defmodule TeachCallElixir.TasksSumParallel do
  alias NimbleCSV.RFC4180, as: CSV

  def run(file_path, top_tasks_count) do
    {users_stats, top_tasks} = parse_file(file_path, top_tasks_count)

    print_user_stats(users_stats)
    print_top_tasks(top_tasks)
  end

  defp parse_file(file_path, top_tasks_count) do
    {:ok, pid} = GenServer.start_link(Storage, %{})

    File.stream!(file_path, read_ahead: 300_000)
    |> CSV.parse_stream(skip_headers: true)
    |> Stream.each(fn [user_id, task_id, work_duration, _date, _comment] ->
      Storage.put(
        pid,
        String.to_integer(user_id),
        String.to_integer(task_id),
        String.to_integer(work_duration)
      )
    end)
    |> Stream.run()

    Storage.get_stats(pid, top_tasks_count)
  end

  defp print_user_stats(user_tasks_map) do
    file = prepare_output_file("users_stats.csv")

    IO.write(file, "user,task,duration\n")

    Enum.each(user_tasks_map, fn {user_id, tasks_map} ->
      IO.write(file, "#{user_id},,\n")

      Enum.each(tasks_map, fn {task_id, task_duration} ->
        IO.write(file, ",#{task_id},#{task_duration}\n")
      end)
    end)
  end

  defp print_top_tasks(top_tasks) do
    file = prepare_output_file("tasks_stats.csv")

    IO.write(file, "task,duration\n")

    Enum.each(top_tasks, fn {task_id, total_duration} ->
      IO.write(file, "#{task_id},#{total_duration}\n")
    end)
  end

  defp prepare_output_file(file_name) do
    File.rm(file_name)
    File.open!(file_name, [:write, :utf8])
  end
end
