defmodule Mix.Tasks.Openapi.Gen do
  @moduledoc """
  Generates OpenAPI specification files for the API.

  ## Usage

      mix openapi.gen

  This will generate both JSON and YAML versions of the OpenAPI spec.
  """
  use Mix.Task

  @shortdoc "Generate OpenAPI specification files"
  def run(_args) do
    Mix.Task.run("app.start")

    IO.puts("Generating OpenAPI specification files...")

    # Generate JSON spec
    Mix.Task.run("openapi.spec.json", ["--spec", "Pc3Web.ApiRouter"])

    IO.puts("OpenAPI spec files generated successfully!")
    IO.puts("  - JSON: priv/static/open_api.json")
    IO.puts("")
    IO.puts("You can view the API documentation at:")
    IO.puts("  - Swagger UI: http://localhost:4000/api/swaggerui")
    IO.puts("  - Redoc: http://localhost:4000/api/redoc")
  end
end
