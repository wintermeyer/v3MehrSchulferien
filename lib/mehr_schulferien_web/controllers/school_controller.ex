defmodule MehrSchulferienWeb.SchoolController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Location
  alias MehrSchulferien.Location.School

  def index(conn, _params) do
    schools = Location.list_schools()
    render(conn, "index.html", schools: schools)
  end

  def new(conn, _params) do
    changeset = Location.change_school(%School{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"school" => school_params}) do
    case Location.create_school(school_params) do
      {:ok, school} ->
        conn
        |> put_flash(:info, "School created successfully.")
        |> redirect(to: school_path(conn, :show, school))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    school = Location.get_school!(id)
    render(conn, "show.html", school: school)
  end

  def edit(conn, %{"id" => id}) do
    school = Location.get_school!(id)
    changeset = Location.change_school(school)
    render(conn, "edit.html", school: school, changeset: changeset)
  end

  def update(conn, %{"id" => id, "school" => school_params}) do
    school = Location.get_school!(id)

    case Location.update_school(school, school_params) do
      {:ok, school} ->
        conn
        |> put_flash(:info, "School updated successfully.")
        |> redirect(to: school_path(conn, :show, school))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", school: school, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    school = Location.get_school!(id)
    {:ok, _school} = Location.delete_school(school)

    conn
    |> put_flash(:info, "School deleted successfully.")
    |> redirect(to: school_path(conn, :index))
  end
end
