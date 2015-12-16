require "webmock"
require "evil/client/rspec"

describe "test environment" do
  before { stub_request :any, // }

  let(:client) { Evil::Client.new("localhost/foo") }

  it "stubs all requests" do
    expect { client.get }.to raise_error RuntimeError, %r{GET /foo}
  end

  it "does not stub client with tag 'stub_client: false'", stub_client: false do
    expect { client.get }.not_to raise_error
  end
end
