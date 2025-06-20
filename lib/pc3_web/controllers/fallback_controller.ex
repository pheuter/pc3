defmodule Pc3Web.FallbackController do
  use Pc3Web, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: Pc3Web.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: Pc3Web.ErrorJSON)
    |> render(:"422", changeset: changeset)
  end
end
