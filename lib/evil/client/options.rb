class Evil::Client
  # Wraps hash of options with railsy methods [#slice] and [#except]
  #
  # Both methods works on the root level only.
  # Nevertheless, this is sufficient to select/reject a part of the whole
  # options collected from the very root of the client.
  #
  class Options < SimpleDelegator
    # Returns a new hash which include only selected keys
    #
    # @param  [Object, Array<Object>] keys
    # @return [Hash]
    #
    def slice(*keys)
      select { |key| keys.flatten.include? key }
    end

    # Returns a new hash where some keys are excluded from
    #
    # @param  [Object, Array<Object>] keys
    # @return [Hash]
    #
    def except(*keys)
      reject { |key| keys.flatten.include? key }
    end
  end
end
