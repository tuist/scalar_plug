defmodule ScalarPlug do
  @moduledoc """
  Documentation for `ScalarPlug`.
  """

  @doc """
  Hello world.
  """

  def init(opts) do
    path = Keyword.get(opts, :path)

    if is_nil(path) do
      raise "The :path option is required for ScalarPlug"
    end

    spec_path = Keyword.get(opts, :spec_path)

    if is_nil(spec_path) do
      raise "The :spec_path option is required for ScalarPlug"
    end

    title = Keyword.get(opts, :title, "API Documentation")
    url = Keyword.get(opts, :url)
    image_url = Keyword.get(opts, :image_url)
    x_handle = Keyword.get(opts, :x_handle)

    %{
      path: path,
      spec_path: spec_path,
      title: title,
      url: url,
      image_url: image_url,
      x_handle: x_handle
    }
  end

  def call(%{request_path: request_path, port: port, host: host, scheme: scheme} = conn, %{
        path: path,
        spec_path: spec_path,
        title: title,
        url: url,
        image_url: image_url,
        x_handle: x_handle
      })
      when request_path == path do
    url =
      if url do
        url
      else
        URI.to_string(%URI{
          port: port,
          scheme: Atom.to_string(scheme),
          host: host
        })
      end

    head = [
      {"title", [], [title]},
      {"meta", [{"charset", "utf-8"}], []},
      {"meta", [{"name", "viewport"}, {"content", "width=device-width, initial-scale=1"}], []},
      {"meta", [{"property", "og:url"}, {"content", url}], []},
      {"meta", [{"property", "og:type"}, {"content", "website"}], []},
      {"meta", [{"property", "og:title"}, {"content", title}], []},
      {"meta", [{"name", "twitter:card"}, {"content", "summary"}], []},
      {"meta", [{"name", "twitter:title"}, {"content", title}], []},
      {"meta", [{"name", "twitter:domain"}, {"content", host}], []},
      {"meta", [{"name", "twitter:url"}, {"content", url}], []}
    ]

    head = if x_handle do
      head ++ [{"meta", [{"name", "twitter:site"}, {"content", "@#{x_handle}"}], []}]
    else
      head
    end

    head =
      if image_url do
        head ++
          [
            {"meta", [{"property", "og:image"}, {"content", image_url}], []},
            {"meta", [{"name", "twitter:image"}, {"content", image_url}], []}
          ]
      else
        head
      end

    #   <meta name="twitter:card" content="summary" />

    document = [
      {"html", [],
       [
         {
           "head",
           [],
           head
         }
       ]}
    ]

    body = Floki.raw_html(document)

    conn
    |> Plug.Conn.put_resp_header("content-type", "text/html; charset=utf-8")
    |> Plug.Conn.send_resp(200, ~s"""
    <!doctype html>
    #{body}
    """)
    |> Plug.Conn.halt()
  end

  def call(conn, _opts), do: conn
end
