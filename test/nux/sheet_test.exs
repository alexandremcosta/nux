defmodule Nux.SheetTest do
  use ExUnit.Case, async: true
  alias Nux.{Sheet, Transfer}
  doctest Sheet

  test "group by month" do
    cashflows = [
      %Transfer{date: ~D[2021-01-01], category: "food", amount: Decimal.new("10.00")},
      %Transfer{date: ~D[2021-01-10], category: "food", amount: Decimal.new("20.00")},
      %Transfer{date: ~D[2021-02-03], category: "food", amount: Decimal.new("50.00")},
      %Transfer{date: ~D[2021-02-25], category: "food", amount: Decimal.new("80.00")},
      %Transfer{date: ~D[2022-03-05], category: "food", amount: Decimal.new("100.00")}
    ]

    assert Sheet.group_by_category_and_period(cashflows, :month) == %{
             "food" => [
               {~D[2021-01-01],
                [
                  %Transfer{date: ~D[2021-01-01], category: "food", amount: Decimal.new("10.00")},
                  %Transfer{date: ~D[2021-01-10], category: "food", amount: Decimal.new("20.00")}
                ]},
               {~D[2021-02-01],
                [
                  %Transfer{date: ~D[2021-02-03], category: "food", amount: Decimal.new("50.00")},
                  %Transfer{date: ~D[2021-02-25], category: "food", amount: Decimal.new("80.00")}
                ]},
               {~D[2022-03-01],
                [
                  %Transfer{date: ~D[2022-03-05], category: "food", amount: Decimal.new("100.00")}
                ]}
             ]
           }
  end

  test "group by week" do
    cashflows = [
      %Transfer{date: ~D[2021-01-01], category: "food", amount: Decimal.new("1.00")},
      %Transfer{date: ~D[2021-01-02], category: "food", amount: Decimal.new("2.00")},
      %Transfer{date: ~D[2021-03-30], category: "food", amount: Decimal.new("5.00")},
      %Transfer{date: ~D[2021-04-01], category: "food", amount: Decimal.new("8.00")},
      %Transfer{date: ~D[2022-03-05], category: "food", amount: Decimal.new("3.00")}
    ]

    assert Sheet.group_by_category_and_period(cashflows, :week) == %{
             "food" => [
               {~D[2020-12-28],
                [
                  %Transfer{amount: Decimal.new("1.00"), category: "food", date: ~D[2021-01-01]},
                  %Transfer{amount: Decimal.new("2.00"), category: "food", date: ~D[2021-01-02]}
                ]},
               {~D[2021-03-29],
                [
                  %Transfer{amount: Decimal.new("5.00"), category: "food", date: ~D[2021-03-30]},
                  %Transfer{amount: Decimal.new("8.00"), category: "food", date: ~D[2021-04-01]}
                ]},
               {~D[2022-02-28],
                [
                  %Transfer{amount: Decimal.new("3.00"), category: "food", date: ~D[2022-03-05]}
                ]}
             ]
           }
  end
end
