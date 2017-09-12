class Evil::Client
  # Class-level methods
  module Dictionary
    include Enumerable

    # Exception to be risen when item cannot be found in a dictionary
    Error = Class.new(ArgumentError)

    # Filename of config YAML file containing dictionary items
    # @return [String]
    attr_reader :config

    # List of all dictionary items
    # @return [Array<Evil::Client::Dictionary>]
    def all
      @all ||= YAML.load_file(config).map { |item| new(item) }
    end

    # Iterates by dictionary items
    # @return [Enumerator<Evil::Client::Dictionary>]
    def each
      block_given? ? all.each { |item| yield(item) } : all.to_enum
    end

    # Calls the item and raises when it is not in the dictionary
    #
    # @param  [Evil::Client::Dictionary] item
    # @return [Evil::Client::Dictionary]
    # @raise  [Evil::Client::Dictionary::Error]
    #
    def call(item)
      return item if all.include? item
      raise Error, "#{item} is absent in the dictionary #{self}"
    end

    # Alias for [.call]
    #
    # @param  [Evil::Client::Dictionary] item
    # @return [Evil::Client::Dictionary]
    # @raise  [Evil::Client::Dictionary::Error]
    #
    def [](item)
      call(item)
    end

    class << self
      # Builds dictionary from YAML config file
      #
      # @param  [String] filename
      # @return [self]
      #
      def [](filename)
        @config = filename
        self
      end

      private

      def extended(klass)
        super
        klass.send :instance_variable_set, :@config, @config
        @config = nil
      end

      def included(klass)
        super
        klass.class_eval "def config; '#{@config}'; end"
        @config = nil
      end
    end
  end
end
