defmodule Din do
  use Application
  use Supervisor
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec
    Logger.debug "starting supervisor"

    children = [worker(Din.Gateway, [])]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
