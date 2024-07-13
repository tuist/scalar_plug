# ScalarPlug

<!-- MDOC !-->

`ScalarPlug` is an Elixir plug to integrate [Scalar](https://github.com/scalar/scalar) into your Elixir application. When a request URL path matches the path the plug has been configured with, it returns a HTML response initializing Scalar.

## Installation

The package is [available in Hex](https://hex.pm/docs/publish) and you can install it by adding the dependency to your project's `mix.exs`:

```elixir
def deps do
  [
    {:scalar_plug, "~> 0.1.0"}
  ]
end
```

## Usage

You can add `ScalarPlug` as a plug to your project passing the configuration options as a keyword list, or a mfa `{:module, :function}` to fetch the options at runtime. The following options are supported:

- `path`: The path at which the documentation will be served (e.g. `/api/docs`).
- `spec_href`: The path or URL to the OpenAPI specification (e.g. `/api/spec`).
- `title` (optional): The value of the `<title>` head tag. When absent, the value `API Documentation` is used.
- `og_title` (optional): The value of the `<meta property="og-title">` Open Graph tag. When absent, the value of `title` is used.
- `url` (optional): The value of the `<meta property="og-url">` and `<meta name="twitter:url">` tags. When absent, the value is derived from the plug request.
- `image_url` (optional): The value of the `<meta property="og-image">` and `<meta name="twitter:image">` tags. When absent, the elements are not included.
- `x_handle` (optional): The X handle (without the @) to set to the `<meta name="twitter:site>` element. When absent, the element is not included.
- `additional_head_elements` (optional): Additional elements to include in the `<head></head>` section of the HTML. The elements should be passed using Floki's tuple-based syntax: `[{element, attributes, children}]`.
- `additional_body_elements` (optional): Additional elements to include in the `<body></body>` section of the HTML. The elements should be passed using Floki's tuple-based syntax: `[{element, attributes, children}]`.
- `configuration` (optional): The Scalar configuration (e.g. `%{ theme: "purple"}`). The configuration is set in a `<script id="api-reference"/>` element as expected by Scalar.

<!-- tabs-open -->

### Compile-time configuration

```elixir
plug ScalarPlug, path: "/api/docs", spec_path: "/api/spec", title: "API Documentation"
```

### MFA runtime configuration

```elixir
plug ScalarPlug, {ConfigurationModule, :scalar_config}
```

### Function runtime configuration

```elixir
plug ScalarPlug, fn -> [path: "/api/docs", spec_path: "/api/spec", title: "API Documentation"] end
```

<!-- tabs-close -->