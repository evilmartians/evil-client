class Evil::Client
  #
  # Exception to be risen when selected name cannot be used in a custom client.
  #
  class NameError < ::NameError
    # Checks whether a name is valid
    #
    # @param  [#to_sym] name The name to check
    # @param  [Array<Symbol>] forbidden ([]) The list of forbidden names
    # @return [Symbol] if name is valid
    # @raise  [self] if name isn't valid
    #
    def self.check!(name, forbidden = [])
      name = name.to_sym
      return name if name[FORMAT] && !forbidden.include?(name)
      raise new(name, forbidden)
    end

    private

    def initialize(name, forbidden)
      super "Invalid name :#{name}." \
            " It should contain latin letters in the lower case, digits," \
            " and underscores only; have minimum 2 chars;" \
            " start from a letter; end with either letter or digit." \
            " The following names: '#{forbidden.join("', '")}'" \
            " are already used by Evil::Client."
    end

    FORMAT = /^[a-z]([a-z\d_])*[a-z\d]$/
  end
end
