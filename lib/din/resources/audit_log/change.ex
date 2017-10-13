defmodule Din.Resources.AuditLog.Change do
  alias Din.Permissions.Role
  alias Din.Resources.Channel

  @typedoc "new value of the key"
  @type new_value :: nil | boolean | integer | String.t | list(Role.t) | list(Channel.Overwrite.t)

  @typedoc "old value of the key"
  @type old_value :: nil | boolean | integer | String.t | list(Role.t) | list(Channel.Overwrite.t)

  @typedoc "type of audit log change key"
  @type key :: String.t

  @enforce_keys [:new_value, :old_value, :key]
  defstruct [:new_value, :old_value, :key]
  @type t :: %__MODULE__{
    new_value: new_value,
    old_value: old_value,
    key: key
  }
end
