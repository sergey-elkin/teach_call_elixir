defmodule TeachCallElixir do
  @moduledoc """
  Documentation for `TeachCallElixir`.
  """

  @file_name "teach_call.csv"
  @top_tasks_count 10
  @benchmark_time 10

  # @task_module TeachCallElixir.AverageTime
  # @task_module TeachCallElixir.TasksSum
  @task_module TeachCallElixir.TasksSumParallel

  def run do
    case System.get_env("ENABLE_BENCHEE") do
      "true" -> run_with_benchee(@task_module)
      _ -> run_without_benchee(@task_module)
    end
  end

  defp run_without_benchee(task_module) do
    @file_name
    |> task_module.run(@top_tasks_count)
  end

  defp run_with_benchee(task_module) do
    Benchee.run(
      %{
        "task" => fn -> task_module.run(@file_name, @top_tasks_count) end
      },
      warmup: 0,
      time: @benchmark_time,
      memory_time: @benchmark_time
    )
  end
end
