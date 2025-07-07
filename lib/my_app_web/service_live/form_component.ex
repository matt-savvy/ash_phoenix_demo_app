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
          type="select"
          multiple
          label="Locations"
          options={[{"1", 1}, {"2", 2}]}
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
     |> assign_form()}
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
        AshPhoenix.Form.for_update(service, :update, as: "service")
      else
        AshPhoenix.Form.for_create(MyApp.Operations.Service, :create, as: "service")
      end

    assign(socket, form: to_form(form))
  end
end
