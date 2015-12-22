module Evil::Client::RSpec
  # Extends/reloads methods of the `receive` object
  module Stub
    include RSpec::Matchers

    # Reloads `with` to add method and path to lazy conditions
    def with(*args, &block)
      mock = args.first
      add_condition(mock.to_proc) if mock.is_a? Evil::Client::RSpec::RequestMock
      super
    end

    # Adds a lazy condition for selecting responces
    #
    # @param [Proc] condition
    #   The condition to be satisfied by actual request
    #
    # @return [self] itself
    #
    def where(&condition)
      @conditions ||= []
      @conditions << condition

      self
    end

    # Define a response to be returned
    #
    # @param [Integer] status The status of the response
    # @param [Hash, nil] body The body of the response
    #
    # @return [undefined]
    #
    def and_respond(status, body = nil)
      with_all_conditions.and_return Evil::Client::Response.new(status, body)
    end

    # Reload all finalizers to apply lazy conditions first
    %w(and_call_original and_wrap_original and_yield and_raise and_throw)
      .each do |name|
        define_method(name) do |*args, &block|
          with_all_conditions.super(*args, &block)
        end
      end

    private

    def add_condition(constraint)
      @conditions ||= []
      @conditions << constraint
    end

    def with_all_conditions
      if @conditions.count > 1
        with(satisfy_all @conditions)
      else
        self
      end
    end
  end
end
