defmodule ScalarPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :scalar_plug,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.16"},
      {:floki, "~> 0.36.2"}
    ]
  end
end
