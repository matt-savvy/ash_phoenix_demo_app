defmodule MyApp.Operations do
  use Ash.Domain,
    otp_app: :my_app

  resources do
    resource MyApp.Operations.Business
    resource MyApp.Operations.Location
  end
end
