defmodule Din.Resources.Channel.Embed.Provider do
  @typedoc "name of provider"
  @type name :: String.t

  @typedoc "url of provider"
  @type url :: String.t

  @enforce_keys [:name, :url]
  defstruct [:name, :url]
  @type t :: %__MODULE__{
    name: name,
    url: url
  }
end
