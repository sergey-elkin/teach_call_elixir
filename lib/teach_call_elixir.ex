defmodule TeachCallElixir do
  @moduledoc """
  Documentation for `TeachCallElixir`.
  """

  alias TeachCallElixir.AverageTime
  alias TeachCallElixir.TasksSum

  @file_name "teach_call.csv"
  @top_tasks_count 10
  @benchmark_time 10

  def run do
    IO.puts("Start processing...")

    case System.get_env("ENABLE_BENCHEE") do
      "true" -> run_with_benchee()
      _ -> run_without_benchee()
    end

    IO.puts("Done.")
  end

  defp run_without_benchee() do
    @file_name
    |> TasksSum.run(@top_tasks_count)
    |> print_tasks()
  end

  defp run_with_benchee() do
    Benchee.run(
      %{
        "task" => fn -> TasksSum.run(@file_name, @top_tasks_count, benchmark_mode: true) end
      },
      warmup: 0,
      time: @benchmark_time,
      memory_time: @benchmark_time
    )
  end

  defp print_tasks(tasks_list) do
    tasks_list
    |> Enum.each(fn {task_id, avg_duration} ->
      IO.puts("Task ##{task_id}: #{avg_duration}")
    end)
  end
end
