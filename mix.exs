defmodule ScalarPlug.MixProject do
  use Mix.Project

  @description "ScalarPlug is an Elixir plug to integrate Scalar into your Elixir application. When a request URL path matches the path the plug has been configured with, it returns a HTML response initializing Scalar."
  @source_url "https://github.com/Aroy-Art/scalar_plug"
  @version "0.3.0"

  def project do
    [
      app: :scalar_api_plug,
      version: @version,
      description: @description,
      elixir: "~> 1.17",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs()
    ]
  end

  defp package() do
    %{
      maintainers: ["Aroy-Art"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/scalar_api_plug/changelog.html",
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
      authors: ["aroy-art@pm.me"]
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
      {:plug, "~> 1.20"},
      {:floki, "~> 0.38"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end
end
