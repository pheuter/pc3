defmodule Pc3Web.ProductController do
  use Pc3Web, :controller

  action_fallback Pc3Web.FallbackController

  def index(conn, _params) do
    case Ash.read(Pc3.Product) do
      {:ok, products} ->
        json(conn, %{data: Enum.map(products, &product_json/1)})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to fetch products"})
    end
  end

  def show(conn, %{"id" => id}) do
    case Ash.get(Pc3.Product, id) do
      {:ok, product} ->
        json(conn, %{data: product_json(product)})

      {:error, %Ash.Error.Query.NotFound{}} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Product not found"})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to fetch product"})
    end
  end

  def create(conn, %{"product" => product_params}) do
    case Ash.create(Pc3.Product, product_params) do
      {:ok, product} ->
        conn
        |> put_status(:created)
        |> json(%{data: product_json(product)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with {:ok, product} <- Ash.get(Pc3.Product, id),
         {:ok, updated_product} <- Ash.update(product, product_params) do
      json(conn, %{data: product_json(updated_product)})
    else
      {:error, %Ash.Error.Query.NotFound{}} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Product not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, product} <- Ash.get(Pc3.Product, id),
         :ok <- Ash.destroy(product) do
      send_resp(conn, :no_content, "")
    else
      {:error, %Ash.Error.Query.NotFound{}} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Product not found"})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to delete product"})
    end
  end

  defp product_json(product) do
    %{
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock
    }
  end

  defp format_errors(error) do
    case error do
      %{errors: errors} when is_list(errors) ->
        Enum.map(errors, fn e ->
          %{
            field: Map.get(e, :field) || Map.get(e, :input) || "base",
            message: Map.get(e, :message) || "Invalid input"
          }
        end)

      _ ->
        [%{field: "base", message: "Invalid input"}]
    end
  end
end
