defmodule Helpers do
  def format_date(date) do
    Calendar.strftime(date, "%d/%m/%Y")
  end
end
