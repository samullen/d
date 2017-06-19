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

  def process({term, config}) do
    results = [&D.Oxford.fetch/1,&D.MerriamWebster.fetch/1]
    |> Enum.map(&(Task.async(fn -> &1.(term) end)))
    |> Task.yield_many(5000)
    |> Enum.map(fn {task, result} -> 
         result || Task.shutdown(task, :brutal_kill) 
       end)
    |> Enum.flat_map(fn {:ok, value} -> value; _ -> [] end)
    |> Enum.each(fn item -> IO.puts format_item(item) end)
  end

  def format_item(item) do
    "Type: #{item.lexical_type}\nDefinition: #{item.definition}\n\n"
  end
end
