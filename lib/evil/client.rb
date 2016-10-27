require "dry-initializer"
require "mime-types"
require "rack"

# Absctract base class for clients to remote APIs
#
# @abstract
# @example
#   class MyClient < Evil::Client
#     # declare settings for the client's constructor
#     # the settings parameterize the rest of the client's definitions
#     settings do
#       option :version, type: Dry::Types["strict.int"].default(1)
#       option :user,    type: Dry::Types["strict.string"]
#       option :token,   type: Dry::Types["strict.string"]
#     end
#
#     # define base url of the server
#     base_url do |settings|
#       "https://my_api.com/v#{settings.version}"
#     end
#
#     # define connection and its middleware stack from bottom to top
#     connection :net_http do |settings|
#       run AddCustomRequestId
#       run EncryptToken if settings.token
#     end
#
#     # definitions shared by all operations (can be reloaded later)
#     operation do |settings|
#       type     { :json }
#       security { basic_auth "foo", "bar" }
#     end
#
#     # operation-specific definitions
#     operation :find_cat do |settings|
#       http_method :get
#       path { "#{settings.url}/cats/find/#{id}" }
#
#       query do
#         option :id, type: Dry::Types["coercible.int"].constrained(gt: 0)
#       end
#
#       response 200, model: Cat
#       response 400, raise: true
#       response 422, raise: true do |body:|
#         JSON.parse(body.first)
#       end
#     end
#
#     # top-level DSL for operation
#     scope :users do
#       scope do # named `:[]` by default
#         param :id, type: Dry::Types["strict.int"]
#
#         def get
#           operations[:find_users].call(id: id)
#         end
#       end
#     end
#   end
#
#   # Initialize a client with a corresponding settings
#   client = MyClient.new user: "andrew", token: "f982j23"
#
#   # Use low-level DSL for searching a user
#   client.operations[:find_user].call(id: 1)
#
#   # Use top-level DSL for the same operation
#   client.users[1].get
#
module Evil
  class Client
    require_relative "client/model"
    require_relative "client/connection"
    require_relative "client/middleware"
    require_relative "client/operation"
    require_relative "client/dsl"

    extend  DSL
    include Dry::Initializer.define -> { param :operations }

    # Builds a client instance with custom settings
    def self.new(*settings)
      super finalize(*settings)
    end

    private

    def initialize(schema)
      @operations = \
        schema[:operations].each_with_object({}) do |(key, val), hash|
          hash[key] = Operation.new val, schema[:connection]
        end
    end
  end
end
