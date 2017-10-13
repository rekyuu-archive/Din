defmodule Din.Resources.Channel.Embed.Author do
  @typedoc "name of author"
  @type name :: String.t

  @typedoc "url of author"
  @type url :: String.t

  @typedoc "url of author icon (only supports http(s) and attachments)"
  @type icon_url :: String.t

  @typedoc "a proxied url of author icon"
  @type proxy_icon_url :: String.t

  @enforce_keys [:name, :url, :icon_url, :proxy_icon_url]
  defstruct [:name, :url, :icon_url, :proxy_icon_url]
  @type t :: %__MODULE__{
    name: name,
    url: url,
    icon_url: icon_url,
    proxy_icon_url: proxy_icon_url
  }
end
