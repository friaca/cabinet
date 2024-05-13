defmodule Helpers do
  def format_date(date) do
    Calendar.strftime(date, "%d/%m/%Y")
  end

  def nil_or_empty?(value) do
    value == nil || value == ""
  end
end
