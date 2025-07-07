defmodule MyApp.Operations.ServiceLocation do
  use Ash.Resource, otp_app: :my_app, domain: MyApp.Operations, data_layer: AshPostgres.DataLayer

  postgres do
    table "service_locations"
    repo MyApp.Repo

    references do
      reference :service, on_delete: :delete, index?: true
      reference :location, on_delete: :delete, index?: true
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:service_id, :location_id]
  end

  relationships do
    belongs_to :service, MyApp.Operations.Service do
      attribute_type :integer
      allow_nil? false
      primary_key? true
    end

    belongs_to :location, MyApp.Operations.Location do
      attribute_type :integer
      allow_nil? false
      primary_key? true
    end
  end
end
