module Evil::Client::DSL
  class Base
    def self.[](schema, *args, &block)
      new(*args, &block).call(schema)
    end

    def call(schema)
      schema
    end

    private

    def merge(source, target)
      target.inject(source) do |obj, (key, val)|
        obj.merge key => (Hash === val ? merge(obj.fetch(key, {}), val) : val)
      end
    end

    def coercer
      @coercer ||= if    @model && @block then Class.new(@model, &@block)
                   elsif @block           then Class.new(Evil::Struct, &@block)
                   elsif @model           then @model
                   end
    end
  end
end
