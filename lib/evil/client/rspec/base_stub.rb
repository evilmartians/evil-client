# @private
module Evil::Client::RSpec
  #
  # Container to chain settings for stubbing operation(s)
  #
  class BaseStub
    include RSpec::Mocks::ExampleMethods
    include RSpec::Matchers

    def with(condition = nil, &block)
      update(condition || block)
    end

    private

    def initialize(klass, name = nil, condition: nil)
      @klass     = klass
      @name      = name
      @condition = condition
    end

    def update(condition)
      self.class.new @klass, @name, condition: condition
    end
  end
end
