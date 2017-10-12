defmodule Din.Websocket do
  use GenServer
  require Logger

  @gateway "gateway.discord.gg"

  def start_link do
    Logger.info "Connecting websocket..."
    url = "gateway.discord.gg"
    path = "/?v=6&encoding=json"
    conn = Socket.Web.connect! url, path: path, secure: true

    GenServer.start_link(__MODULE__, %{conn: conn})
  end

  def init(state) do
    send self, :receive
    {:ok, state}
  end

  def handle_info(:receive, state) do
    case Socket.Web.recv!(state[:conn]) do
      {:text, message} ->
        message = message |> Poison.Parser.parse!(keys: :atoms)
        send self, {:gateway, message}
      {:close, :normal, _reason} -> Logger.warn "websocket closed"
      _ -> nil
    end

    :erlang.send_after(100, self, :receive)
    {:noreply, state}
  end

  def handle_info({:gateway, %{d: payload, op: 10}}, state) do
    Logger.debug "hello"
    {:noreply, state}
  end
end
