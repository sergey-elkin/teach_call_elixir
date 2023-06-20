defmodule TeachCallElixir.Task do
  alias NimbleCSV.RFC4180, as: CSV

  def run(file_path, opts \\ []) do
    top_tasks_count = opts[:top_tasks_count]
    benchmark_mode = opts[:benchmark_mode]

    file_path
    |> parse_file()
    |> calc_user_tasks_durations()
    |> top_durable_tasks(top_tasks_count)
    |> maybe_print_tasks(benchmark_mode)
  end

  defp parse_file(file_name) do
    File.stream!(file_name, read_ahead: 100_000)
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

      Map.put(
        acc,
        row.user_id,
        Map.put(tasks_map, row.task_id, task_duration)
      )
    end)
  end

  defp top_durable_tasks(user_tasks_map, top_count) do
    user_tasks_map
    |> Enum.reduce(%{}, fn {_user_id, tasks_map}, acc ->
      tasks_map
      |> Enum.reduce(acc, fn {task_id, duration}, acc ->
        task_durations = (acc[task_id] || []) ++ [duration]

        Map.put(acc, task_id, task_durations)
      end)
    end)
    |> Enum.map(fn {task_id, durations_list} ->
      count = Enum.count(durations_list)
      sum = Enum.sum(durations_list)

      {task_id, sum / count}
    end)
    |> Enum.sort_by(fn {_task_id, avg_duration} -> avg_duration end, :desc)
    |> Enum.take(top_count)
  end

  defp maybe_print_tasks(tasks_list, benchmark_mode) do
    tasks_list
    |> Enum.each(fn {task_id, avg_duration} ->
      unless benchmark_mode do
        IO.puts("Task ##{task_id}: #{avg_duration}")
      end
    end)
  end
end
