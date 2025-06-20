defmodule Pc3.Api do
  use Ash.Domain,
    extensions: [AshJsonApi.Domain]

  json_api do
    routes do
      # Add base_route for product resource
      base_route "/products", Pc3.Product do
        get(:read)
        index(:read)
        post(:create)
        patch(:update)
        delete(:destroy)
      end
    end
  end

  resources do
    resource(Pc3.Product)
  end
end
