defmodule D.MerriamWebster do
  import SweetXml

  @user_agent [{"User-Agent", "Elixir samuel@pixelatedworks.com"}]
  @api_key "81aae390-fc77-47a9-b990-d151db3ef918"

  def fetch(term) do
    endpoint(term)
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> format_response
  end

  def endpoint(term) do
    "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/#{term}?key=#{@api_key}"
  end

  def handle_response({:ok, %{body: body, status_code: 200}}) do
    {:ok, body}
  end
  def handle_response({:error, %{status_code: _, reason: reason}}) do
    {:error, reason}
  end

  def format_response({:error, reason}), do: {:error, reason}
  def format_response({:ok, body}) do
    body
    |> xpath(
      ~x{//entry_list/entry}l, 
      description: ~x{./fl/text()},
      definition: ~x{./def/dt/text()}l
    )
  end
end
