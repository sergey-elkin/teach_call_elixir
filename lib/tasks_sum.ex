defmodule TeachCallElixir.TasksSum do
  alias NimbleCSV.RFC4180, as: CSV

  def run(file_path, top_tasks_count, opts \\ []) do
    benchmark_mode = opts[:benchmark_mode]

    file_path
    |> parse_file()
    |> calc_user_tasks_durations()
    |> maybe_print_user_tasks(benchmark_mode)
    |> most_durable_tasks(top_tasks_count)
  end

  defp parse_file(file_path) do
    File.stream!(file_path, read_ahead: 300_000)
    |> CSV.parse_stream(skip_headers: true)
    |> Stream.map(fn [user_id, task_id, work_duration, _date, _comment] ->
      %{user_id: String.to_integer(user_id), task_id: String.to_integer(task_id), work_duration: String.to_integer(work_duration)}
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

  defp maybe_print_user_tasks(user_tasks_map, true) do
    user_tasks_map
    |> Enum.each(fn {_user_id, tasks_map} ->
      tasks_map
      |> Enum.each(fn _ ->
        nil
      end)
    end)

    user_tasks_map
  end

  defp maybe_print_user_tasks(user_tasks_map, _benchmark_mode) do
    user_tasks_map
    |> Enum.each(fn {user_id, tasks_map} ->
      IO.puts("User ##{user_id}:")

      tasks_map
      |> Enum.each(fn {task_id, task_duration} ->
        IO.puts("  Task ##{task_id}: #{task_duration}")
      end)

      IO.puts("=======================")
    end)

    user_tasks_map
  end

  defp most_durable_tasks(user_tasks_map, top_count) do
    user_tasks_map
    |> Map.values()
    |> Enum.flat_map(&Map.to_list/1)
    |> Enum.group_by(fn {task_id, _duration} -> task_id end)
    |> Enum.map(fn {task_id, durations_list} ->
      total_duration = durations_list |> Enum.reduce(0, fn {_task_id, duration}, acc -> acc + duration end)

      {task_id, total_duration}
    end)
    |> Enum.sort_by(fn {_task_id, total_duration} -> total_duration end, :desc)
    |> Enum.take(top_count)
  end
end
