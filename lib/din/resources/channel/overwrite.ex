defmodule Din.Resources.Channel.Overwrite do
  @typedoc "role or user id"
  @type id :: integer

  @typedoc "either \"role\" or \"member\""
  @type type :: String.t

  @typedoc "permission bit set"
  @type allow :: integer

  @typedoc "permission bit set"
  @type deny :: integer

  @enforce_keys [:id, :type, :allow, :deny]
  defstruct [:id, :type, :allow, :deny]
  @type t :: %__MODULE__{
    id: id,
    type: type,
    allow: allow,
    deny: deny
  }
end
