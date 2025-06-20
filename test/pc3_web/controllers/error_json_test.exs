defmodule Pc3Web.ErrorJSONTest do
  use Pc3Web.ConnCase, async: true

  test "renders 404" do
    assert Pc3Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Pc3Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
