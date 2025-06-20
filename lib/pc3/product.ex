defmodule Pc3.Product do
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
  end
end
