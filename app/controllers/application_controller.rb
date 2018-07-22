class ApplicationController < ActionController::Base
  http_basic_authenticate_with(
    name: Rails.application.credentials.http_user,
    password: Rails.application.credentials.http_password
  )
end
