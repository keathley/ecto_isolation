defmodule EctoIsolation.SafeTransaction do
  alias EctoIsolation.{
    Coupon,
    Repo,
  }
  import Ecto.Query, only: [from: 2]

  @begin "begin;"
  @isolation_level "set transaction isolation level repeatable read;"
  @commit "commit;"

  def transaction(f) do
    Repo.transaction fn ->
      Repo.query!(@isolation_level)
      f.()
    end
  end

  def run(parent, name) do
    receive do
      :select ->
        :ok
    end
    IO.puts "#{name}: Selecting."
    code = Repo.one(from c in Coupon, select: c.code, where: c.code == "foo")
    IO.inspect(code, label: "code")
    send(parent, {self(), :done})

    receive do
      :update ->
        :ok
    end
    IO.puts "#{name} Updating."
    query = from c in Coupon,
      update: [set: [used: true]],
      where: c.code == "foo"
    resp = Repo.update_all(query, [])
    IO.inspect(resp, label: "REsponse")
    send(parent, {self(), :done})

    receive do
      :commit ->
        :ok
    end
    IO.puts "#{name} Committing."
    send(parent, {self(), :done})
  end
end
