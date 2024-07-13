defmodule ScalarPlugTest do
  use ExUnit.Case
  alias ScalarPlug
  use Plug.Test
  doctest ScalarPlug

  describe "init/1" do
    test "raises when the :path option is missing" do
      assert_raise RuntimeError, "The :path option is required for ScalarPlug", fn ->
        ScalarPlug.init([])
      end
    end

    test "raises when the :spec_href option is missing" do
      assert_raise RuntimeError, "The :spec_href option is required for ScalarPlug", fn ->
        ScalarPlug.init(path: "/api/docs")
      end
    end
  end

  describe "call/2" do
    test "it returns the correct response" do
      # Given
      conn = conn("GET", "/api/docs")

      url =
        URI.to_string(%URI{
          port: conn.port,
          scheme: Atom.to_string(conn.scheme),
          host: conn.host
        })

      image_url =
        URI.to_string(%URI{
          port: conn.port,
          scheme: Atom.to_string(conn.scheme),
          host: conn.host,
          path: "/images/og.png"
        })

      x_handle = "test"
      spec_href = "/api/spec"

      opts =
        ScalarPlug.init(
          path: "/api/docs",
          spec_href: spec_href,
          image_url: image_url,
          x_handle: x_handle,
          configuration: %{theme: "purple"},
          additional_head_elements: [
            {"script", [{"id", "additional_head_element"}], []}
          ],
          additional_body_elements: [
            {"p", [{"id", "additional_body_element"}], []}
          ]
        )

      # When
      got = conn |> ScalarPlug.call(opts)

      # Then
      assert got.status == 200
      assert get_resp_header(got, "content-type") |> List.first() == "text/html; charset=utf-8"
      html = got.resp_body |> Floki.parse_document!()
      assert Floki.find(html, "title") |> Floki.text() == "API Documentation"
      assert Floki.find(html, "meta[property='og:url'][content='#{url}']") != []
      assert Floki.find(html, "meta[property='og:type'][content='website']") != []
      assert Floki.find(html, "meta[property='og:title'][content='API Documentation']") != []
      assert Floki.find(html, "meta[property='og:image'][content='#{image_url}']") != []
      assert Floki.find(html, "meta[name='twitter:card'][content='summary']") != []
      assert Floki.find(html, "meta[name='twitter:site'][content='@#{x_handle}']") != []
      assert Floki.find(html, "meta[name='twitter:image'][content='#{image_url}']") != []
      assert Floki.find(html, "meta[name='twitter:title'][content='API Documentation']") != []
      assert Floki.find(html, "meta[name='twitter:domain'][content='#{conn.host}']") != []
      assert Floki.find(html, "meta[name='twitter:url'][content='#{url}']") != []
      script_data_configuration = Jason.encode!(%{theme: "purple"}) |> String.replace("\"", "'")

      api_reference =
        Floki.find(html, "body > script[id='api-reference'][data-url='#{spec_href}']")
        |> List.first()

      assert api_reference |> Floki.attribute("data-configuration") |> List.first() ==
               script_data_configuration

      assert Floki.find(
               html,
               "body > script[src='https://cdn.jsdelivr.net/npm/@scalar/api-reference']"
             ) != []

      assert Floki.find(html, "head > script#additional_head_element") != []
      assert Floki.find(html, "body > p#additional_body_element") != []
    end
  end
end
