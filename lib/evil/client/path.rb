class Evil::Client
  # Relative paths builder
  #
  # @api private
  #
  class Path
    # Returns a new instance of the class with a part added to the path
    #
    # @param [#to_s] part
    #
    # @return [Evil::Client::Path]
    #
    def [](part)
      new_path = @path ? [@path, part].join("/") : part
      dup.tap { |instance| instance.instance_eval { @path = new_path } }
    end

    # Returns the resulting relative path
    #
    # @return [String]
    #
    def to_s
      @path
    end
  end
end
