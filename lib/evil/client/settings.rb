class Evil::Client
  #
  # Container for settings assigned to some operation or scope.
  #
  class Settings
    Names.clean(self) # Remove unnecessary methods from the instance
    extend ::Dry::Initializer

    @policy = Policy

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

      # Only options can be defined for the settings container
      # @private
      def param(*args)
        option(*args)
      end

      # Creates or updates the settings' initializer
      #
      # @see [http://dry-rb.org/gems/dry-initializer]
      #
      # @param       [#to_sym] key       Symbolic name of the option
      # @param       [#call]   type      Type coercer for the option
      # @option opts [#call]   :type     Another way to assign type coercer
      # @option opts [#call]   :default  Proc containing default value
      # @option opts [Boolean] :optional Whether it can be missed
      # @option opts [#to_sym] :as       The name of settings variable
      # @option opts [false, :private, :protected] :reader Reader method type
      # @return      [self]
      #
      def option(key, type = nil, as: key.to_sym, **opts)
        NameError.check!(as)
        super
        self
      end

      # Creates or reloads memoized attribute
      #
      # @param [#to_sym] key The name of the attribute
      # @param [Proc] block  The body of new attribute
      # @return [self]
      #
      def let(key, &block)
        NameError.check!(key)
        define_method(key) do
          instance_variable_get(:"@#{key}") ||
            instance_variable_set(:"@#{key}", instance_exec(&block))
        end
        self
      end

      # Policy class that collects all the necessary validators
      #
      # @return [Class] a subclass of [Tram::Policy] named after the scope
      #
      def policy
        @policy ||= superclass.policy.for(self)
      end

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
      def new(logger, opts = {})
        logger&.debug(self) { "initializing with options #{opts}..." }
        opts = Hash(opts).each_with_object({}) { |(k, v), o| o[k.to_sym] = v }
        in_english { super logger, opts }
      rescue => error
        raise ValidationError, error.message
      end

      private

      def in_english(&block)
        available_locales = I18n.available_locales
        I18n.available_locales = %i[en]
        I18n.with_locale(:en, &block)
      ensure
        I18n.available_locales = available_locales
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

    private

    def initialize(logger, **options)
      super(options)
      @logger = logger
      self.class.policy[self].validate!
      logger&.debug(self) { "initialized" }
    end
  end
end
