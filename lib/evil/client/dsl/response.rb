module Evil::Client::DSL
  # Builds a schema for response processor
  class Response
    extend Dry::Initializer::Mixin
    param  :status
    option :raise,  default: proc { false }
    option :format, default: proc {}
    option :model,  default: proc { nil }
    option :block,  default: proc { nil }

    def self.[](*args)
      new(*args).to_h
    end

    def to_h
      { status: status.to_i, coercer: coercer, raise: raise }
    end

    private

    def json?
      format.to_s == "json"
    end

    def arity
      block&.arity
    end

    def coercer
      handlers = [parser, processor, wrapper, finalizer].compact
      proc { |body| handlers.inject(body) { |obj, handler| handler.call(obj) } }
    end

    def parser
      proc { |body| JSON.parse(body) } if json?
    end

    def wrapper
      return unless json?
      proc { |data| Hash === data ? data : { data: data } }
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
      case [model.nil?, addon.nil?]
      when [false, true]  then model
      when [false, false] then Class.new(model).tap(&addon)
      when [true,  false] then Class.new(Evil::Client::Model).tap(&addon)
      else nil
      end
    end
  end
end
