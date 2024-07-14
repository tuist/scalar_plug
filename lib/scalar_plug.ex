defmodule ScalarPlug do
  @external_resource readme = Path.join([__DIR__, "../README.md"])

  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC !-->") |> Enum.fetch!(1)

  @type options :: [
          path: String.t(),
          spec_href: String.t(),
          title: String.t(),
          og_title: String.t(),
          url: String.t(),
          image_url: String.t(),
          x_handle: String.t(),
          configuration: map(),
          additional_head_elements: tuple(),
          additional_body_elements: tuple()
        ]

  @doc ~S"""
  Initializes the plug with the options or a mfa tuple to load the configuration at runtime.
  """
  @spec init(opts :: options() | mfa()) :: any()
  def init(opts) when is_list(opts) do
    opts |> parse_opts()
  end

  def init(opts) when is_tuple(opts) do
    opts
  end

  def init(opts) when is_function(opts) do
    opts
  end

  @spec parse_opts(opts :: options()) :: map()
  defp parse_opts(opts) do
    path = Keyword.get(opts, :path)

    if is_nil(path) do
      raise "The :path option is required for ScalarPlug"
    end

    spec_href = Keyword.get(opts, :spec_href)

    if is_nil(spec_href) do
      raise "The :spec_href option is required for ScalarPlug"
    end

    title = Keyword.get(opts, :title, "API Documentation")
    og_title = Keyword.get(opts, :og_title, title)
    url = Keyword.get(opts, :url)
    image_url = Keyword.get(opts, :image_url)
    x_handle = Keyword.get(opts, :x_handle)
    configuration = Keyword.get(opts, :configuration, %{})
    additional_head_elements = Keyword.get(opts, :additional_head_elements, [])
    additional_body_elements = Keyword.get(opts, :additional_body_elements, [])

    %{
      path: path,
      spec_href: spec_href,
      title: title,
      og_title: og_title,
      url: url,
      image_url: image_url,
      x_handle: x_handle,
      configuration: configuration,
      additional_head_elements: additional_head_elements,
      additional_body_elements: additional_body_elements
    }
  end

  @doc ~S"""
  If the request matches the `path` configuration value, it returns a HTML response with a Scalar setup to load the API documentation.
  Otherwise it returns the same connection.
  """
  @spec call(Plug.Conn.t(), options() | mfa() | fun()) :: Plug.Conn.t()
  def call(conn, opts) when is_function(opts) do
    call(conn, opts.() |> parse_opts)
  end

  def call(conn, {module, function}) do
    call(conn, apply(module, function, []) |> parse_opts())
  end

  def call(%{request_path: request_path, port: port, host: host, scheme: scheme} = conn, %{
        path: path,
        spec_href: spec_href,
        title: title,
        og_title: og_title,
        url: url,
        image_url: image_url,
        x_handle: x_handle,
        configuration: configuration,
        additional_head_elements: additional_head_elements,
        additional_body_elements: additional_body_elements
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
      {"meta", [{"property", "og:title"}, {"content", og_title}], []},
      {"meta", [{"name", "twitter:card"}, {"content", "summary"}], []},
      {"meta", [{"name", "twitter:title"}, {"content", title}], []},
      {"meta", [{"name", "twitter:domain"}, {"content", host}], []},
      {"meta", [{"name", "twitter:url"}, {"content", url}], []}
    ]

    head =
      if x_handle do
        head ++ [{"meta", [{"name", "twitter:site"}, {"content", "@#{x_handle}"}], []}]
      else
        head
      end

    head = head ++ additional_head_elements

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

    configuration_json = Jason.encode!(configuration) |> String.replace("\"", "'")

    body = [
      {"script",
       [
         {"id", "api-reference"},
         {"data-url", spec_href},
         {"data-configuration", configuration_json}
       ], []},
      {"script", [{"src", "https://cdn.jsdelivr.net/npm/@scalar/api-reference"}], []}
    ]

    body = body ++ additional_body_elements

    document = [
      {"html", [],
       [
         {
           "head",
           [],
           head
         },
         {
           "body",
           [],
           body
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
