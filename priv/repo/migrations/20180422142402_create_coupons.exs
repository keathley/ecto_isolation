defmodule EctoIsolation.Repo.Migrations.CreateCoupons do
  use Ecto.Migration

  def change do
    create table(:coupons) do
      add :code, :string
      add :used, :boolean

      timestamps()
    end
  end
end
