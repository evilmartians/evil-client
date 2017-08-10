# @private
module Evil::Client::RSpec
  #
  # Checks whether an operation schema matches klass and name
  #
  # @example
  #   expect(schema).to evil_client_schema_matching(MyClient, /users/)
  #
  ::RSpec::Matchers.define :evil_client_schema_matching do |klass, name = nil|
    match do |schema|
      expect(schema).to be_instance_of(Evil::Client::Schema::Operation)
      expect(schema.client.ancestors).to include(klass)

      case name
      when NilClass then true
      when Regexp   then schema.to_s[name]
      else          schema.to_s == "#{klass}.#{name}"
      end
    end
  end
end
