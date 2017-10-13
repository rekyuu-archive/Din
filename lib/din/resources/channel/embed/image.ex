defmodule Din.Resources.Channel.Embed.Image do
  @typedoc "source url of image (only supports http(s) and attachments)"
  @type url :: String.t

  @typedoc "a proxied url of the image"
  @type proxy_url :: String.t

  @typedoc "height of image"
  @type height :: integer

  @typedoc "width of image"
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
