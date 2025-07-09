defmodule MyAppWeb.Operations.FormTest do
  use MyApp.DataCase

  alias MyApp.Operations.{Location, Service, ServiceLocation}
  require Ash.Query

  describe "Operations forms test" do
    test "can create and update services with a form" do
      %{id: location_1_id} = Ash.create!(Location, %{name: "HQ"})
      %{id: location_2_id} = Ash.create!(Location, %{name: "Downtown Station"})
      %{id: location_3_id} = Ash.create!(Location, %{name: "Northeast Station"})

      phx_form =
        Service
        |> AshPhoenix.Form.for_create(:create)
        |> Phoenix.Component.to_form()

      create_attrs = %{"name" => "Tuneup", "location_ids" => [location_1_id, location_2_id]}

      assert %Phoenix.HTML.Form{
               source: %AshPhoenix.Form{
                 source: %Ash.Changeset{
                   valid?: true
                 }
               }
             } = AshPhoenix.Form.validate(phx_form, create_attrs)

      assert {:ok, %Service{id: service_id} = service} =
               AshPhoenix.Form.submit(phx_form, params: create_attrs)

      assert [
               %ServiceLocation{location_id: ^location_1_id, service_id: ^service_id},
               %ServiceLocation{location_id: ^location_2_id, service_id: ^service_id}
             ] = Ash.Query.filter(ServiceLocation, service_id == ^service.id) |> Ash.read!()

      assert %Service{
               locations: [%Location{id: ^location_1_id}, %Location{id: ^location_2_id}]
             } = service = Ash.load!(service, [:locations])

      phx_form =
        service
        |> AshPhoenix.Form.for_update(:update)
        |> Phoenix.Component.to_form()

      %Ash.Changeset{data: data} = phx_form.source.source
      assert [%Location{id: ^location_1_id}, %Location{id: ^location_2_id}] = data.locations

      update_attrs = %{"name" => "Tuneup", "location_ids" => [location_3_id]}

      assert {:ok, %Service{} = service} =
               AshPhoenix.Form.submit(phx_form, params: update_attrs)

      assert [
               %ServiceLocation{location_id: ^location_3_id, service_id: ^service_id}
             ] = Ash.Query.filter(ServiceLocation, service_id == ^service.id) |> Ash.read!()

      assert %Service{
               locations: [%Location{id: ^location_3_id}]
             } = Ash.load!(service, [:locations])
    end
  end
end
