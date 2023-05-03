defmodule Nux.Cashflow do
  @moduledoc "Cashflow is a struct that represents a single row on Nubank's CSV file."
  defstruct [:date, :category, :title, :amount, :type]
  NimbleCSV.define(CSVParser, escape: "\\")

  @type cashflow :: %{
          date: Date.t(),
          category: String.t() | nil,
          title: String.t(),
          amount: Decimal.t(),
          type: :credit_card | :checking_account
        }

  @doc """
  Lists cashflows from a CSV file.

  ## Example

      iex> path = Path.join([__DIR__, "..", "test", "fixtures", "nubank.csv"])
      iex> Cashflow.list_from_file(path)
      [
        %Cashflow{
          amount: Decimal.new("10.00"),
          category: "food",
          date: ~D[2021-01-01],
          title: "McDonalds",
          type: :credit_card
        }
      ]
  """
  @spec list_from_file!(Path.t()) :: [cashflow()]
  def list_from_file!(path) do
    stream = path |> File.stream!() |> CSVParser.parse_stream(skip_headers: false)
    header = stream |> Enum.take(1) |> List.first()

    stream
    |> Stream.drop(1)
    |> Stream.map(mapper!(header))
    |> Enum.to_list()
  end

  @credit_card_headers ["date", "category", "title", "amount"]
  @checking_account_headers ["Data", "Valor", "Identificador", "Descrição"]
  defp mapper!(headers) do
    type =
      case headers do
        @credit_card_headers -> :credit_card
        @checking_account_headers -> :checking_account
      end

    fn row -> new(row, type) end
  end

  defp new([date, category, title, amount], :credit_card) do
    %__MODULE__{
      amount: amount |> Decimal.new() |> Decimal.negate(),
      category: if(category != "", do: category),
      date: Date.from_iso8601!(date),
      title: title,
      type: :credit_card
    }
  end

  defp new([date, amount, _id, title], :checking_account) do
    %__MODULE__{
      amount: Decimal.new(amount),
      category: nil,
      date: parse_brazilian_date!(date),
      title: title,
      type: :checking_account
    }
  end

  defp parse_brazilian_date!(date_string) do
    [day, month, year] = date_string |> String.split("/") |> Enum.map(&String.to_integer/1)
    Date.new!(year, month, day)
  end

  @doc """
  Sums the amounts of a list of cashflows.

  ## Example

      iex> cashflows = [
      ...>   %Cashflow{amount: Decimal.new("10.00")},
      ...>   %Cashflow{amount: Decimal.new("20.00")}
      ...> ]
      iex> Cashflow.sum_amounts(cashflows)
      Decimal.new("30.00")
  """
  @spec sum_amounts([cashflow()]) :: Decimal.t()
  def sum_amounts(cashflows) do
    cashflows
    |> Enum.map(& &1.amount)
    |> Enum.reduce(0, &Decimal.add/2)
  end
end
