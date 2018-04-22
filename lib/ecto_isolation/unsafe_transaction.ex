defmodule EctoIsolation.UnsafeTransaction do
  alias EctoIsolation.{
    Coupon,
    Repo,
  }
  import Ecto.Query, only: [from: 2]

  def transaction(f) do
    Repo.transaction(f)
  end

  def run(name) do
    receive do
      :select ->
        :ok
    end
    IO.puts "#{name}: Selecting."
    Repo.one(from c in Coupon, select: c.code, where: c.code == "foo")

    receive do
      :update ->
        :ok
    end
    IO.puts "#{name} Updating."
    query = from c in Coupon,
      update: [set: [used: true]],
      where: c.code == "foo"
    Repo.update_all(query, [])

    receive do
      :commit ->
        :ok
    end
    IO.puts "#{name} Committing."
  end
end
