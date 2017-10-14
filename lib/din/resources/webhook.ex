defmodule Din.Resources.Webhook do
  alias Din.Error

  @moduledoc """
  Webhooks are a low-effort way to post messages to channels in Discord. They do not require a bot user or authentication to use.
  """

  @doc """
  Create a new webhook. Returns a webhook object on success.

  ## Parameters

  - `name` - name of the webhook (2-32 characters)
  - `avatar` - image for the default webhook avatar
  """
  @spec create(Din.snowflake, [
    name: String.t,
    avatar: binary
  ]) :: map | Error.t
  def create(channel_id, opts \\ []) do
    Din.API.post "/channels/#{channel_id}/webhooks", opts
  end

  @doc """
  Returns a list of channel webhook objects.
  """
  @spec get_channel_webhooks(Din.snowflake) :: list(map) | Error.t
  def get_channel_webhooks(channel_id) do
    Din.API.get "/channels/#{channel_id}/webhooks"
  end

  @doc """
  Returns a list of guild webhook objects.
  """
  @spec get_guild_webhooks(Din.snowflake) :: list(map) | Error.t
  def get_guild_webhooks(guild_id) do
    Din.API.get "/guilds/#{guild_id}/webhooks"
  end

  @doc """
  Returns the new webhook object for the given id.
  """
  @spec get(Din.snowflake) :: map | Error.t
  def get(webhook_id) do
    Din.API.get "/webhooks/#{webhook_id}"
  end

  @doc """
  Same as get/1, except this call does not require authentication and returns no user in the webhook object.
  """
  @spec get_with_token(Din.snowflake, String.t) :: map | Error.t
  def get_with_token(webhook_id, webhook_token) do
    Din.API.get "/webhooks/#{webhook_id}/#{webhook_token}"
  end

  @doc """
  Modify a webhook. Returns the updated webhook object on success.

  ## Parameters

  - `name` - the default name of the webhook
  - `avatar` - image for the default webhook avatar
  - `channel_id` - the new channel id this webhook should be moved to
  """
  @spec modify(Din.snowflake, [
    name: String.t,
    avatar: binary,
    channel_id: Din.snowflake
  ]) :: map | Error.t
  def modify(webhook_id, opts \\ []) do
    Din.API.patch "/webhooks/#{webhook_id}", opts
  end

  @doc """
  Same as modify/2, except this call does not require authentication, does not accept a channel_id parameter in the body, and does not return a user in the webhook object.
  """
  @spec modify_with_token(Din.snowflake, String.t, [
    name: String.t,
    avatar: binary,
  ]) :: map | Error.t
  def modify_with_token(webhook_id, webhook_token, opts \\ []) do
    Din.API.patch "/webhooks/#{webhook_id}/#{webhook_token}", opts
  end

  @doc """
  Delete a webhook permanently. User must be owner. Returns a 204 NO CONTENT response on success.
  """
  @spec delete(Din.snowflake) :: nil | Error.t
  def delete(webhook_id) do
    Din.API.delete "/webhooks/#{webhook_id}"
  end

  @doc """
  Same as delete/1, except this call does not require authentication.
  """
  @spec delete_with_token(Din.snowflake, String.t) :: nil | Error.t
  def delete_with_token(webhook_id, webhook_token) do
    Din.API.delete "/webhooks/#{webhook_id}/#{webhook_token}"
  end

  @doc """
  Sends a message via webhook. You must have ONE of either `content`, `file`, or `embeds`

  ## Parameters

  - `wait` - waits for server confirmation of message send before response, and returns the created message body (defaults to `false`; when `false` a message that is not saved does not return an error)
  - `content` - the message contents (up to 2000 characters)
  - `username` - override the default username of the webhook
  - `avatar_url` - override the default avatar of the webhook
  - `tts` - true if this is a TTS message
  - `file` - the contents of the file being sent
  - `embeds` - embedded rich content
  """
  @spec execute(Din.snowflake, String.t, [
    wait: boolean,
    content: String.t,
    username: String.t,
    avatar_url: String.t,
    tts: boolean,
    file: binary,
    embeds: list(map)
  ]) :: map | Error.t
  def execute(webhook_id, webhook_token, opts \\ []) do
    endpoint = "/webhooks/#{webhook_id}/#{webhook_token}?#{URI.encode_query opts.wait}"
    data = opts |> Keyword.delete(:wait)

    case Keyword.has_key?(data, :file) do
      true -> Din.API.multipart endpoint, data
      false -> Din.API.post endpoint, data
    end
  end

  @doc """
  Refer to [Slack's documentation](https://api.slack.com/incoming-webhooks) for more information. Discord does not support Slack's channel, icon_emoji, mrkdwn, or mrkdwn_in properties.

  ## Parameters

  - `wait` - waits for server confirmation of message send before response, and returns the created message body (defaults to `false`; when `false` a message that is not saved does not return an error)
  """
  @spec execute_slack(Din.snowflake, String.t, [
    wait: boolean
  ]) :: map | Error.t
  def execute_slack(webhook_id, webhook_token, opts \\ []) do
    Din.API.post "/webhooks/#{webhook_id}/#{webhook_token}/slack?#{URI.encode_query opts.wait}"
  end

  @doc """
  Add a new webhook to your GitHub repo (in the repo's settings), and use this endpoint as the "Payload URL." You can choose what events your Discord channel receives by choosing the "Let me select individual events" option and selecting individual events for the new webhook you're configuring.

  ## Parameters

  - `wait` - waits for server confirmation of message send before response, and returns the created message body (defaults to `false`; when `false` a message that is not saved does not return an error)
  """
  @spec execute_github(Din.snowflake, String.t, [
    wait: boolean
  ]) :: map | Error.t
  def execute_github(webhook_id, webhook_token, opts \\ []) do
    Din.API.post "/webhooks/#{webhook_id}/#{webhook_token}/github?#{URI.encode_query opts.wait}"
  end
end
