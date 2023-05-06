defmodule Nux.Transfer do
  @moduledoc "Transfer is a struct that represents a single row the CSV file."
  defstruct [:date, :category, :title, :amount, :type]
  NimbleCSV.define(CSVParser, escape: "\\")

  @type transfer :: %{
          date: Date.t(),
          category: String.t() | nil,
          title: String.t(),
          amount: Decimal.t(),
          type: :credit_card | :checking_account
        }

  @doc """
  Lists transfers from a CSV file.

  ## Example

      iex> path = :code.priv_dir(:nux) |> Path.join(["fixtures/", "file.csv/"])
      iex> Transfer.list_from_file!(path)
      [
        %Transfer{
          amount: Decimal.new("-10.00"),
          category: "food",
          date: ~D[2021-01-01],
          title: "Mc Donalds",
          type: :credit_card
        }
      ]
  """
  @spec list_from_file!(Path.t()) :: [transfer()]
  def list_from_file!(path) do
    stream = path |> File.stream!() |> CSVParser.parse_stream(skip_headers: false)
    header = stream |> Enum.take(1) |> List.first()

    stream
    |> Stream.drop(1)
    |> Stream.map(fn row -> new(row, header) end)
    |> Enum.to_list()
  end

  @credit_card_header ["date", "category", "title", "amount"]
  @checking_account_header ["Data", "Valor", "Identificador", "Descrição"]

  defp new([date, category, title, amount], @credit_card_header) do
    %__MODULE__{
      amount: amount |> Decimal.new() |> Decimal.negate(),
      category: if(category != "", do: category),
      date: Date.from_iso8601!(date),
      title: title,
      type: :credit_card
    }
  end

  defp new([date, amount, _id, title], @checking_account_header) do
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
  Sums the amounts of a list of transfers.

  ## Example

      iex> transfers = [
      ...>   %Transfer{amount: Decimal.new("10.00")},
      ...>   %Transfer{amount: Decimal.new("20.00")}
      ...> ]
      iex> Transfer.sum_amounts(transfers)
      Decimal.new("30.00")
  """
  @spec sum_amounts([transfer()]) :: Decimal.t()
  def sum_amounts(transfers) do
    transfers
    |> Enum.map(& &1.amount)
    |> Enum.reduce(0, &Decimal.add/2)
  end
end
