defmodule MehrSchulferienWeb.DayController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Calendar
  alias MehrSchulferien.Calendar.Day

  def index(conn, _params) do
    days = Calendar.list_days()
    render(conn, "index.html", days: days)
  end

  def new(conn, _params) do
    changeset = Calendar.change_day(%Day{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"day" => day_params}) do
    case Calendar.create_day(day_params) do
      {:ok, day} ->
        conn
        |> put_flash(:info, "Day created successfully.")
        |> redirect(to: day_path(conn, :show, day))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    day = Calendar.get_day!(id)
    render(conn, "show.html", day: day)
  end

  def edit(conn, %{"id" => id}) do
    day = Calendar.get_day!(id)
    changeset = Calendar.change_day(day)
    render(conn, "edit.html", day: day, changeset: changeset)
  end

  def update(conn, %{"id" => id, "day" => day_params}) do
    day = Calendar.get_day!(id)

    case Calendar.update_day(day, day_params) do
      {:ok, day} ->
        conn
        |> put_flash(:info, "Day updated successfully.")
        |> redirect(to: day_path(conn, :show, day))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", day: day, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    day = Calendar.get_day!(id)
    {:ok, _day} = Calendar.delete_day(day)

    conn
    |> put_flash(:info, "Day deleted successfully.")
    |> redirect(to: day_path(conn, :index))
  end
end
