# @private
module Evil::Client::RSpec
  #
  # Container to chain settings for allowing operation(s)
  #
  class ExpectStub < BaseStub
    def to_have_been_performed
      expect(Evil::Client::Container::Operation)
        .to have_received(:new)
        .with evil_client_schema_matching(@klass, @name),
              *any_args, # logger
              @condition || anything
    end
  end
end
