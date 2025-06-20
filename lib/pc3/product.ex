defmodule Pc3.Product do
  @moduledoc """
  Product resource representing items in the inventory.

  Uses CSV data layer for persistence with support for JSON API.

  ## Business Actions

  - `purchase/2` - Purchase items from stock with quantity validation
  - `restock/2` - Add items to stock
  - `adjust_price/2` - Update product pricing with optional reason

  ## Validations

  - Price must be greater than 0
  - Stock cannot be negative
  - Name must be between 1-255 characters
  - Name cannot start/end with whitespace
  - Description limited to 1000 characters
  """

  use Ash.Resource,
    domain: Pc3.Api,
    data_layer: AshCsv.DataLayer,
    extensions: [AshJsonApi.Resource]

  json_api do
    type("product")
  end

  csv do
    file("priv/data/products.csv")
    create?(true)
    header?(true)
    columns([:id, :name, :description, :price, :stock])
  end

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :description, :string do
      public?(true)
    end

    attribute :price, :decimal do
      allow_nil?(false)
      public?(true)
    end

    attribute :stock, :integer do
      allow_nil?(false)
      default(0)
      public?(true)
    end
  end

  validations do
    validate compare(:price, greater_than: 0) do
      message("Price must be greater than 0")
    end

    validate compare(:stock, greater_than_or_equal_to: 0) do
      message("Stock cannot be negative")
    end

    validate string_length(:name, min: 1, max: 255) do
      message("Name must be between 1 and 255 characters")
    end

    validate string_length(:description, max: 1000) do
      message("Description cannot exceed 1000 characters")
    end

    validate match(:name, ~r/^[^\s].*[^\s]$/) do
      message("Name cannot start or end with whitespace")
    end
  end

  calculations do
    calculate(:in_stock?, :boolean, expr(stock > 0))
    calculate(:low_stock?, :boolean, expr(stock > 0 and stock <= 10))
    calculate(:formatted_price, :string, expr(fragment("'$' || CAST(? AS TEXT)", price)))
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      primary?(true)
      accept([:name, :description, :price, :stock])
    end

    update :update do
      primary?(true)
      accept([:name, :description, :price, :stock])
    end

    update :purchase do
      accept([])

      argument :quantity, :integer do
        allow_nil?(false)
        constraints(min: 1)
      end

      validate compare(:stock, greater_than_or_equal_to: arg(:quantity)) do
        message("Insufficient stock. Only %{stock} items available.")
      end

      change(set_attribute(:stock, expr(stock - ^arg(:quantity))))
    end

    update :restock do
      accept([])

      argument :quantity, :integer do
        allow_nil?(false)
        constraints(min: 1)
      end

      change(set_attribute(:stock, expr(stock + ^arg(:quantity))))
    end

    update :adjust_price do
      accept([])

      argument :new_price, :decimal do
        allow_nil?(false)
        constraints(min: 0)
      end

      argument :reason, :string do
        allow_nil?(true)
      end

      validate compare(arg(:new_price), greater_than: 0) do
        message("New price must be greater than 0")
      end

      change(set_attribute(:price, arg(:new_price)))
    end

    read :low_stock do
      filter(expr(stock > 0 and stock <= 10))
    end

    read :out_of_stock do
      filter(expr(stock == 0))
    end
  end
end
