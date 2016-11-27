module Evil::Client::DSL
  class Query < Base
    def call(schema)
      merge schema, query: coercer
    end

    private

    attr_reader :model, :block

    def initialize(model: nil, &block)
      @model = model
      @block = block
    end
  end
end
