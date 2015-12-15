# Checks whether a subject sends a request to the client's adapter
#
# @example
#   expect { some_action }
#     .to send_request_to(client)
#     .with(
#       method:   :post,
#       path:     "/users",
#       query:    { auth: "foobar" },
#       body:     { name: "Andrew" },
#       headers:  { "X-Password" => "barbaz" }
#     )
#
# @api public
#
RSpec::Matchers.define :send_request_to do |client|
  supports_block_expectations

  adapter = client.adapter

  match do |action|
    allow(adapter).to receive(:send_request).and_wrap_original do |m, request|
      expect(request).to be_match(options)
      m.call(request)
    end

    expect(adapter).to receive(:send_request)

    action.call
  end

  match_when_negated do |action|
    allow(adapter).to receive(:send_request).and_wrap_original do |m, request|
      expect(request).not_to be_match(options)
      m.call(request)
    end

    expect(adapter)
      .to receive(:send_request)
      .with(be_match options)
      .exactly(0).times

    action.call
  end

  chain :with do |opts = {}|
    opts.each do |key, value|
      if [:body, :query, :headers].include? key
        options[key] ||= {}
        options[key].update(value)
      else
        options.update(key => value)
      end
    end
  end

  chain :with_method do |method|
    with(method: method)
  end

  chain :with_path do |path|
    with(path: path)
  end

  chain :with_body do |body = {}|
    with(body: body)
  end

  chain :with_query do |query = {}|
    with(query: query)
  end

  chain :with_headers do |headers = {}|
    with(headers: headers)
  end

  req = client.current_request
  root_path = "#{req.protocol}://#{req.host}:#{req.body}"

  failure_message do |_|
    string = " with options #{options}" unless options.empty?
    "The client of #{root_path} has not received the request#{string}"
  end

  failure_message_when_negated do |_|
    string = " with options #{options}" unless options.empty?
    "The client of #{root_path} has received the request#{string}"
  end

  def options
    @options ||= {}
  end
end
