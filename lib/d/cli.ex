defmodule D.CLI do
  @drc_path Path.expand(Application.get_env(:d, :drc_path))

  def main(argv) do
    argv
    |> parse_args
    |> parse_config
    |> process
  end

  def parse_args(argv) do
    options = OptionParser.parse(argv, switches: [help: :boolean],
                                       aliases:  [h: :help])
    case options do
      {[help: true], _, _} -> :help
      {_, [term], _}       -> term
      _                    -> :help
    end
  end

  def parse_config(:help), do: :help
  def parse_config(term) do 
    {term, do_parse_config(@drc_path, File.exists?(@drc_path))}
  end

  def process(:help) do
    IO.puts """
      usage: d <word or term to define>
      """
  end

  def process({term, config}) do
    IO.puts "define #{term}"
    IO.puts "define #{inspect config}"
    # case File.read(filepath) do
    #   {:ok, data} -> IO.write data
    #   {:error, error} -> IO.puts "Error: #{:file.format_error(error)}"
    # end
  end

  defp do_parse_config(path, true) do
    {:ok, results} = ConfigParser.parse_file(path)
    results
  end
  defp do_parse_config(path, false) do
    content = """
      [merriam-webster]\napi_key = your-key-here\n
      [oxford]\napp_id = your-oxford-appid\napp_key = your-oxford-app_key\n
      """

    case File.write(path, content) do
      :ok -> 
        do_parse_config(path, true)

      {:error, message} -> 
        IO.puts(:stderr, message) && System.halt(2)
    end
  end
end
