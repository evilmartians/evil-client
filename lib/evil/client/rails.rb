class Evil::Client
  # Rails plugin for extracting request id from Railtie
  #
  # @api private
  #
  module Rails
    require_relative "rails/request_id"
    require_relative "rails/railtie"
  end 
end
