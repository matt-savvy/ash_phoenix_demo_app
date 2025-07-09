defmodule MyAppWeb.ServiceLive.IndexTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  require Ash.Query

  alias MyApp.Operations.{Service, Location}

  setup do
    locations =
      [
        %{name: "HQ"},
        %{name: "Downtown Station"},
        %{name: "Northeast Station"}
      ]
      |> Ash.bulk_create!(Location, :create, return_records?: true)
      |> Map.get(:records)

    %{locations: locations}
  end

  test "create a new service", %{conn: conn, locations: locations} do
    [%{id: location_1_id}, %{id: location_2_id} | _rest] = locations
    {:ok, new_service_view, html} = live(conn, "/services/new")

    assert html =~ "New Service"

    attrs = %{name: "Overhaul", location_ids: [location_1_id, location_2_id]}

    assert new_service_view
           |> form("#service-form", service: attrs)
           |> render_submit()

    assert %Service{
             locations: [
               %Location{id: ^location_1_id},
               %Location{id: ^location_2_id}
             ]
           } =
             Ash.Query.filter(Service, name == ^attrs.name)
             |> Ash.read!(load: [:locations])
             |> List.first()
  end

  test "edit a service", %{conn: conn, locations: locations} do
    [%{id: location_1_id}, %{id: location_2_id}, %{id: location_3_id}] = locations

    %Service{} =
      service =
      Ash.create!(Service, %{name: "Overhaul", location_ids: [location_1_id, location_2_id]})

    {:ok, edit_service_view, html} = live(conn, "/services/#{service.id}/edit")

    assert html =~ "Edit Service"

    select =
      edit_service_view
      |> element("#service_location_ids")
      |> render

    assert select =~ "<option selected=\"selected\" value=\"#{location_1_id}\">"
    assert select =~ "<option selected=\"selected\" value=\"#{location_2_id}\">"
    assert select =~ "<option value=\"#{location_3_id}\""

    attrs = %{location_ids: [location_2_id, location_3_id]}

    assert edit_service_view
           |> form("#service-form", service: attrs)
           |> render_submit()

    assert %Service{
             locations: [
               %Location{id: ^location_2_id},
               %Location{id: ^location_3_id}
             ]
           } =
             Ash.get!(Service, service.id, load: [:locations])
  end
end
