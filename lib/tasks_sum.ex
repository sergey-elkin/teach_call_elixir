defmodule TeachCallElixir.TasksSum do
  alias NimbleCSV.RFC4180, as: CSV

  def run(file_path, top_tasks_count) do
    file_path
    |> parse_file()
    |> calc_user_tasks_durations()
    |> print_user_tasks()
    |> most_durable_tasks(top_tasks_count)
  end

  defp parse_file(file_path) do
    File.stream!(file_path, read_ahead: 300_000)
    |> CSV.parse_stream(skip_headers: true)
    |> Stream.map(fn [user_id, task_id, work_duration, _date, _comment] ->
      %{
        user_id: String.to_integer(user_id),
        task_id: String.to_integer(task_id),
        work_duration: String.to_integer(work_duration)
      }
    end)
    |> Enum.to_list()
  end

  defp calc_user_tasks_durations(data) do
    data
    |> Enum.reduce(%{}, fn row, acc ->
      tasks_map = acc[row.user_id] || %{}
      task_duration = (tasks_map[row.task_id] || 0) + row.work_duration

      Map.put(acc, row.user_id, Map.put(tasks_map, row.task_id, task_duration))
    end)
  end

  defp print_user_tasks(user_tasks_map) do
    file = prepare_output_file("users_stats.csv")

    IO.write(file, "user,task,duration\n")

    user_tasks_map
    |> Enum.each(fn {user_id, tasks_map} ->
      IO.write(file, "#{user_id},,\n")

      tasks_map
      |> Enum.each(fn {task_id, task_duration} ->
        IO.write(file, ",#{task_id},#{task_duration}\n")
      end)
    end)

    user_tasks_map
  end

  defp most_durable_tasks(user_tasks_map, top_count) do
    file = prepare_output_file("tasks_stats.csv")

    IO.write(file, "task,duration\n")

    user_tasks_map
    |> Map.values()
    |> Enum.flat_map(&Map.to_list/1)
    |> Enum.group_by(fn {task_id, _duration} -> task_id end)
    |> Enum.map(fn {task_id, durations_list} ->
      total_duration =
        durations_list |> Enum.reduce(0, fn {_task_id, duration}, acc -> acc + duration end)

      {task_id, total_duration}
    end)
    |> Enum.sort_by(fn {_task_id, total_duration} -> total_duration end, :desc)
    |> Enum.take(top_count)
    |> Enum.each(fn {task_id, total_duration} ->
      IO.write(file, "#{task_id},#{total_duration}\n")
    end)
  end

  defp prepare_output_file(file_name) do
    File.rm(file_name)
    File.open!(file_name, [:write, :utf8])
  end
end
