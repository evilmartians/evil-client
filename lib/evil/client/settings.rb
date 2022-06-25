class Evil::Client
  #
  # Container for settings assigned to some operation or scope.
  #
  class Settings < Model
    Names.clean(self) # Remove unnecessary methods from the instance

    class << self
      # Subclasses itself for a given schema
      #
      # @param  [Class] schema
      # @return [Class] a subclass for the schema
      #
      def for(schema)
        Class.new(self).tap do |klass|
          klass.send(:instance_variable_set, :@schema, schema)
        end
      end

      # Reference to the schema klass the settings belongs to
      #
      # @return [Class]
      #
      attr_reader :schema, :locale

      # Human-friendly representation of settings class
      #
      # @return [String]
      #
      def name
        super || @schema.to_s
      end
      alias_method :to_s,    :name
      alias_method :to_str,  :name
      alias_method :inspect, :name

      # Add validation rule to the [#policy]
      #
      # @param [Proc] block  The body of new attribute
      # @return [self]
      #
      def validate(&block)
        policy.validate(&block)
        self
      end

      # Builds settings with options
      #
      # @param  [Logger, nil] logger
      # @param  [Hash<#to_sym, Object>, nil] opts
      # @return [Evil::Client::Settings]
      #
      def new(logger, **op)
        logger&.debug(self) { "initializing with options #{op}..." }
        super(**op).tap do |item|
          item.logger = logger
          logger&.debug(item) { "initialized" }
        end
      end
    end

    # The processed hash of options contained by the instance of settings
    #
    # @return [Hash<Symbol, Object>]
    #
    def options
      @options ||= Options.new self.class.dry_initializer.attributes(self)
    end

    # @!attribute logger
    # @return [Logger, nil] The logger attached to current settings
    attr_accessor :logger

    # DSL helper to format datetimes following RFC7231/RFC2822
    #
    # @see https://tools.ietf.org/html/rfc7231#section-7.1.1.1
    #
    # @param  [Date, String, nil] value Value to be formatted
    # @return [String, nil]
    #
    def datetime(value)
      return unless value

      value = DateTime.parse(value) if value.is_a? String
      value = value.to_datetime     if value.respond_to? :to_datetime
      raise "Cannot convert #{value} to DateTime" unless value.is_a?(DateTime)

      value.rfc2822
    end

    # Human-readable representation of settings instance
    #
    # @return [String]
    #
    def inspect
      number = super.match(/\>\:([^ ]+) /)[1]
      params = options.map { |k, v| "@#{k}=#{v}" }.join(", ")
      number ? "#<#{self.class}:#{number} #{params}>" : super
    end
    alias_method :to_str, :inspect
    alias_method :to_s,   :inspect
  end
end
