defmodule Din.API do
  @moduledoc """
  REST calls for Discord HTTP API.
  """

  @doc """
  Defines headers for each call.
  """
  @spec headers :: map
  def headers do
    %{
      "User-Agent"    => "Din (https://github.com/rekyuu/Din, v0.0.0)",
      "Authorization" => "Bot #{Application.get_env(:din, :discord_token)}"
    }
  end

  @doc """
  GET from given endpoint.
  """
  @spec get(String.t) :: map
  def get(endpoint) do
    url = "#{Din.discord_url}#{endpoint}"

    HTTPoison.get!(url, headers())
    |> Map.fetch!(:body)
    |> Poison.Parser.parse!(keys: :atoms)
  end

  @doc """
  POST to a given endpoint with supplied keyword list.
  """
  @spec post(String.t, list) :: map
  def post(endpoint, data) do
    url = "#{Din.discord_url}#{endpoint}"
    body = data
    |> Enum.into(%{})
    |> Poison.encode!

    HTTPoison.post!(url, body, headers())
    |> Map.fetch!(:body)
    |> Poison.Parser.parse!(keys: :atoms)
  end

  @doc """
  POST a multipart to a given endpoint with supplied keyword list.
  """
  @spec multipart(String.t, list) :: map
  def multipart(endpoint, data) do
    url = "#{Din.discord_url}#{endpoint}"
    body = data
    |> Enum.into(%{})
    |> Poison.encode!

    HTTPoison.post!(url, {:multipart, body}, headers())
    |> Map.fetch!(:body)
    |> Poison.Parser.parse!(keys: :atoms)
  end

  @doc """
  PATCH to a given endpoint with supplied keyword list.
  """
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

  @doc """
  DELETE to a given endpoint.
  """
  @spec delete(String.t) :: map
  def delete(endpoint) do
    url = "#{Din.discord_url}#{endpoint}"

    HTTPoison.delete!(url, headers())
    |> Map.fetch!(:body)
    |> Poison.Parser.parse!(keys: :atoms)
  end
end
