defmodule Nux.Sheet do
  alias Cashflow
  @type period_kind :: :day | :week | :month

  @doc """
  Groups cashflows by category and period.
  Period can be :day, :week or :month.

  ## Examples

      iex> cashflows = [
      ...>   %Cashflow{date: ~D[2021-01-01], category: "food", amount: Decimal.new("10.00")},
      ...>   %Cashflow{date: ~D[2021-01-01], category: "food", amount: Decimal.new("20.00")},
      ...>   %Cashflow{date: ~D[2021-01-02], category: "food", amount: Decimal.new("50.00")},
      ...>   %Cashflow{date: ~D[2022-02-02], category: "food", amount: Decimal.new("60.00")},
      ...>   %Cashflow{date: ~D[2022-02-02], category: "food", amount: Decimal.new("80.00")},
      ...>   %Cashflow{date: ~D[2022-02-03], category: "food", amount: Decimal.new("90.00")},
      ...> ]
      iex> Sheet.group_by_category_and_period(cashflows, :day)
      %{
        "food" => %{
          ~D[2021-01-01] => [
            %Cashflow{date: ~D[2021-01-01], category: "food", amount: Decimal.new("10.00")},
            %Cashflow{date: ~D[2021-01-01], category: "food", amount: Decimal.new("20.00")}
          ],
          ~D[2021-01-02] => [
            %Cashflow{date: ~D[2021-01-02], category: "food", amount: Decimal.new("50.00")}
          ],
          ~D[2022-02-02] => [
            %Cashflow{date: ~D[2022-02-02], category: "food", amount: Decimal.new("60.00")},
            %Cashflow{date: ~D[2022-02-02], category: "food", amount: Decimal.new("80.00")}
          ],
          ~D[2022-02-03] => [
            %Cashflow{date: ~D[2022-02-03], category: "food", amount: Decimal.new("90.00")}
          ]
        }
      }
  """
  @spec group_by_category_and_period(Enumerable.t(), period_kind) ::
          %{String.t() => %{Date.t() => [Cashflow.t()]}}
  def group_by_category_and_period(cashflows, period_kind) do
    cashflows
    |> Enum.group_by(& &1.category)
    |> Map.new(fn {category, cashflows} ->
      {category, group_by_period(cashflows, period_kind)}
    end)
  end

  defp group_by_period(cashflows, period_kind) do
    cashflows
    |> Enum.group_by(beginning_of_function(period_kind))
    |> Enum.map(fn {start_date, cashflows} ->
      sorted_cashflows = Enum.sort_by(cashflows, & &1.date, Date)
      {start_date, sorted_cashflows}
    end)
    |> Enum.sort_by(fn {start_date, _cashflows} -> start_date end, Date)
  end

  defp beginning_of_function(period_kind) do
    case period_kind do
      :day -> & &1.date
      :week -> &Date.beginning_of_week(&1.date)
      :month -> &Date.beginning_of_month(&1.date)
    end
  end

  def group_by_period_and_category(cashflows, period_kind) do
    cashflows
    |> group_by_period(period_kind)
    |> Map.new(fn {period, cashflows} ->
      {period, Enum.group_by(cashflows, & &1.category)}
    end)
  end

  def list_all_periods(sheet) do
    sheet
    |> Enum.flat_map(fn {_category, by_period} ->
      Enum.map(by_period, fn {period, _cashflows} -> period end)
    end)
    |> Enum.uniq()
    |> Enum.sort(Date)
  end

  def list_cashflows(sheet, period) do
    Enum.flat_map(sheet, fn {_category, by_period} ->
      find_cashflows(by_period, period)
    end)
  end

  def find_cashflows(by_period, period) do
    Enum.find_value(
      by_period,
      [],
      fn {p, cashflows} ->
        if p == period, do: cashflows
      end
    )
  end
end
