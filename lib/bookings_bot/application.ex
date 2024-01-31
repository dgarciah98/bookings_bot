defmodule BookingsBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # This will setup the Registry.ExGram
      ExGram,
      # BookingsBot.Server,
      {BookingsBot.Bot, [method: :polling, token: ExGram.Config.get(:ex_gram, :token)]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BookingsBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
