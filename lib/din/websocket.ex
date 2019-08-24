defmodule Din.Websocket do
  use WebSockex
  require Logger

  @doc """
  Starts the websocket from the Gateway.
  """
  def start_link(gateway_pid) do
    Logger.info "starting websocket"
    url = "wss://gateway.discord.gg/?v=6&encoding=json"
    WebSockex.start_link(url, __MODULE__, %{gateway: gateway_pid})
  end

  def init(state) do
    Logger.info "websocket initialized"
    {:ok, state}
  end

  @doc """
  Handler for websocket connections.
  """
  def handle_connect(_conn, state) do
    Logger.debug "websocket connected"
    {:ok, state}
  end

  @doc """
  Handler for `:text` frames.

  This will send the message to the Gateway supervisor for matching.
  """
  def handle_frame({:text, payload}, state) do
    Logger.debug "payload received"

    message = payload |> Poison.Parser.parse!(keys: :atoms)
    send state[:gateway], {:gateway, message}

    {:ok, state}
  end

  @doc """
  Fallback for unexpected frames.
  """
  def handle_frame(frame, state) do
    Logger.warn "unused frame: #{inspect frame}"
    {:ok, state}
  end

  @doc """
  Handler to close the websocket from the Gateway supervisor.
  """
  def handle_cast({:close, code, reason}, state) do
    Logger.warn "closed: #{reason} [#{code}]"
    {:close, {code, reason}, state}
  end

  @doc """
  Fallback for SSL errors that result in a closed websocket.
  """
  def handle_info({:ssl_closed, _payload}, state) do
    Logger.warn "socket closed: ssl_closed"
    {:close, {1001, "ssl closed"}, state}
  end

  @doc """
  Handler for websocket disconnects, local or remote.

  Will output the disonnect code to the console.
  """
  def handle_disconnect(%{reason: {location, code, _reason}}, state) do
    Logger.warn "websocket closed by #{location} (#{code})"
    send state[:gateway], :reconnect

    {:ok, state}
  end
end
