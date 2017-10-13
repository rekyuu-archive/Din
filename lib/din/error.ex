defmodule Din.Error do
  @typedoc "error code"
  @type code :: integer

  @typedoc "error message"
  @type message :: String.t

  @enforce_keys [:code, :message]
  defstruct [:code, :message]
  @type t :: %__MODULE__{
    code: code,
    message: message
  }
end
