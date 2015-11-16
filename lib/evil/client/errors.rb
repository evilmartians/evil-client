class Evil::Client
  # Collection of gem-specific exceptions
  #
  # @api public
  #
  module Errors

    require_relative "errors/path_error"
    require_relative "errors/url_error"
    require_relative "errors/response_error"

  end
end
