class Evil::Client
  # Rails plugin for extracting request id from Railtie
  #
  # @api private
  #
  module Rails
    require_relative "rails/request_id"
    require_relative "rails/railtie"
  end

  # Makes default_id to be taken from Railtie
  API.id_provider = Rails::RequestID
end
