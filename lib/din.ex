defmodule Din do
  use Application
  use Supervisor
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec
    Logger.info "Starting supervisor..."

    children = [worker(Din.Websocket, [])]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
