defmodule Mix.Tasks.Start do
  use Mix.Task

  require Logger

  # Usage: mix start

  @impl Mix.Task
  def run(_) do
    TeachCallElixir.run()
  end
end
