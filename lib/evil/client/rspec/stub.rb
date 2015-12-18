module Evil::Client::RSpec
  # Extends/reloads methods of the `receive` object
  module Stub
    include RSpec::Matchers

    # Reloads `with` chain method so that it can take a block with a request
    #
    # Unlike original condition it also accumulates conditions and
    # checks the request against all of them.
    #
    # @param [RequestMock] mock
    #   The mock to compare to request by method and path
    # @param [Proc] condition
    #   The condition to be satisfied by actual request
    #
    # @return [undefined]
    #
    def with(mock = nil, &condition)
      @conditions ||= []
      if mock
        @conditions << mock.to_proc
        super mock
      else
        @conditions << condition
        super satisfy_all(@conditions)
      end
    end

    # Adds `and_respond` chain method to define a response to be returned
    #
    # @param [Integer] status The status of the response
    # @param [Hash, nil] body The body of the response
    #
    # @return [undefined]
    #
    def and_respond(status, body = nil)
      and_return Evil::Client::Response.new(status, body)
    end
  end
end
