defmodule Pc3.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Pc3.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Pc3.DataCase
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Pc3.Repo)

    unless tags[:async] do
      Sandbox.mode(Pc3.Repo, {:shared, self()})
    end

    :ok
  end
end
