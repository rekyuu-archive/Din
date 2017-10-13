defmodule Din.Resources.Channel.Embed.Video do
  @typedoc "source url of video"
  @type url :: String.t

  @typedoc "height of video"
  @type height :: integer

  @typedoc "width of video"
  @type width :: integer

  @enforce_keys [:url, :height, :width]
  defstruct [:url, :height, :width]
  @type t :: %__MODULE__{
    url: url,
    height: height,
    width: width
  }
end
