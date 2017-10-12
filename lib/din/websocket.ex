defmodule Din.Websocket do
  use WebSockex
  require Logger

  def start_link(opts \\ []) do
    Logger.info "Connecting websocket..."

    url = "wss://gateway.discord.gg/?v=6&encoding=json"
    WebSockex.start_link(url, __MODULE__, [], insecure: false)
  end

  def handle_frame({type, msg}, state) do
    Logger.debug "[recv] #{type}: #{msg}"
    {:ok, state}
  end
end
