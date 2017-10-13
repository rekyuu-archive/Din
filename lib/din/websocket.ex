defmodule Din.Websocket do
  use WebSockex
  require Logger

  def start_link(gateway_pid) do
    Logger.info "starting websocket"
    url = "wss://gateway.discord.gg/?v=6&encoding=json"
    WebSockex.start_link(url, __MODULE__, %{gateway: gateway_pid})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_connect(_conn, state) do
    Logger.debug "websocket connected"
    {:ok, state}
  end

  def handle_frame({:text, payload}, state) do
    message = payload |> Poison.Parser.parse!(keys: :atoms)
    send state[:gateway], {:gateway, message}

    {:ok, state}
  end

  def handle_frame(frame, state) do
    Logger.warn "unused frame: #{inspect frame}"
    {:ok, state}
  end

  def handle_cast({:close, code, reason}, state) do
    {:close, {code, reason}, state}
  end

  def handle_info({:ssl_closed, _payload}, state) do
    Logger.warn "socket closed: ssl_closed"
    {:close, {1001, "ssl closed"}, state}
  end

  def handle_disconnect(%{reason: {location, code}}, state) do
    Logger.warn "websocket closed by #{location} (#{code})"
    send state[:gateway], :reconnect

    {:ok, state}
  end
end
