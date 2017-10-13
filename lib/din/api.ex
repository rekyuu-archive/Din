defmodule Din.API do
  @spec headers :: map
  def headers do
    %{
      "User-Agent"    => "Din (https://github.com/rekyuu/Din, v0.0.0)",
      "Authorization" => "Bot #{Application.get_env(:din, :discord_token)}"
    }
  end

  @spec get(String.t) :: map
  def get(endpoint) do
    url = "#{Din.discord_url}#{endpoint}"

    HTTPoison.get!(url, headers())
    |> Map.fetch!(:body)
    |> Poison.Parser.parse!(keys: :atoms)
  end

  @spec patch(String.t, list) :: map
  def patch(endpoint, data) do
    url = "#{Din.discord_url}#{endpoint}"
    body = data
    |> Enum.into(%{})
    |> Poison.encode!

    HTTPoison.patch!(url, body, headers())
    |> Map.fetch!(:body)
    |> Poison.Parser.parse!(keys: :atoms)
  end
end
