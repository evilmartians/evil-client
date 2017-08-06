require "uri"
require "logger"
require "rack"
require "cgi"
require "json"
require "yaml"
require "i18n"
require "mime-types"
require "securerandom"
require "dry-initializer"
require "net/http"
require "net/https"
#
# Namespace for gems created by Evil Martians
#
module Evil
  #
  # Absctract base class for clients to remote APIs
  #
  class Client
    require_relative "client/exceptions/definition_error"
    require_relative "client/exceptions/name_error"
    require_relative "client/exceptions/response_error"
    require_relative "client/exceptions/type_error"
    require_relative "client/exceptions/validation_error"

    require_relative "client/chaining"
    require_relative "client/settings"
    require_relative "client/schema"
    require_relative "client/container"
    require_relative "client/builder"
    require_relative "client/connection"
    require_relative "client/formatter"
    require_relative "client/resolver"

    include Chaining

    class << self
      # Object used as an HTTP(s) connection to remote API
      #
      # It is expected to implement the method [#call] which
      # should take one argument for a rack-compatible request environment,
      # and return a rack-compatible response.
      #
      # By default the connection is set to [Evil::Client::Connection],
      # but it can be redefined for a custom client.
      #
      # @return [#call] connection (Evil::Client::Connection)
      #
      def connection
        @connection ||= Evil::Client::Connection
      end

      # Sets a custom connection, or resets it to a default one
      #
      # @param  [#call, nil] connection
      # @return [self]
      #
      def connection=(connection)
        @connection = connection
        self
      end

      # Schema for the root scope of the client
      #
      # @return [Evil::Client::Schema::Scope]
      #
      def schema
        @schema ||= Schema::Scope.new(self)
      end

      private

      def respond_to_missing?(name, *)
        schema.respond_to? name
      end

      def method_missing(*args, &block)
        respond_to_missing?(*args) ? schema.send(*args, &block) : super
      end
    end

    # Initialized root scope container
    #
    # @return [Evil::Client::Container::Scope]
    #
    attr_reader :scope

    # Logger for the root scope
    #
    # @return (see Evil::Client::Settings#logger)
    #
    def logger
      @scope.logger
    end

    # Sets logger to the client
    #
    # @param  [Logger, nil] logger
    # @return [self]
    #
    def logger=(logger)
      @scope.logger = logger
      self
    end

    # Operations defined at the root of the client
    #
    # @return (see Evil::Client::Container::Scope#operations)
    #
    def operations
      @scope.operations
    end

    # Subscopes of client root
    #
    # @return (see Evil::Client::Container::Scope#scopes)
    #
    def scopes
      @scope.scopes
    end

    # Options assigned to the client
    #
    # @return (see Evil::Client::Container#options)
    #
    def options
      @scope.options
    end

    private

    def initialize(**options)
      @scope = Container::Scope.new self.class.send(:schema), options
    end
  end
end
