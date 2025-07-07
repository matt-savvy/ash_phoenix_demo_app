defmodule MyApp.Operations.Business do
  use Ash.Resource, otp_app: :my_app, domain: MyApp.Operations, data_layer: AshPostgres.DataLayer

  postgres do
    table "businesses"
    repo MyApp.Repo
  end

  actions do
    defaults [:read, :destroy]
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end
  end
end
