defmodule Helpers do
  def format_date(date) do
    Calendar.strftime(date, "%d/%m/%Y")
  end

  def nil_or_empty?(value) do
    value == nil || value == ""
  end

  def convert!("true"), do: true
  def convert!("false"), do: false
  def convert!(1), do: true
  def convert!(0), do: false
  def convert!("1"), do: true
  def convert!("0"), do: false
  def convert!(num), do: String.to_integer(num)
end
