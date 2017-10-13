defmodule Din.Resources.AuditLog do
  alias Din.Resources.{AuditLog, Guild, User, Webhook}
  alias Din.Error
  @moduledoc """
  Whenever an admin action is performed on the API, an entry is added to the respective guild's audit log. You can specify the reason by attaching the `X-Audit-Log-Reason` request header. This header supports url encoded utf8 characters.
  """

  @typedoc "array of webhook objects"
  @type webhooks :: list(Webhook.t) | nil

  @typedoc "array of user objects"
  @type users :: list(User.t) | nil

  @typedoc "array of audit log entry objects"
  @type audit_log_entries :: list(AuditLog.Entry.t) | nil

  @enforce_keys [:webhooks, :users, :audit_log_entries]
  defstruct [:webhooks, :users, :audit_log_entries, :code, :message]
  @type t :: %__MODULE__{
    webhooks: webhooks,
    users: users,
    audit_log_entries: audit_log_entries
  }

  @typedoc "list of valid audit log events"
  @type event :: :guild_update | :channel_create | :channel_update | :channel_delete | :channel_overwrite_create | :channel_overwrite_update | :channel_overwrite_delete | :member_kick | :member_prune | :member_ban_add | :member_ban_remove | :member_update | :member_role_update | :role_create | :role_update | :role_delete | :invite_create | :invite_update | :invite_delete | :webhook_create | :webhook_update | :webhook_delete | :emoji_create | :emoji_update | :emoji_delete | :message_delete

  @doc """
  Used to give readable names to event opcodes.
  """
  @spec event_codes :: map
  def event_codes do
    %{
      guild_update:              1,
      channel_create:           10,
      channel_update:           11,
      channel_delete:           12,
      channel_overwrite_create: 13,
      channel_overwrite_update: 14,
      channel_overwrite_delete: 15,
      member_kick:              20,
      member_prune:             21,
      member_ban_add:           22,
      member_ban_remove:        23,
      member_update:            24,
      member_role_update:       25,
      role_create:              30,
      role_update:              31,
      role_delete:              32,
      invite_create:            40,
      invite_update:            41,
      invite_delete:            42,
      webhook_create:           50,
      webhook_update:           51,
      webhook_delete:           52,
      emoji_create:             60,
      emoji_update:             61,
      emoji_delete:             62,
      message_delete:           72
    }
  end

  @doc """
  Returns an audit log object for the guild. Requires the 'VIEW_AUDIT_LOG' permission.

  ## Options

  - `user_id` - filter the log for a user id
  - `action_type` - the type of audit log event
  - `before` - filter the log before a certain entry id
  - `limit` - how many entries are returned (default 50, minimum 1, maximum 100)
  """
  @spec get_guild_audit_log(Guild.id, [
    user_id: User.id,
    action_type: integer | AuditLog.event,
    before: integer,
    limit: 1..100]) :: t | Error.t
  def get_guild_audit_log(guild_id, opts \\ []) do
    opts = cond do
      Keyword.has_key?(opts, :action_type) ->
        cond do
          is_atom(opts.action_type) ->
            Keyword.update! opts, :action_type, &(event_codes()[&1])
          true -> opts
        end
      true -> opts
    end

    query = URI.encode_query(opts)
    Din.API.get "/guilds/#{guild_id}/audit-logs?#{query}"
  end
end