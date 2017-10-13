defmodule Din.Resources.Channel.Embed.Thumbnail do
  @typedoc "source url of thumbnail (only supports http(s) and attachments)"
  @type url :: String.t

  @typedoc "a proxied url of the thumbnail"
  @type proxy_url :: String.t

  @typedoc "height of thumbnail"
  @type height :: integer

  @typedoc "width of thumbnail"
  @type width :: integer

  @enforce_keys [:url, :proxy_url, :height, :width]
  defstruct [:url, :proxy_url, :height, :width]
  @type t :: %__MODULE__{
    url: url,
    proxy_url: proxy_url,
    height: height,
    width: width
  }
end
