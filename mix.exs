defmodule BookingsBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :bookings_bot,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BookingsBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  def deps do
    [
      {:timex, "~> 3.0"},
      {:ex_gram, git: "https://github.com/rockneurotiko/ex_gram.git"},
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.12"},
      {:jason, ">= 1.0.0"}
    ]
  end
end
