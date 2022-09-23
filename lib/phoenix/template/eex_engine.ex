defmodule Phoenix.Template.EExEngine do
  @moduledoc """
  The Phoenix engine that handles the `.eex` extension.
  """

  @behaviour Phoenix.Template.Engine

  def compile(path, name) do
    EEx.compile_file(path, [line: 1] ++ options_for(name))
  end

  defp options_for(name) do
    case Phoenix.Template.format_encoder(name) do
      Phoenix.HTML.Engine ->
        unless Code.ensure_loaded?(Phoenix.HTML.Engine) do
          raise "could not load Phoenix.HTML.Engine to use with .html.eex templates. " <>
                  "You can configure your own format encoder for HTML but we recommend " <>
                  "adding phoenix_html as a dependency as it provides XSS protection."
        end

        trim =
          case Application.get_env(:phoenix_template, :trim_on_html_eex_engine) do
            nil ->
              case Application.get_env(:phoenix_view, :trim_on_html_eex_engine) do
                nil ->
                  Application.get_env(:phoenix, :trim_on_html_eex_engine, true)

                boolean ->
                  # TODO: Uncomment once :phoenix_template is extracted
                  # IO.warn(
                  #   "config :phoenix_view, :trim_on_html_eex_engine is deprecated, please use config :phoenix_template, :trim_on_html_eex_engine instead"
                  # )

                  boolean
              end

            boolean ->
              boolean
          end

        [engine: Phoenix.HTML.Engine, trim: trim]

      _ ->
        [engine: EEx.SmartEngine]
    end
  end
end
