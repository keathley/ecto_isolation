defmodule EctoIsolation.Coupon do
  use Ecto.Schema

  schema "coupons" do
    field :code, :string
    field :used, :boolean

    timestamps()
  end
end
