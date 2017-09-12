class Evil::Client
  #
  # Data structure with validators and memoizers
  #
  class Model
    extend Dry::Initializer

    @policy = Policy

    class << self
      # @!method options(key, type = nil, opts = {})
      # Creates or updates the settings' initializer
      #
      # @see [http://dry-rb.org/gems/dry-initializer]
      #
      # @param       [#to_sym] key        Symbolic name of the option
      # @param       [#call]   type (nil) Type coercer for the option
      # @option opts [#call]   :type      Another way to assign type coercer
      # @option opts [#call]   :default   Proc containing default value
      # @option opts [Boolean] :optional  Whether it can be missed
      # @option opts [#to_sym] :as        The name of settings variable
      # @option opts [false, :private, :protected] :reader Reader method type
      # @return      [self]
      #
      def option(key, type = nil, as: key.to_sym, **opts)
        NameError.check!(as)
        super
        self
      end
      undef_method :param # model initializes with [#options] only

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

      def new(op = {})
        op = Hash(op).each_with_object({}) { |(k, v), obj| obj[k.to_sym] = v }
        super(op).tap { |item| in_english { policy[item].validate! } }
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
  end
end
