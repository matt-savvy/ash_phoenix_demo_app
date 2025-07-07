defmodule MyApp.Operations.Service do
  use Ash.Resource, otp_app: :my_app, domain: MyApp.Operations, data_layer: AshPostgres.DataLayer

  postgres do
    table "services"
    repo MyApp.Repo
  end

  actions do
    defaults [:read, :destroy, create: [], update: []]
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end
  end
end
