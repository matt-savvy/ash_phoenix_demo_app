defmodule MyAppWeb.LocationLive.FormComponent do
  use MyAppWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage location records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="location-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Location</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, location_params))}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: location_params) do
      {:ok, location} ->
        notify_parent({:saved, location})

        socket =
          socket
          |> put_flash(:info, "Location #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{location: location}} = socket) do
    form =
      if location do
        AshPhoenix.Form.for_update(location, :update, as: "location")
      else
        AshPhoenix.Form.for_create(MyApp.Operations.Location, :create, as: "location")
      end

    assign(socket, form: to_form(form))
  end
end
