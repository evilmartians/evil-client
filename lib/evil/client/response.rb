require "hashie"
require "json"

class Evil::Client
  # Data structure describing the content of successful response
  #
  # @see https://github.com/intridea/hashie 'hashie' gem for +Mash+ description
  #
  # @api public
  #
  class Response < Hashie::Mash
    def initialize(raw_response)
      super JSON(raw_response.content)
    end
  end
end
