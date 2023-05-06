defmodule Nux.Sheet do
  alias Nux.Transfer
  @type period_kind :: :day | :week | :month

  @doc """
  Groups transfers by category and period.
  Period can be :day, :week or :month.

  ## Examples

      iex> transfers = [
      ...>   %Transfer{date: ~D[2021-01-01], category: "food", amount: Decimal.new("10.00")},
      ...>   %Transfer{date: ~D[2021-01-01], category: "food", amount: Decimal.new("20.00")},
      ...>   %Transfer{date: ~D[2021-01-02], category: "food", amount: Decimal.new("50.00")},
      ...>   %Transfer{date: ~D[2022-02-02], category: "food", amount: Decimal.new("60.00")},
      ...>   %Transfer{date: ~D[2022-02-02], category: "food", amount: Decimal.new("80.00")},
      ...>   %Transfer{date: ~D[2022-02-03], category: "food", amount: Decimal.new("90.00")},
      ...> ]
      iex> Sheet.group_by_category_and_period(transfers, :day)
      %{
        "food" => [
          {~D[2021-01-01],
           [
             %Transfer{date: ~D[2021-01-01], category: "food", amount: Decimal.new("10.00")},
             %Transfer{date: ~D[2021-01-01], category: "food", amount: Decimal.new("20.00")}
           ]},
          {~D[2021-01-02],
           [
             %Transfer{date: ~D[2021-01-02], category: "food", amount: Decimal.new("50.00")}
           ]},
          {~D[2022-02-02],
           [
             %Transfer{date: ~D[2022-02-02], category: "food", amount: Decimal.new("60.00")},
             %Transfer{date: ~D[2022-02-02], category: "food", amount: Decimal.new("80.00")}
           ]},
          {~D[2022-02-03],
           [
             %Transfer{date: ~D[2022-02-03], category: "food", amount: Decimal.new("90.00")}
           ]}
        ]
      }

  """
  @spec group_by_category_and_period(Enumerable.t(), period_kind) ::
          %{String.t() => %{Date.t() => [Transfer.t()]}}
  def group_by_category_and_period(transfers, period_kind) do
    transfers
    |> Enum.group_by(& &1.category)
    |> Map.new(fn {cat, transfers} -> {cat, group_by_period(transfers, period_kind)} end)
  end

  defp group_by_period(transfers, period_kind) do
    transfers
    |> Enum.group_by(beginning_of_function(period_kind))
    |> Enum.map(fn {date, transfers} -> {date, Enum.sort_by(transfers, & &1.date, Date)} end)
    |> List.keysort(0, Date)
  end

  defp beginning_of_function(period_kind) do
    case period_kind do
      :day -> & &1.date
      :week -> &Date.beginning_of_week(&1.date)
      :month -> &Date.beginning_of_month(&1.date)
    end
  end

  def list_all_periods(sheet) do
    sheet
    |> Enum.flat_map(fn {_category, by_period} ->
      Enum.map(by_period, fn {period, _transfers} -> period end)
    end)
    |> Enum.uniq()
    |> Enum.sort(Date)
  end

  def list_transfers(sheet, period) do
    Enum.flat_map(sheet, fn {_category, by_period} ->
      find_transfer(by_period, period)
    end)
  end

  def find_transfer(list, key) when is_list(list) do
    {_key, transfers} = List.keyfind(list, key, 0, {nil, []})
    transfers
  end
end
