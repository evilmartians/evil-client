class Evil::Client
  #
  # Validator to be called in context of initialized settings
  #
  class Settings::Validator
    # Performs validation of initialized settings
    #
    # @param [Evil::Client::Settings]
    # @return true
    # @raise [Evil::Client::ValidationError] when a validation fails
    #
    def call(settings)
      if validate!(settings, @block)
        settings&.logger&.debug(self) { "passed for #{settings}" }
        true
      else
        settings&.logger&.error(self) { "failed for #{settings}" }
        raise ValidationError.new(@key, @schema, settings.options)
      end
    end

    # Human-friendly representation of current validator
    #
    # @return [String]
    #
    def to_s
      "#{@schema}.validator[:#{@key}]"
    end
    alias_method :to_str,  :to_s
    alias_method :inspect, :to_s

    private

    def initialize(schema, key, &block)
      check_key!   key
      check_block! block

      @schema = schema
      @key    = key.to_sym
      @block  = block
    end

    def check_key!(key)
      message = if !key.respond_to? :to_sym
                  "Validator should have a symbolic name"
                elsif key.empty?
                  "Validator name should not be empty"
                end

      raise ArgumentError.new(message) if message
    end

    def check_block!(block)
      raise ArgumentError, "You should set block for validation" unless block
    end

    def validate!(settings, block)
      settings.instance_eval(&block) && true
    rescue => error
      settings&.logger&.error(self) { "broken for #{settings} with #{error}" }
      raise
    end
  end
end
