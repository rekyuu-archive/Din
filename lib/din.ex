defmodule Din do
  @typedoc "64-bit string IDs"
  @type snowflake :: String.t

  @spec discord_url :: String.t
  def discord_url, do: "https://discordapp.com/api/v6"
end
