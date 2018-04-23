defmodule EctoIsolation.Repo.Migrations.CreateCoupons do
  use Ecto.Migration

  def change do
    create table(:coupons) do
      add :code, :string, unique: true
      add :used, :boolean, default: false
    end
  end
end
