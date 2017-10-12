defmodule Din.API do
  @spec headers :: map
  def headers do
    %{
      "User-Agent"    => "Din (https://github.com/rekyuu/Din, v0.0.0)",
      "Authorization" => "Bot #{Application.get_env(:din, :discord_token)}"
    }
  end

  @spec get(String.t) :: map
  def get(url) do
    HTTPoison.get!(url, @headers)
    |> Poison.Parser.parse!(keys: :atoms)
    |> Map.fetch(:body)
  end
end
