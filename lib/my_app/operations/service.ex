defmodule MyApp.Operations.Service do
  use Ash.Resource, otp_app: :my_app, domain: MyApp.Operations, data_layer: AshPostgres.DataLayer

  postgres do
    table "services"
    repo MyApp.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name]
      primary? true
      argument :location_ids, {:array, :integer}, allow_nil?: true

      change manage_relationship(:location_ids, :locations, type: :append_and_remove)
    end

    update :update do
      accept [:name]
      primary? true
      argument :location_ids, {:array, :integer}, allow_nil?: true
      require_atomic? false

      change manage_relationship(:location_ids, :locations, type: :append_and_remove)
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end
  end

  relationships do
    has_many :location_relationships, MyApp.Operations.ServiceLocation do
      destination_attribute :service_id
    end

    many_to_many :locations, MyApp.Operations.Location do
      join_relationship :location_relationships
      source_attribute_on_join_resource :service_id
      destination_attribute_on_join_resource :location_id
    end
  end

  aggregates do
    list :location_ids, :locations, :id
  end
end
