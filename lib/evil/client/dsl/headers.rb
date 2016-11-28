module Evil::Client::DSL
  class Headers < Base
    def call(schema)
      merge schema, headers: coercer
    end

    private

    attr_reader :model, :block

    def initialize(model: Evil::Struct, &block)
      @model = model
      @block = block
    end
  end
end
