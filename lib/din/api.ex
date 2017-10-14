defmodule Din.API do
  alias Din.Error

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
    |> parse()
  end

  @doc """
  POST to a given endpoint with supplied keyword list.
  """
  @spec post(String.t, list) :: map
  def post(endpoint, data \\ []) do
    url = "#{Din.discord_url}#{endpoint}"
    body = data
    |> Enum.into(%{})
    |> Poison.encode!

    HTTPoison.post!(url, body, Map.merge(headers(), %{"Content-Type" => "application/json"}))
    |> Map.fetch!(:body)
    |> parse()
  end

  @doc """
  POST a multipart to a given endpoint with supplied keyword list.
  """
  @spec multipart(String.t, list) :: map
  def multipart(endpoint, data) do
    url = "#{Din.discord_url}#{endpoint}"
    body = data
    |> Key.delete(:file)
    |> Enum.into(%{})
    |> Poison.encode!

    HTTPoison.post!(url, {:multipart, [{:file, data.file}, {:payload_json, body}]}, Map.merge(headers(), %{"Content-Type" => "multipart/form-data"}))
    |> Map.fetch!(:body)
    |> parse()
  end

  @doc """
  PATCH to a given endpoint with supplied keyword list.
  """
  @spec patch(String.t, list) :: map
  def patch(endpoint, data \\ []) do
    url = "#{Din.discord_url}#{endpoint}"
    body = data
    |> Enum.into(%{})
    |> Poison.encode!

    HTTPoison.patch!(url, body, Map.merge(headers(), %{"Content-Type" => "application/json"}))
    |> Map.fetch!(:body)
    |> parse()
  end

  @doc """
  PUT to a given endpoint with supplied keyword list.
  """
  @spec put(String.t, list) :: map
  def put(endpoint, data \\ []) do
    url = "#{Din.discord_url}#{endpoint}"
    body = data
    |> Enum.into(%{})
    |> Poison.encode!

    HTTPoison.put!(url, body, Map.merge(headers(), %{"Content-Type" => "application/json"}))
    |> Map.fetch!(:body)
    |> parse()
  end

  @doc """
  DELETE to a given endpoint.
  """
  @spec delete(String.t) :: map
  def delete(endpoint) do
    url = "#{Din.discord_url}#{endpoint}"

    HTTPoison.delete!(url, headers())
    |> Map.fetch!(:body)
    |> parse()
  end

  @doc """
  Returns Error structs, nil for no response endpoints, or the map of the returned data.
  """
  @spec parse(map) :: map | Error.t | nil
  def parse(map) do
    case map do
      "" -> nil
      map ->
        case map |> Poison.Parser.parse!(keys: :atoms) do
          %{code: code, message: message} ->
            struct(Error, Poison.Parser.parse!(map, keys: :atoms))
          map -> map
        end
    end
  end
end
