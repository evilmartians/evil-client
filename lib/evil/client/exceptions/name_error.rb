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
    def self.check!(name)
      name = name.to_sym
      return name if name[Names::FORMAT] && !Names::FORBIDDEN.include?(name)
      raise new(name)
    end

    private

    def initialize(name)
      super "Invalid name :#{name}." \
            " It should contain latin letters in the lower case, digits," \
            " and underscores only; have minimum 2 chars;" \
            " start from a letter; end with either letter or digit." \
            " The following names: '#{Names::FORBIDDEN.join("', '")}'" \
            " are already used by Evil::Client."
    end
  end
end
