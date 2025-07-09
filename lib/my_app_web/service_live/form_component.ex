defmodule MyAppWeb.ServiceLive.FormComponent do
  use MyAppWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage service records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="service-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:locations]}
          value={locations_value(@form)}
          type="select"
          multiple
          label="Locations"
          options={Enum.map(@locations, &{&1.name, &1.id})}
        />
        <.input field={@form[:name]} type="text" label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Service</.button>
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
     |> assign_locations()
     |> assign_form()}
  end

  defp assign_locations(socket) do
    locations =
      MyApp.Operations.Location
      |> Ash.read!()

    socket
    |> assign(:locations, locations)
  end

  defp locations_value(form) do
    case Ash.Changeset.fetch_argument(form.source.source, :locations) do
      {:ok, location_ids} ->
        location_ids

      :error ->
        case form.source.source.data.locations do
          %Ash.NotLoaded{} -> []
          locations -> Enum.map(locations, & &1.id)
        end
    end
  end

  @impl true
  def handle_event("validate", %{"service" => service_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, service_params))}
  end

  def handle_event("save", %{"service" => service_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: service_params) do
      {:ok, service} ->
        notify_parent({:saved, service})

        socket =
          socket
          |> put_flash(:info, "Service #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{service: service}} = socket) do
    form =
      if service do
        service
        |> Ash.load!([:locations])
        |> AshPhoenix.Form.for_update(:update, as: "service")
      else
        AshPhoenix.Form.for_create(MyApp.Operations.Service, :create, as: "service")
      end

    assign(socket, form: to_form(form))
  end
end
