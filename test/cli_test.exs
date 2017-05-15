defmodule CliTest do
  use ExUnit.Case
  doctest D

  import D.CLI, only: [parse_args: 1, parse_config: 1]

  describe "parse_args/1" do
    test ":help returned by option parsing with -h and --help options" do
      assert parse_args(["-h", "anything"]) == :help
      assert parse_args(["--help", "anything"]) == :help
    end

    test "term and config returned when args provided" do
      assert parse_args(~w{example}) == "example"
    end
  end

  describe "parse_config/1" do
    test ":help is returned when :help is passed" do
      assert parse_config(:help) == :help
    end

    test "passing term returns {term, %{config}" do
      default_config = %{"merriam-webster" => %{"api_key" => "your-key-here"}, "oxford" => %{"app_id" => "your-oxford-appid", "app_key" => "your-oxford-app_key"}}
      assert parse_config("example") == {"example", default_config}
    end

    test "it creates a .drc file in the configured drc path if nonexistent" do
      drc_path = Path.expand(Application.get_env(:d, :drc_path))
      File.rename(drc_path, "#{Path.dirname(drc_path)}/.drc_bak")

      parse_config(:list)
      assert File.exists?(drc_path) == true

      File.rename("#{Path.dirname(drc_path)}/.drc_bak", drc_path)
    end

    test "it sets defaults for created .drc" do
      drc_path = Path.expand(Application.get_env(:d, :drc_path))
      File.rename(drc_path, "#{Path.dirname(drc_path)}/.drc_bak")
      default_config = """
        [merriam-webster]\napi_key = your-key-here\n
        [oxford]\napp_id = your-oxford-appid\napp_key = your-oxford-app_key\n
        """

      parse_config("example")
      assert File.read(drc_path) == {:ok, default_config}

      File.rename("#{Path.dirname(drc_path)}/.drc_bak", drc_path)
    end
  end
end
