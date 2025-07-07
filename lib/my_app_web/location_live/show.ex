defmodule MyAppWeb.LocationLive.Show do
  use MyAppWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Location {@location.id}
      <:subtitle>This is a location record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/locations/#{@location}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit location</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@location.id}</:item>
    </.list>

    <.back navigate={~p"/locations"}>Back to locations</.back>

    <.modal
      :if={@live_action == :edit}
      id="location-modal"
      show
      on_cancel={JS.patch(~p"/locations/#{@location}")}
    >
      <.live_component
        module={MyAppWeb.LocationLive.FormComponent}
        id={@location.id}
        title={@page_title}
        action={@live_action}
        location={@location}
        patch={~p"/locations/#{@location}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:location, Ash.get!(MyApp.Operations.Location, id))}
  end

  defp page_title(:show), do: "Show Location"
  defp page_title(:edit), do: "Edit Location"
end
