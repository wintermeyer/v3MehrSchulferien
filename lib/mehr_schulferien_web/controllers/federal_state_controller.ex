defmodule MehrSchulferienWeb.FederalStateController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Location
  alias MehrSchulferien.Location.FederalState

  def index(conn, _params) do
    federal_states = Location.list_federal_states()
    render(conn, "index.html", federal_states: federal_states)
  end

  def new(conn, _params) do
    changeset = Location.change_federal_state(%FederalState{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"federal_state" => federal_state_params}) do
    case Location.create_federal_state(federal_state_params) do
      {:ok, federal_state} ->
        conn
        |> put_flash(:info, "Federal state created successfully.")
        |> redirect(to: federal_state_path(conn, :show, federal_state))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    federal_state = Location.get_federal_state!(id)
    render(conn, "show.html", federal_state: federal_state)
  end

  def edit(conn, %{"id" => id}) do
    federal_state = Location.get_federal_state!(id)
    changeset = Location.change_federal_state(federal_state)
    render(conn, "edit.html", federal_state: federal_state, changeset: changeset)
  end

  def update(conn, %{"id" => id, "federal_state" => federal_state_params}) do
    federal_state = Location.get_federal_state!(id)

    case Location.update_federal_state(federal_state, federal_state_params) do
      {:ok, federal_state} ->
        conn
        |> put_flash(:info, "Federal state updated successfully.")
        |> redirect(to: federal_state_path(conn, :show, federal_state))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", federal_state: federal_state, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    federal_state = Location.get_federal_state!(id)
    {:ok, _federal_state} = Location.delete_federal_state(federal_state)

    conn
    |> put_flash(:info, "Federal state deleted successfully.")
    |> redirect(to: federal_state_path(conn, :index))
  end
end
