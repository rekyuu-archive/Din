defmodule Din.Resources.AuditLog do
  alias Din.Error

  @doc """
  Returns an audit log object for the guild. Requires the `VIEW_AUDIT_LOG` permission.

  ## Options

  - `user_id` - filter the log for a user id
  - `action_type` - the type of audit log event
  - `before` - filter the log before a certain entry id
  - `limit` - how many entries are returned (default 50, minimum 1, maximum 100)
  """
  @spec get_guild_audit_log(Din.snowflake, [
    user_id: Din.snowflake,
    action_type: integer,
    before: Din.snowflake,
    limit: 1..100]) :: map | Error.t
  def get_guild_audit_log(guild_id, opts \\ []) do
    Din.API.get "/guilds/#{guild_id}/audit-logs?#{URI.encode_query opts}"
  end
end
