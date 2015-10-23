class Evil::Client
  # Collection of gem-specific exceptions
  module Errors

    require_relative "errors/path_error"
    require_relative "errors/url_error"

  end
end
