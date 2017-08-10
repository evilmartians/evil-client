class Evil::Client
  #
  # Utility to remove unnecessary methods from instances
  # to clear a namespace
  # @private
  #
  module Names
    extend self

    # Removes unused instance methods inherited from [Object] from given class
    #
    # @param  [Class] klass
    # @return [nil]
    #
    def clean(klass)
      (klass.instance_methods - BasicObject.instance_methods - FORBIDDEN)
        .each { |m| klass.send(:undef_method, m) if m[FORMAT] } && nil
    end

    # List of preserved methods.
    # They also couldn't be used as names of operations/scopes/options
    # to avoid name conflicts.
    FORBIDDEN = %i[
      basic_auth
      class
      datetime
      hash
      inspect
      instance_exec
      instance_variable_get
      instance_variable_set
      key_auth
      logger
      logger
      object_id
      operation
      operations
      options
      schema
      scope
      scopes
      self
      send
      settings
      singleton_class
      to_s
      to_str
      token_auth
    ].freeze

    # Matches whether a name can be used in operations/scopes/options
    FORMAT = /^[a-z]([a-z\d_])*[a-z\d]$/
  end
end
