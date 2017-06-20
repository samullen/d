defmodule D.Dictionary do
  import SweetXml

  @user_agent [{"User-Agent", "Elixir samuel@samuelmullen.com"}]

  def fetch(config) do
    endpoint(config)
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> format_response(config)
  end

  def endpoint(config) do
    "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/#{config["term"]}?key=#{config["dictionary_api_key"]}"
  end

  def handle_response({:ok, %{body: body, status_code: 200}}) do
    {:ok, body}
  end
  def handle_response({:error, %{status_code: _, reason: reason}}) do
    {:error, reason}
  end

  def format_response({:error, reason}, config), do: {:error, reason}
  def format_response({:ok, body}, config) do
    body
    |> xpath(
      ~x{//entry_list/entry[starts-with(@id, "#{config["term"]}[")]}l,
      lexical_type: ~x{./fl/text()},
      definition: ~x{./def/dt/text()}l
    )
  end
end
