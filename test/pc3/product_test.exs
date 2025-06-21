defmodule Pc3.ProductTest do
  use Pc3.DataCase, async: true

  alias Pc3.Product

  describe "validations" do
    test "price must be greater than 0" do
      {:error, changeset} =
        Ash.create(Product, %{
          name: "Test Product",
          price: 0,
          stock: 10
        })

      assert %{price: ["Price must be greater than 0"]} = changeset.errors |> errors_to_map()
    end

    test "stock cannot be negative" do
      {:error, changeset} =
        Ash.create(Product, %{
          name: "Test Product",
          price: 10.00,
          stock: -5
        })

      assert %{stock: ["Stock cannot be negative"]} = changeset.errors |> errors_to_map()
    end

    test "name is required" do
      {:error, changeset} =
        Ash.create(Product, %{
          price: 10.00,
          stock: 10
        })

      errors = changeset.errors |> errors_to_map()
      assert errors[:name] == ["is required"]
    end

    test "name cannot exceed 255 characters" do
      long_name = String.duplicate("a", 256)

      {:error, changeset} =
        Ash.create(Product, %{
          name: long_name,
          price: 10.00,
          stock: 10
        })

      errors = changeset.errors |> errors_to_map()
      assert %{name: ["Name must be between 1 and 255 characters"]} = errors
    end

    test "name cannot start or end with whitespace" do
      # Test with leading whitespace
      {:error, changeset1} =
        Ash.create(Product, %{
          name: " Test",
          price: 10.00,
          stock: 10
        })

      errors1 = changeset1.errors |> errors_to_map()
      assert errors1[:name] != nil

      # Test with trailing whitespace
      {:error, changeset2} =
        Ash.create(Product, %{
          name: "Test ",
          price: 10.00,
          stock: 10
        })

      errors2 = changeset2.errors |> errors_to_map()
      assert errors2[:name] != nil
    end

    test "description cannot exceed 1000 characters" do
      long_description = String.duplicate("a", 1001)

      {:error, changeset} =
        Ash.create(Product, %{
          name: "Test Product",
          description: long_description,
          price: 10.00,
          stock: 10
        })

      assert %{description: ["Description cannot exceed 1000 characters"]} =
               changeset.errors |> errors_to_map()
    end
  end

  describe "create product" do
    test "creates a product with valid attributes" do
      assert {:ok, product} =
               Ash.create(Product, %{
                 name: "Valid Product",
                 description: "A test product",
                 price: 19.99,
                 stock: 100
               })

      assert product.name == "Valid Product"
      assert product.description == "A test product"
      assert Decimal.equal?(product.price, Decimal.new("19.99"))
      assert product.stock == 100
    end

    test "creates a product with default stock of 0" do
      assert {:ok, product} =
               Ash.create(Product, %{
                 name: "No Stock Product",
                 price: 5.00
               })

      assert product.stock == 0
    end
  end

  describe "purchase action" do
    setup do
      {:ok, product} =
        Ash.create(Product, %{
          name: "Test Product",
          price: 10.00,
          stock: 50
        })

      {:ok, product: product}
    end

    test "successful purchase reduces stock", %{product: product} do
      assert {:ok, updated} =
               product
               |> Ash.Changeset.for_update(:purchase, %{quantity: 5})
               |> Ash.update()

      assert updated.stock == 45
    end

    test "purchase fails with insufficient stock", %{product: product} do
      assert {:error, changeset} =
               product
               |> Ash.Changeset.for_update(:purchase, %{quantity: 51})
               |> Ash.update()

      errors = changeset.errors |> errors_to_map()
      # Check that there's an error about insufficient stock
      assert errors[:stock] != nil
      [error | _] = errors[:stock]
      assert error =~ "Insufficient stock"
    end

    test "purchase requires quantity greater than 0", %{product: product} do
      assert {:error, changeset} =
               product
               |> Ash.Changeset.for_update(:purchase, %{quantity: 0})
               |> Ash.update()

      errors = changeset.errors |> errors_to_map()
      assert errors[:quantity] != nil
    end
  end

  describe "restock action" do
    setup do
      {:ok, product} =
        Ash.create(Product, %{
          name: "Test Product",
          price: 10.00,
          stock: 10
        })

      {:ok, product: product}
    end

    test "successful restock increases stock", %{product: product} do
      assert {:ok, updated} =
               product
               |> Ash.Changeset.for_update(:restock, %{quantity: 20})
               |> Ash.update()

      assert updated.stock == 30
    end

    test "restock requires quantity greater than 0", %{product: product} do
      assert {:error, changeset} =
               product
               |> Ash.Changeset.for_update(:restock, %{quantity: 0})
               |> Ash.update()

      errors = changeset.errors |> errors_to_map()
      assert errors[:quantity] != nil
    end
  end

  describe "adjust_price action" do
    setup do
      {:ok, product} =
        Ash.create(Product, %{
          name: "Test Product",
          price: 10.00,
          stock: 10
        })

      {:ok, product: product}
    end

    test "successful price adjustment", %{product: product} do
      assert {:ok, updated} =
               product
               |> Ash.Changeset.for_update(:adjust_price, %{new_price: "15.99"})
               |> Ash.update()

      assert Decimal.equal?(updated.price, Decimal.new("15.99"))
    end

    test "price adjustment with reason", %{product: product} do
      assert {:ok, updated} =
               product
               |> Ash.Changeset.for_update(:adjust_price, %{
                 new_price: "8.00",
                 reason: "Holiday sale"
               })
               |> Ash.update()

      assert Decimal.equal?(updated.price, Decimal.new("8.00"))
    end

    test "price adjustment fails with zero price", %{product: product} do
      assert {:error, changeset} =
               product
               |> Ash.Changeset.for_update(:adjust_price, %{new_price: 0})
               |> Ash.update()

      errors = changeset.errors |> errors_to_map()
      # The validation error should be present
      assert errors != %{}
      # Check if the error message contains the expected text
      error_messages = errors |> Map.values() |> List.flatten() |> Enum.join(" ")
      assert error_messages =~ "must be more than"
    end
  end

  describe "calculations" do
    test "in_stock? calculation" do
      {:ok, in_stock} = Ash.create(Product, %{name: "In Stock", price: 10.00, stock: 15})
      {:ok, out_of_stock} = Ash.create(Product, %{name: "Out of Stock", price: 10.00, stock: 0})

      in_stock_loaded = Ash.load!(in_stock, :in_stock?)
      out_of_stock_loaded = Ash.load!(out_of_stock, :in_stock?)

      assert in_stock_loaded.in_stock? == true
      assert out_of_stock_loaded.in_stock? == false
    end

    test "low_stock? calculation" do
      {:ok, low} = Ash.create(Product, %{name: "Low Stock", price: 10.00, stock: 5})
      {:ok, normal} = Ash.create(Product, %{name: "Normal Stock", price: 10.00, stock: 50})
      {:ok, out} = Ash.create(Product, %{name: "Out of Stock", price: 10.00, stock: 0})

      low_loaded = Ash.load!(low, :low_stock?)
      normal_loaded = Ash.load!(normal, :low_stock?)
      out_loaded = Ash.load!(out, :low_stock?)

      assert low_loaded.low_stock? == true
      assert normal_loaded.low_stock? == false
      assert out_loaded.low_stock? == false
    end
  end

  describe "read actions" do
    setup do
      products = [
        %{name: "Low Stock 1", price: 10.00, stock: 5},
        %{name: "Low Stock 2", price: 15.00, stock: 10},
        %{name: "Out of Stock", price: 20.00, stock: 0},
        %{name: "Normal Stock", price: 25.00, stock: 100}
      ]

      created =
        Enum.map(products, fn attrs ->
          {:ok, product} = Ash.create(Product, attrs)
          product
        end)

      {:ok, products: created}
    end

    test "low_stock read action filters correctly", %{products: products} do
      {:ok, results} = Ash.read(Product, action: :low_stock)

      # Get the IDs of our test products that should be in low stock
      low_stock_ids =
        products
        |> Enum.filter(fn p -> p.stock > 0 and p.stock <= 10 end)
        |> Enum.map(& &1.id)

      # Verify our test products are in the results
      result_ids = Enum.map(results, & &1.id)
      assert Enum.all?(low_stock_ids, fn id -> id in result_ids end)

      # Verify all results match the low stock criteria
      assert Enum.all?(results, fn p -> p.stock > 0 and p.stock <= 10 end)
    end

    test "out_of_stock read action filters correctly", %{products: products} do
      {:ok, results} = Ash.read(Product, action: :out_of_stock)

      # Get the IDs of our test products that should be out of stock
      out_of_stock_ids =
        products
        |> Enum.filter(fn p -> p.stock == 0 end)
        |> Enum.map(& &1.id)

      # Verify our test products are in the results
      result_ids = Enum.map(results, & &1.id)
      assert Enum.all?(out_of_stock_ids, fn id -> id in result_ids end)

      # Verify all results have zero stock
      assert Enum.all?(results, fn p -> p.stock == 0 end)
    end
  end

  # Helper function to convert errors to a map for easier assertion
  defp errors_to_map(errors) do
    errors
    |> Enum.map(fn error ->
      field =
        case error do
          %{field: f} when not is_nil(f) -> f
          %{fields: [f | _]} when not is_nil(f) -> f
          %{path: [f | _]} -> f
          _ -> :validation
        end

      message =
        case error do
          %{message: msg} -> msg
          %Ash.Error.Changes.Required{} -> "is required"
          _ -> inspect(error)
        end

      {field, message}
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end
end
