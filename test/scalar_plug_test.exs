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

    test "raises when the :spec_path option is missing" do
      assert_raise RuntimeError, "The :spec_path option is required for ScalarPlug", fn ->
        ScalarPlug.init([path: "/api/docs"])
      end
    end
  end

  describe "call/2" do
    test "when " do
      # Given
      conn = conn("GET", "/api/docs")
      url = URI.to_string(%URI{
        port: conn.port,
        scheme: Atom.to_string(conn.scheme),
        host: conn.host
      })
      image_url = URI.to_string(%URI{
        port: conn.port,
        scheme: Atom.to_string(conn.scheme),
        host: conn.host,
        path: "/images/og.png"
      })
      x_handle = "test"
      opts = ScalarPlug.init([path: "/api/docs", spec_path: "/api/spec", image_url: image_url, x_handle: x_handle])


      # When
      got = conn |> ScalarPlug.call(opts)

      # Then
      assert got.status == 200
      assert get_resp_header(got, "content-type") |> List.first() == "text/html; charset=utf-8"
      html = got.resp_body |> Floki.parse_document!()
      assert Floki.find(html, "title") |> Floki.text() == "API Documentation"
      assert Floki.find(html, "meta[property='og:url'][content='#{url}']") != nil
      assert Floki.find(html, "meta[property='og:type'][content='website']") != nil
      assert Floki.find(html, "meta[property='og:title'][content='API Documentation']") != nil
      assert Floki.find(html, "meta[property='og:image'][content=#{image_url}']") != nil
      assert Floki.find(html, "meta[name='twitter:card'][content='summary']") != nil
      assert Floki.find(html, "meta[name='twitter:site'][content='#{x_handle}']") != nil
      assert Floki.find(html, "meta[name='twitter:image'][content='#{image_url}']") != nil
      assert Floki.find(html, "meta[name='twitter:title'][content='API Documentation']") != nil
      assert Floki.find(html, "meta[name='twitter:domain'][content='#{conn.host}']") != nil
      assert Floki.find(html, "meta[name='twitter:url'][content='#{url}']") != nil

    end
  end
end
