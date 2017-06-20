defmodule D.CLI do
  def main(argv) do
    argv
    |> D.Config.setup
    |> process
  end

  def process(:help) do
    IO.puts """
      usage: d <word or term to define>
      """
  end

  def process(config) do
    results = [&D.Dictionary.fetch/1,&D.Thesaurus.fetch/1]
    |> Enum.map(&(Task.async(fn -> &1.(config) end)))
    |> Task.yield_many(5000)
    |> Enum.map(fn {task, result} -> 
         result || Task.shutdown(task, :brutal_kill) 
       end)
    |> Enum.flat_map(fn {:ok, value} -> value; _ -> [] end)
    |> Enum.each(fn item -> IO.puts format_item(item) end)
  end

  def format_item(%{lexical_type: lexical_type, definition: definitions}) do
    """
    Type: #{lexical_type}
    Definition(s): 
      #{Enum.join(definitions, "\n  ")}
    """
  end
  def format_item(%{lexical_type: lexical_type, senses: senses}) do
    Enum.map(senses, fn(sense) ->
      """
      #{lexical_type}: #{sense.sense}
        Synonyms: #{sense.synonyms}
        Antonyms: #{sense.antonyms}
      """
    end)
    |> Enum.join("\n")

  end
end
