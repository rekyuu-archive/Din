defmodule Din do
  @doc """
  Din is a Discord wrapper for Elixir. It's focused around simplicity and makes sure to actually reconnect when a connection or heartbeat drops.

  Usage is simple. Include Din in your dependencies and start it from your supervisor.

  ## Example

  ```Elixir
  defmodule YourApplication.YourModule do
    use Din.Module
    alias Din.Resources.Channel

    handle :message_create do
      if data.content == "!ping" do
        Channel.create_message(data.channel_id, "Pong!")
      end
    end

    # Fallback for unused events
    handle _event, do: nil
  end
  ```
  """

  @typedoc "64-bit string IDs"
  @type snowflake :: String.t

  @typedoc "base url for Discord's HTTP API"
  @spec discord_url :: String.t
  def discord_url, do: "https://discordapp.com/api/v6"
end
