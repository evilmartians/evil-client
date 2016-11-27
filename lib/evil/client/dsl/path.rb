module Evil::Client::DSL
  # Adds path settings to the operation's schema
  class Path < Base
    def call(schema)
      merge schema, path: path
    end

    private

    SLASHES = %r{\A/+|/+\z}

    attr_reader :block, :value

    def initialize(value = nil, &block)
      @value = value.to_s.gsub(SLASHES, "")
      @block = block
    end

    def path
      if block then ->(opts) { block.call(opts).to_s.gsub(SLASHES, "") }
      else          ->(_) { value }
      end
    end
  end
end
