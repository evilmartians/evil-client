module Test
  class Client < Evil::Client
    settings do
      param  :subdomain, type: Dry::Types["strict.string"]
      option :version,   type: Dry::Types["coercible.int"], default: proc { 1 }
      option :user,      type: Dry::Types["strict.string"]
      option :password,  type: Dry::Types["coercible.string"], optional: true
      option :token,     type: Dry::Types["coercible.string"], optional: true
    end

    base_url do |settings|
      "https://#{settings.subdomain}.example.com/api/v#{settings.version}/"
    end
  end
end
