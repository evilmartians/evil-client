class Evil::Client
  # Class-level methods
  module Dictionary
    include Enumerable

    Error = Class.new(ArgumentError)

    attr_reader :config

    def all
      @all ||= YAML.load_file(config).map { |item| new(item) }
    end

    def each
      block_given? ? all.each { |item| yield(item) } : all.to_enum
    end

    def call(item)
      return item if all.include? item
      raise Error, "#{item} is absent in the dictionary #{self}"
    end

    def [](item)
      call(item)
    end

    class << self
      def [](value)
        @config = value
        self
      end

      private

      def extended(klass)
        super
        klass.send :instance_variable_set, :@config, @config
      end

      def included(klass)
        super
        klass.class_eval "def config; '#{@config}'; end"
      end
    end
  end
end
