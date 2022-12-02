defmodule Nux.Csv do
  def is_card?(content) do
    String.starts_with?(content, "date,category,title,amount")
  end
end
