defmodule MyApp.OperationsTest do
  use MyApp.DataCase

  alias MyApp.Operations.{Location, Service, ServiceLocation}
  require Ash.Query

  describe "Operations tests" do
    test "can create a service with locations" do
      %{id: location_1_id} = Ash.create!(Location, %{name: "HQ"})
      %{id: location_2_id} = Ash.create!(Location, %{name: "Downtown Station"})
      %{id: location_3_id} = Ash.create!(Location, %{name: "Northeast Station"})

      service_1 =
        Ash.create!(Service, %{name: "Tuneup", locations: [location_1_id, location_2_id]})

      assert Ash.Query.filter(ServiceLocation, service_id == ^service_1.id) |> Ash.count!() == 2

      assert %Service{
               locations: [%Location{id: ^location_1_id}, %Location{id: location_2_id}],
               location_ids: [^location_1_id, ^location_2_id]
             } = Ash.load!(service_1, [:locations, :location_ids])

      service_2 = Ash.create!(Service, %{name: "Overhaul", locations: [location_3_id]})

      assert Ash.Query.filter(ServiceLocation, service_id == ^service_2.id) |> Ash.count!() == 1

      Ash.update!(service_2, %{locations: [location_2_id]})

      assert %Service{
               locations: [%Location{id: location_2_id}]
             } = Ash.load!(service_2, [:locations])

      assert [
               %ServiceLocation{location_id: ^location_2_id}
             ] = Ash.Query.filter(ServiceLocation, service_id == ^service_2.id) |> Ash.read!()
    end
  end
end
