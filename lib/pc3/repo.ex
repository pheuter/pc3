defmodule Pc3.Repo do
  use AshSqlite.Repo,
    otp_app: :pc3

  def installed_extensions do
    # Add any SQLite extensions here
    []
  end
end
