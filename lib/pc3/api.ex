defmodule Pc3.Api do
  @moduledoc """
  The main API domain for the product management system.

  Provides JSON API endpoints for product operations including:
  - Standard CRUD operations
  - Business logic actions (purchase, restock, price adjustments)
  - Filtered queries (low stock, out of stock)

  All endpoints follow JSON API specification and include OpenAPI documentation.
  """

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

        # Business logic actions
        patch(:purchase, route: "/purchase")
        patch(:restock, route: "/restock")
        patch(:adjust_price, route: "/adjust_price")

        # Custom read actions
        get(:low_stock, route: "/low_stock")
        get(:out_of_stock, route: "/out_of_stock")
      end
    end
  end

  resources do
    resource(Pc3.Product)
  end
end
