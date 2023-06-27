defmodule Storage do
  use GenServer

  # Client

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state)
  end

  def put(pid, user_id, task_id, work_duration) do
    GenServer.cast(pid, {user_id, task_id, work_duration})
  end

  def get_stats(pid, top_tasks_count) do
    GenServer.call(pid, {:get_stats, top_tasks_count})
  end

  # Server (callbacks)

  @impl true
  def init(_initial_state) do
    {:ok, {%{}, %{}}}
  end

  @impl true
  def handle_cast({user_id, task_id, work_duration}, {users_stats, tasks_stats}) do
    {
      :noreply,
      {
        update_users_stats(users_stats, user_id, task_id, work_duration),
        update_tasks_stats(tasks_stats, task_id, work_duration)
      }
    }
  end

  @impl true
  def handle_call({:get_stats, top_tasks_count}, _from, {users_stats, tasks_stats} = state) do
    top_tasks =
      tasks_stats
      |> Enum.sort_by(fn {_task_id, total_duration} -> total_duration end, :desc)
      |> Enum.take(top_tasks_count)

    {:reply, {users_stats, top_tasks}, state}
  end

  defp update_users_stats(users_stats, user_id, task_id, work_duration) do
    user_tasks_map = users_stats[user_id] || %{}
    user_task_duration = (user_tasks_map[task_id] || 0) + work_duration

    Map.put(users_stats, user_id, Map.put(user_tasks_map, task_id, user_task_duration))
  end

  defp update_tasks_stats(tasks_stats, task_id, work_duration) do
    task_duration = (tasks_stats[task_id] || 0) + work_duration

    Map.put(tasks_stats, task_id, task_duration)
  end
end
