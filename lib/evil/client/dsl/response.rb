module Evil::Client::DSL
  # Builds a schema for response processor
  class Response
    extend Dry::Initializer::Mixin
    option :raise,  default: proc { false }
    option :format, default: proc {}
    option :block,  default: proc { nil }
    option :type,   default: proc { nil }

    def self.[](options)
      new(options).to_h
    end

    def to_h
      { raise: raise, coercer: coercer }
    end

    private

    def json?
      format.to_s == "json"
    end

    def arity
      block&.arity
    end

    def coercer
      handlers = [parser, processor, finalizer].compact
      proc { |body| handlers.inject(body) { |obj, handler| handler.call(obj) } }
    end

    def parser
      proc { |body| JSON.parse(body) } if json?
    end

    def processor
      return unless block&.arity == 1
      block
    end

    def addon
      return unless arity == 0
      proc { |klass| klass.instance_eval(&block) }
    end

    def finalizer
      case [type.nil?, addon.nil?]
      when [false, true]  then type
      when [false, false] then Class.new(type).tap(&addon)
      when [true,  false] then Class.new(Evil::Client::Model).tap(&addon)
      end
    end
  end
end
