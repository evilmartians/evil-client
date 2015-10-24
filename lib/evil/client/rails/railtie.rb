require "logger"

module Evil::Client::Rails
  # Takes request_id provider and logger from Rails app
  #
  # @api private
  #
  class Railtie < Rails::Railtie
    # Sets request ID
    initializer "evil.client.rails.request_id" do |app|
      app.middleware.use RequestID
    end

    # Sets logger shared by all API instances in Rails dev/test environment
    if %w(development test).include? Rails.env
      initializer "evil.client.rails.logger" do
        logger = Logger.new("log/evil_client.log", "daily")
        Evil::Client::API.logger = logger
      end
    end
  end
end
