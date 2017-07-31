class Evil::Client
  #
  # Exception to be risen when scope or operation cannot be initialized
  # due to some options or their composition are invalid
  #
  class ValidationError < ArgumentError
    private

    def initialize(key, scope = nil, **options)
      scope = "evil.client.errors.#{scope}"
              .split(".")
              .map { |part| __underscore__(part) }

      super key.is_a?(Symbol) ? I18n.t(key, scope: scope, **options) : key
    end

    def __underscore__(name)
      name.dup.tap do |n|
        n.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        n.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        n.gsub!("::", "/")
        n.tr!("-", "_")
        n.downcase!
      end
    end
  end
end
