# @private
module Evil::Client::RSpec
  #
  # Container to chain settings for allowing operation(s)
  #
  class AllowStub < BaseStub
    def to_return(response = nil)
      allow(Evil::Client::Container::Operation)
        .to follow_expectation
        .and_return double(:operation, call: response)
    end

    def to_raise(error = StandardError, *args)
      allow(Evil::Client::Container::Operation)
        .to follow_expectation
        .and_return proc { raise(error, *args) }
    end

    def to_call_original
      allow(Evil::Client::Container::Operation)
        .to follow_expectation
        .and_call_original
    end

    private

    def follow_expectation
      receive(:new).with evil_client_schema_matching(@klass, @name),
                         *any_args, # logger
                         @condition || anything
    end
  end
end
