module Evil::Client::DSL
  # Nested definition for attached files
  class Files
    # Builds a final upload schema from request options
    #
    # @param  [Hash<Symbol, Object>] options
    # @return [Hash<Symbol, Object>]
    #
    def call(**options)
      @mutex.synchronize do
        @schema = []
        instance_exec(options, &@block)
        @schema
      end
    end

    private

    def initialize(&block)
      @mutex = Mutex.new
      @block = block
    end

    # ==========================================================================
    # Helper methods that mutate files @schema
    # ==========================================================================

    def add(data, type: "text/plain", charset: "utf-8", filename: nil, **)
      @schema << {
        file:     data.respond_to?(:read) ? data : StringIO.new(data),
        type:     MIME::Types[type].first,
        charset:  charset,
        filename: filename
      }
    end
  end
end
