defmodule Din.Resources.Channel.Embed.Footer do
  @typedoc "footer text"
  @type text :: String.t

  @typedoc "url of footer icon (only supports http(s) and attachments)"
  @type icon_url :: String.t

  @typedoc "a proxied url of footer icon"
  @type proxy_icon_url :: String.t

  @enforce_keys [:text, :icon_url, :proxy_icon_url]
  defstruct [:text, :icon_url, :proxy_icon_url]
  @type t :: %__MODULE__{
    text: text,
    icon_url: icon_url,
    proxy_icon_url: proxy_icon_url
  }
end
