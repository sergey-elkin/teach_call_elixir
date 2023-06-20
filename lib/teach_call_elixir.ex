defmodule TeachCallElixir do
  @moduledoc """
  Documentation for `TeachCallElixir`.
  """

  alias TeachCallElixir.Task

  @file_name "teach_call.csv"
  @top_tasks_count 10
  @benchmark_time 10

  def run do
    case System.get_env("ENABLE_BENCHEE") do
      "true" -> run_with_benchee()
      _ -> run_without_benchee()
    end
  end

  defp run_without_benchee() do
    Task.run(@file_name, top_tasks_count: @top_tasks_count)
  end

  defp run_with_benchee() do
    Benchee.run(
      %{
        "task" => fn -> Task.run(@file_name, top_tasks_count: @top_tasks_count, benchmark_mode: true) end
      },
      warmup: 0,
      time: @benchmark_time,
      memory_time: @benchmark_time
    )
  end
end
