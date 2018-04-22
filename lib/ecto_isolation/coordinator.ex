defmodule EctoIsolation.Coordinator do
  def race(mod) do
    t1 = start_transaction(mod, :t1)
    t2 = start_transaction(mod, :t2)

    :ok = sync(t1, :select)
    :ok = sync(t2, :select)

    :ok = sync(t1, :update)
    :ok = sync(t2, :update)

    :ok = sync(t1, :commit)
    :ok = sync(t2, :commit)
  end

  def sync(pid, msg) do
    send(pid, msg)
    receive do
      {^pid, :done} ->
        :ok
    end
  end

  def start_transaction(mod, name) do
    pid = self()
    spawn_link fn ->
      mod.transaction(fn -> mod.run(pid, name) end)
    end
  end
end
