module Evil::Client::DSL
  class HttpMethod < Base
    def call(schema)
      merge schema, method: http_method
    end

    private

    attr_reader :block, :string

    def initialize(string = nil, &block)
      @string = string.to_s.downcase
      @block  = block
    end

    def http_method
      if block
        ->(opts) { block.call(opts).to_s.downcase }
      else
        proc { string }
      end
    end
  end
end
