defmodule EctoIsolation.Coordinator do
  alias EctoIsolation.{
    Coupon,
    Repo,
  }
  import Ecto.Query, only: [from: 2]

  def race do
    t1 = start_transaction()
    t2 = start_transaction()

    send(t1, :select)
    send(t2, :select)

    send(t1, :update)
    send(t2, :update)
  end

  def start_transaction do
    spawn_link fn ->
      Repo.transaction(fn -> do_transaction() end)
    end
  end

  def do_transaction do
    receive do
      :select ->
        :ok
    end
    Repo.one(from c in Coupon, select: c.code, where: c.code == "foo")

    receive do
      :update ->
        :ok
    end
    query = from c in Coupon,
      update: [set: [used: true]],
      where: c.code == "foo"
    Repo.update_all(query, [])
  end
end
