defmodule NuxWeb.UploadLive do
  use NuxWeb, :live_view
  alias Nux.Csv

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, %{})
     |> allow_upload(:avatar, accept: ~w(.csv), max_entries: 100, auto_upload: true)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, %{client_name: filename} ->
        {:ok, {filename, File.read!(path)}}
      end)

    {:noreply, update(socket, :uploaded_files, &Enum.into(uploaded_files, &1))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
