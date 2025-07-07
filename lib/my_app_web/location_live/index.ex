defmodule MyAppWeb.LocationLive.Index do
  use MyAppWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Locations
      <:actions>
        <.link patch={~p"/locations/new"}>
          <.button>New Location</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="locations"
      rows={@streams.locations}
      row_click={fn {_id, location} -> JS.navigate(~p"/locations/#{location}") end}
    >
      <:col :let={{_id, location}} label="Id">{location.id}</:col>

      <:action :let={{_id, location}}>
        <div class="sr-only">
          <.link navigate={~p"/locations/#{location}"}>Show</.link>
        </div>

        <.link patch={~p"/locations/#{location}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, location}}>
        <.link
          phx-click={JS.push("delete", value: %{id: location.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="location-modal"
      show
      on_cancel={JS.patch(~p"/locations")}
    >
      <.live_component
        module={MyAppWeb.LocationLive.FormComponent}
        id={(@location && @location.id) || :new}
        title={@page_title}
        action={@live_action}
        location={@location}
        patch={~p"/locations"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :locations, Ash.read!(MyApp.Operations.Location))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Location")
    |> assign(:location, Ash.get!(MyApp.Operations.Location, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Location")
    |> assign(:location, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Locations")
    |> assign(:location, nil)
  end

  @impl true
  def handle_info({MyAppWeb.LocationLive.FormComponent, {:saved, location}}, socket) do
    {:noreply, stream_insert(socket, :locations, location)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    location = Ash.get!(MyApp.Operations.Location, id)
    Ash.destroy!(location)

    {:noreply, stream_delete(socket, :locations, location)}
  end
end
