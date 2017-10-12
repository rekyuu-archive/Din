defmodule Din.Websocket do
  use GenServer
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    Logger.info "Connecting websocket..."

    url = "gateway.discord.gg"
    path = "/?v=6&encoding=json"
    conn = Socket.Web.connect! url, path: path, secure: true
    send self, {:receive, conn}

    {:ok, []}
  end

  def handle_info({:receive, conn}, state) do
    response = Socket.Web.recv!(conn)
    IO.inspect response
    :erlang.send_after(100, self, {:receive, conn})

    {:noreply, state}
  end
end
