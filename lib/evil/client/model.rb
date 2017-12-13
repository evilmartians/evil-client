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
        lets[key.to_sym] = block

        define_method(key) do
          instance_variable_get(:"@#{key}") ||
            instance_variable_set(:"@#{key}", instance_exec(&block))
        end

        self
      end

      # Definitions for virtual attributes
      #
      # @return [Hash<Symbol, Proc>]
      #
      def lets
        @lets ||= {}
      end

      # Policy object for model instances
      #
      # @return [Evil::Client::Policy]
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

      # Merges [.option]-s, virtual attributes [.let] and [.validation]-s
      # from another model into the current one.
      #
      # @param  [Evil::Client::Model] other
      # @return [self]
      #
      # rubocop: disable Metrics/AbcSize
      def extend(other)
        return super if other.instance_of? Module

        unless other.ancestors.include? Evil::Client::Model
          raise TypeError, "#{other} is not a subclass of Evil::Client::Model"
        end

        other.dry_initializer.options.each do |definition|
          option definition.source, definition.options
        end

        other.lets.each { |key, block| let(key, &block) }
        other.policy.all.each { |validator| policy.local << validator }
      end
      # rubocop: enable Metrics/AbcSize

      # Model instance constructor
      #
      # @param  [Hash] op Model options
      # @return [Evil::Client::Model]
      #
      def new(op = {})
        op = Hash(op).each_with_object({}) { |(k, v), obj| obj[k.to_sym] = v }
        super(op).tap { |item| in_english { policy[item].validate! } }
      rescue StandardError => error
        raise ValidationError, error.message
      end
      alias call new
      alias []   call

      private

      def in_english(&block)
        unless I18n.available_locales.include?(:en)
          available_locales = I18n.available_locales
          I18n.available_locales += %i[en]
        end
        I18n.with_locale(:en, &block)
      ensure
        I18n.available_locales = available_locales if available_locales
      end
    end
  end
end
