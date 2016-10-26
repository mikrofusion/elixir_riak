defmodule ElixirRiak.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elixir_riak,
      version: "0.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      preferred_cli_env: [espec: :test]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :logger,
      ],
      included_application: [
        :riakc
      ],
      mod: {ElixirRiak, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:riakc, "~> 2.4"},
      {:espec, "~> 1.1.0", only: :test},
      {:ex_machina, "~> 1.0", only: :test}
    ]
  end
end
