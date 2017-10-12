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
    response = state[:conn]
    |> Socket.Web.recv!
    |> Poison.Parser.parse(keys: :atoms)

    IO.inspect response
    :erlang.send_after(100, self, :receive)

    {:noreply, state}
  end
end
