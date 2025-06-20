defmodule Pc3Web.ApiRouter do
  use AshJsonApi.Router,
    domains: [Pc3.Api],
    open_api: "/open_api",
    phoenix_endpoint: Pc3Web.Endpoint,
    modify_open_api: {__MODULE__, :modify_open_api, []}

  def modify_open_api(spec, _, _) do
    %{
      spec
      | info: %{
          spec.info
          | title: "PC3 API",
            version: "1.0.0",
            description: "JSON API for managing products"
        }
    }
  end
end
