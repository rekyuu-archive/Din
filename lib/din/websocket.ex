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
    send self, :identify
    send self, {:heartbeat, payload.heartbeat_interval, nil}

    {:noreply, state}
  end

  def handle_info({:gateway, %{op: 11}}, state) do
    Logger.debug "heartbeat ack"
    {:noreply, state}
  end

  def handle_info({:gateway, %{d: payload, op: op}}, state) do
    Logger.debug "op #{op}"
  end

  def handle_info(:identify, state) do
    Logger.debug "identifying"
    payload = %{
      token: Application.get_env(:din, :discord_token),
      properties: %{
        "$os": "elixir",
        "$browser": "din",
        "$device": "din"
      },
      compress: false,
      large_threshold: 250
    }

    Socket.Web.send! state[:conn], {:text, Poison.encode!(%{op: 2, d: payload})}
    {:noreply, state}
  end

  def handle_info({:heartbeat, heartbeat_interval, sequence}, state) do
    Logger.debug "sending heartbeat #{sequence}"
    Socket.Web.send! state[:conn], {:text, Poison.encode!(%{op: 1, d: sequence})}

    sequence = case sequence do
      nil -> 0
      sequence -> sequence
    end

    :erlang.send_after(heartbeat_interval, self, {:heartbeat, heartbeat_interval, sequence + 1})
    {:noreply, state}
  end
end
