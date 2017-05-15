defmodule D.Oxford do
  import Poison

  @user_agent [{"User-Agent", "Elixir samuel@pixelatedworks.com"}]
  @app_id "18240425"
  @app_key "024535080a538988affc8255309e3857"

  def fetch(term) do
    endpoint(term)
    |> HTTPoison.get(["Accept": "application/json", "app_id": @app_id, "app_key": @app_key], [ssl: [{:versions, [:'tlsv1.2']}]])
    |> handle_response
    |> format_response
  end

  def endpoint(term) do
    "https://od-api.oxforddictionaries.com/api/v1/entries/en/#{term}"
  end

  def handle_response({:ok, %{body: body, status_code: 200}}) do
    {:ok, body}
  end
  def handle_response({:error, %{status_code: _, reason: reason}}) do
    {:error, reason}
  end

  def format_response({:ok, body}) do
    body
    |> Poison.Parser.parse!
    |> Map.get("results")
    |> Enum.flat_map(&(Map.get(&1, "lexicalEntries")))
    |> lexical_entries
  end
  def format_response({:error, reason}), do: {:error, reason}

  defp lexical_entries(list) do
    Enum.flat_map(list, fn (item) -> entries_list(item["lexicalCategory"], item["entries"]) end)
  end
  defp entries_list(type, entries) do
    Enum.flat_map(entries, fn (entry) -> senses_list(type, entry["senses"]) end)
  end
  defp senses_list(type, senses) do
    Enum.map(senses, fn (sense) -> type_and_definition(type, hd(Map.get(sense, "definitions", ["unknown"]))) end)
  end
  defp type_and_definition(type, definition) do
    %{lexical_type: type, definition: definition}
  end
end
