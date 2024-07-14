defmodule ScalarPlug.MixProject do
  use Mix.Project

  @description "ScalarPlug is an Elixir plug to integrate Scalar into your Elixir application. When a request URL path matches the path the plug has been configured with, it returns a HTML response initializing Scalar."
  @source_url "https://github.com/tuist/ScalarPlug"
  @version "0.2.0"

  def project do
    [
      app: :scalar_plug,
      version: @version,
      description: @description,
      elixir: "~> 1.17",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/tuist/ScalarPlug",
      homepage_url: "https://github.com/tuist/ScalarPlug",
      docs: docs()
    ]
  end

  defp package() do
    %{
      maintainers: ["Pedro Piñera", "Marek Fořt"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/ScalarPlug/changelog.html",
        "GitHub" => @source_url
      }
    }
  end

  defp docs() do
    [
      main: "ScalarPlug",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["CHANGELOG.md", {:"README.md", [title: "Overview"]}],
      main: "readme",
      authors: ["pedro@tuist.io", "marek@tuist.io"]
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
      {:floki, "~> 0.36.2"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end
end
