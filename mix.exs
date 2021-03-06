defmodule Makeitcrash.Mixfile do
  use Mix.Project

  def project do
    [app: :makeitcrash,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Makeitcrash.Application, []},
     extra_applications: [:logger, :runtime_tools, :ex_twilio]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0-rc"},
     {:phoenix_pubsub, "~> 1.0"},
     {:gettext, "~> 0.11"},
     {:ex_twilio, "~> 0.3.0"},
     {:hackney, "== 1.8.0", override: true},
     {:cowboy, "~> 1.0"}]
  end
end
