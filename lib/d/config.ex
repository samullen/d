defmodule D.Config do
  @drc_path Path.expand(Application.get_env(:d, :drc_path))

  def setup(argv) do
    argv
    |> parse_args
    |> parse_config
  end

  def parse_args(argv) do
    options = OptionParser.parse(argv, switches: [help: :boolean],
                                       aliases:  [h: :help])
    case options do
      {[help: true], _, _} -> :help
      {_, [term], _}       -> %{term: term}
      _                    -> :help
    end
  end

  def parse_config(:help), do: :help
  def parse_config(term) do 
    Map.merge(term, do_parse_config(File.exists?(@drc_path)))
  end

  defp do_parse_config(true) do
    {:ok, results} = ConfigParser.parse_file(@drc_path)
    results
  end
  defp do_parse_config(false) do
    content = """
      [config]
      dictionary_api_key = your-key-here
      thesaurus_api_key = your-key-here
      """

    case File.write(@drc_path, content) do
      :ok -> 
        do_parse_config(true)

      {:error, message} -> 
        IO.puts(:stderr, message) && System.halt(2)
    end
  end
end
