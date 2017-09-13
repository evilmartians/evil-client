class Evil::Client
  # Class-level methods
  module Dictionary
    include Enumerable

    # Exception to be risen when item cannot be found in a dictionary
    Error = Class.new(ArgumentError)

    # Raw data for the dictionary items
    # @return [String]
    def raw
      @raw ||= []
    end

    # List of the dictionary items
    # @return [Array<Evil::Client::Dictionary>]
    def all
      @all ||= raw.map { |item| new(item) }
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
      # Loads [#raw] dictionary from YAML config file
      #
      # @param  [String] path
      # @return [self]
      #
      def [](path)
        file, paths = path.to_s.split("#")
        list = YAML.load_file(file)
        keys = paths.to_s.split("/").map(&:to_sym)
        @raw = keys.any? ? Hash(list).dig(*keys) : list
        self
      end

      private

      def extended(klass)
        super
        klass.send :instance_variable_set, :@raw, @raw.to_a
        @raw = nil
      end

      def included(klass)
        super
        klass.send :define_method, :raw, &@raw.method(:to_a)
        @raw = nil
      end
    end
  end
end
