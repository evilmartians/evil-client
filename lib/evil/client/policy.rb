class Evil::Client
  #
  # Base class for policies that validate settings
  #
  class Policy < Tram::Policy
    class << self
      # Subclasses itself for a settings class
      #
      # @param  [Class] settings Settings class to validate
      # @return [Class]
      #
      def for(settings)
        Class.new(self).tap do |klass|
          klass.send :instance_variable_set, :@settings, settings
        end
      end

      # Reference to the settings class whose instances validates the policy
      #
      # @return [Class, nil]
      #
      attr_reader :settings

      # Delegates the name of the policy to the name of checked settings
      #
      # @return [String, nil]
      #
      def name
        "#{settings}.policy"
      end
      alias_method :to_s,    :name
      alias_method :to_sym,  :name
      alias_method :inspect, :name

      private

      def scope
        @scope ||= %i[evil client errors] << \
                   Tram::Policy::Inflector.underscore(settings.to_s)
      end
    end

    # An instance of settings to be checked by the policy
    param :settings

    private

    def respond_to_missing?(name, *)
      settings.respond_to?(name)
    end

    def method_missing(*args)
      respond_to_missing?(*args) ? settings.__send__(*args) : super
    end
  end
end
