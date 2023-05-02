defmodule NuxWeb.UploadLive do
  use NuxWeb, :live_view
  alias Nux.{Cashflow, Sheet}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:files, [])
     |> assign(:sheet_by_category_and_period, %{})
     |> assign(:sheet_by_period_and_category, %{})
     |> assign(:cashflows, [])
     |> assign(:cashflow_found, [])
     |> assign(:cashflow_title, "")
     |> assign(:cashflow_category, "")
     |> allow_upload(:csv_file, accept: ~w(.csv), max_entries: 100, auto_upload: true)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :csv_file, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    files =
      consume_uploaded_entries(socket, :csv_file, fn %{path: path}, %{client_name: filename} ->
        {:ok, {filename, Cashflow.list_from_file!(path)}}
      end)

    files = files ++ socket.assigns.files
    cashflows = Enum.flat_map(files, fn {_filename, cashflows} -> cashflows end)
    sheet_by_category_and_period = Sheet.group_by_category_and_period(cashflows, :month)
    sheet_by_period_and_category = Sheet.group_by_period_and_category(cashflows, :month)

    {:noreply,
     socket
     |> assign(:files, files)
     |> assign(:cashflows, cashflows)
     |> assign(:sheet_by_category_and_period, sheet_by_category_and_period)
     |> assign(:sheet_by_period_and_category, sheet_by_period_and_category)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate_category", params, socket) do
    %{"cashflow" => %{"title" => subtitle}} = params

    if subtitle == "" do
      {:noreply, assign(socket, :cashflow_found, [])}
    else
      cashflows =
        Enum.filter(socket.assigns.cashflows, fn %{title: title} ->
          String.contains?(String.downcase(title), String.downcase(subtitle))
        end)

      {:noreply, assign(socket, :cashflow_found, cashflows)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("save_category", %{"cashflow" => params}, socket) do
    %{"title" => subtitle, "category" => category} = params
    subtitle = String.downcase(subtitle)

    cashflows =
      socket.assigns.cashflows
      |> Enum.map(fn cashflow ->
        if cashflow.title |> String.downcase() |> String.contains?(subtitle) do
          %{cashflow | category: category}
        else
          cashflow
        end
      end)

    sheet_by_category_and_period = Sheet.group_by_category_and_period(cashflows, :month)
    sheet_by_period_and_category = Sheet.group_by_period_and_category(cashflows, :month)

    {:noreply,
     socket
     |> assign(:cashflow_found, [])
     |> assign(:cashflow_title, "")
     |> assign(:cashflow_category, "")
     |> assign(:cashflows, cashflows)
     |> assign(:sheet_by_category_and_period, sheet_by_category_and_period)
     |> assign(:sheet_by_period_and_category, sheet_by_period_and_category)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
