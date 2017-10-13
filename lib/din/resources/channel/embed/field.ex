defmodule Din.Resources.Channel.Embed.Field do
  @typedoc "name of the field"
  @type name :: String.t

  @typedoc "value of the field"
  @type value :: String.t

  @typedoc "whether or not this field should display inline"
  @type inline :: boolean

  @enforce_keys [:name, :value, :inline]
  defstruct [:name, :value, :inline]
  @type t :: %__MODULE__{
    name: name,
    value: value,
    inline: inline
  }
end
