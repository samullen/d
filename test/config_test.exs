defmodule ConfigTest do
  use ExUnit.Case

  import D.Config, only: [
    parse_args: 1, 
    parse_config: 1, 
  ]

  describe "parse_args/1" do
    test ":help returned by option parsing with -h and --help options" do
      assert parse_args(["-h", "anything"]) == :help
      assert parse_args(["--help", "anything"]) == :help
    end

    test "term and config returned when args provided" do
      assert parse_args(~w{example}) == %{"term" => "example"}
    end
  end

  describe "parse_config/1" do
    test ":help is returned when :help is passed" do
      assert parse_config(:help) == :help
    end

    test "passing term returns %{term: term, config}" do
      default_config = %{"dictionary_api_key" => "your-key-here", "thesaurus_api_key" => "your-key-here"}
      assert parse_config(%{"term" => "example"}) == Map.merge(%{"term" => "example"}, default_config)
    end

    test "it creates a .drc file in the configured drc path if nonexistent" do
      drc_path = Path.expand(Application.get_env(:d, :drc_path))
      File.rename(drc_path, "#{Path.dirname(drc_path)}/.drc_bak")

      parse_config(%{"term" => "example"})
      assert File.exists?(drc_path) == true

      File.rename("#{Path.dirname(drc_path)}/.drc_bak", drc_path)
    end

    test "it sets defaults for created .drc" do
      drc_path = Path.expand(Application.get_env(:d, :drc_path))
      File.rename(drc_path, "#{Path.dirname(drc_path)}/.drc_bak")
      default_config = """
        [config]
        dictionary_api_key = your-key-here
        thesaurus_api_key = your-key-here
        """

      parse_config(%{"term" => "example"})
      assert File.read(drc_path) == {:ok, default_config}

      File.rename("#{Path.dirname(drc_path)}/.drc_bak", drc_path)
    end
  end
end
