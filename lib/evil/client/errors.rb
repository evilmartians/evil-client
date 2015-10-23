class Evil::Client
  # Коллекция специфических исключений
  #
  module Errors

    require_relative "errors/path_error"
    require_relative "errors/url_error"

  end
end
