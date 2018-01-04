class Evil::Client
  #
  # Base class for policies that validate settings
  #
  class Policy < Tram::Policy
    class << self
      # Subclasses itself for a model class
      #
      # @param  [Class] model Settings class to validate
      # @return [Class]
      #
      def for(model)
        Class.new(self).tap do |klass|
          klass.send :instance_variable_set, :@model, model
        end
      end

      # Reference to the model whose instances are validated by the policy
      #
      # @return [Class, nil]
      #
      attr_reader :model

      # Delegates the name of the policy to the name of checked model
      #
      # @return [String, nil]
      #
      def name
        "#{model}.policy"
      end
      alias_method :to_s,    :name
      alias_method :to_sym,  :name
      alias_method :inspect, :name

      # Redefines translation scope for the policy
      #
      # @return[Array<Symbol>]
      #
      def scope
        @scope ||= %i[evil client errors] << \
                   Tram::Policy::Inflector.underscore(model.to_s).to_sym
      end
    end

    # An instance of settings to be checked by the policy
    param :model

    private

    def respond_to_missing?(name, *)
      model.respond_to?(name)
    end

    def method_missing(*args)
      respond_to_missing?(*args) ? model.__send__(*args) : super
    end
  end
end
