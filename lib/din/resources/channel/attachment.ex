defmodule Din.Resources.Channel.Attachment do
  @typedoc "attachment id"
  @type id :: integer

  @typedoc "name of file attached"
  @type filename :: String.t

  @typedoc "size of file in bytes"
  @type size :: integer

  @typedoc "source url of file"
  @type url :: String.t

  @typedoc "a proxied url of file"
  @type proxy_url :: String.t

  @typedoc "height of file (if image)"
  @type height :: integer | nil

  @typedoc "width of file (if image)"
  @type width :: integer | nil

  @enforce_keys [:id, :filename, :size, :url, :proxy_url, :height, :width]
  defstruct [:id, :filename, :size, :url, :proxy_url, :height, :width]
  @type t :: %__MODULE__{
    id: id,
    filename: filename,
    size: size,
    url: url,
    proxy_url: proxy_url,
    height: height,
    width: width
  }
end
