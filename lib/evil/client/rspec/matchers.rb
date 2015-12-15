# Checks whether a subject sends a request to the client's adapter
#
# @example
#   expect(client).to receive_request.with(
#     method:  :post,
#     path:    "/users",
#     body:    { name: "Andrew" },
#   )
#   client.path(:users).post name: "Andrew"
#
# @api public
#
RSpec::Matchers.define :receive_request do |method, path|

  match do |client|
    strict.update(method: method, path: path)
    adapter = client.adapter

    allow(adapter).to receive(:send_request).and_wrap_original do |m, request|
      expect(request).to be_match_pair(strict, partial)
      m.call(request)
    end

    expect(adapter).to receive(:send_request)
  end

  match_when_negated do |client|
    strict.update(method: method, path: path)
    adapter = client.adapter

    allow(adapter).to receive(:send_request).and_wrap_original do |m, request|
      expect(request).not_to be_match_pair(strict, partial)
      m.call(request)
    end

    expect(adapter)
      .to receive(:send_request)
      .with(be_match_pair strict, partial)
      .exactly(0).times
  end

  chain :with_body do |body = {}|
    strict[:body] ||= {}
    strict[:body].update(body)
  end

  chain :with_query do |query = {}|
    strict[:query] ||= {}
    strict[:query].update(query)
  end

  chain :with_headers do |headers = {}|
    strict[:headers] ||= {}
    strict[:headers].update(headers)
  end

  chain :with_body_including do |body = {}|
    partial[:body] ||= {}
    partial[:body].update(body)
  end

  chain :with_query_including do |query = {}|
    partial[:query] ||= {}
    partial[:query].update(query)
  end

  chain :with_headers_including do |headers = {}|
    partial[:headers] ||= {}
    partial[:headers].update(headers)
  end

  failure_message do |client|
    message(client, true)
  end

  failure_message_when_negated do |client|
    message(client, false)
  end

  def strict
    @strict ||= {}
  end

  def partial
    @partial ||= {}
  end

  def message(client, direct = true)
    req = client.current_request
    path = "#{strict[:method].upcase} #{req.protocol}://#{req.host}:#{req.body}#{strict[:path]}"
    "The request #{path} has #{"not " if direct}been received by the client"
  end
end

# # When this matcher is used in a code below, it changes the subject
# # of the current spec from `client` to `request`! I haven't had any idea why :(
# #
# # Maybe this is the bug in 'rspec/expectations'
# #
# #    expect(adapter)
# #     .to receive(:send_request)
# #     .with(be_match_pair strict, partial)
# #     .exactly(0).times
# #
# RSpec::Matchers.define :match_pair? do |strict, partial|
#   match do |request|
#     request.match?(strict) && request.match?(partial, false)
#   end
# end

class Evil::Client::Request
  # @private
  #
  # This method is added due to strange behaviour of RSpec expectation
  # (see commented method above)
  #
  def match_pair?(strict, partial)
    match?(strict) && match?(partial, false)
  end
end
