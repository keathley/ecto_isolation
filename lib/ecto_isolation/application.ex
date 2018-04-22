defmodule EctoIsolation.Application do
  use Application

  def start(_, _) do
    children = [
      EctoIsolation.Repo,
    ]

    opts = [strategy: :one_for_one, name: EctoIsolation.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
