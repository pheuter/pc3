defmodule Pc3Web.PageController do
  use Pc3Web, :controller

  @spec home(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def home(conn, _params) do
    render(conn, :home)
  end
end
