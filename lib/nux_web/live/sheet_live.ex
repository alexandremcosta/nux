defmodule NuxWeb.SheetLive do
  use NuxWeb, :live_view
  alias Nux.{Transfer, Sheet}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:files, [])
     |> assign(:sheet, %{})
     |> assign(:transfers, [])
     |> assign(:transfer_found, [])
     |> assign(:transfer_title, "")
     |> assign(:transfer_category, "")
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
        {:ok, {filename, Transfer.list_from_file!(path)}}
      end)

    files = files ++ socket.assigns.files
    transfers = Enum.flat_map(files, fn {_filename, transfers} -> transfers end)
    sheet = Sheet.group_by_category_and_period(transfers, :month)

    {:noreply,
     socket
     |> assign(:files, files)
     |> assign(:transfers, transfers)
     |> assign(:sheet, sheet)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate_category", params, socket) do
    %{"transfer" => %{"title" => subtitle}} = params

    if subtitle == "" do
      {:noreply, assign(socket, :transfer_found, [])}
    else
      transfers =
        socket.assigns.transfers
        |> Enum.filter(fn %{title: title} ->
          String.contains?(String.downcase(title), String.downcase(subtitle))
        end)
        |> Enum.sort_by(& &1.date, {:desc, Date})

      {:noreply, assign(socket, :transfer_found, transfers)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("save_category", %{"transfer" => params}, socket) do
    %{"title" => subtitle, "category" => category} = params
    subtitle = String.downcase(subtitle)

    transfers =
      socket.assigns.transfers
      |> Enum.map(fn transfer ->
        if transfer.title |> String.downcase() |> String.contains?(subtitle) do
          %{transfer | category: category}
        else
          transfer
        end
      end)

    sheet = Sheet.group_by_category_and_period(transfers, :month)

    {:noreply,
     socket
     |> assign(:transfer_found, [])
     |> assign(:transfer_title, "")
     |> assign(:transfer_category, "")
     |> assign(:transfers, transfers)
     |> assign(:sheet, sheet)}
  end

  def handle_event("change_form", params, socket) do
    query = params["title"]

    transfers =
      socket.assigns.transfers
      |> Enum.filter(fn %{title: title} ->
        String.contains?(String.downcase(title), String.downcase(query))
      end)
      |> Enum.sort_by(& &1.date, {:desc, Date})

    {:noreply, socket |> assign(:transfer_title, query) |> assign(:transfer_found, transfers)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
