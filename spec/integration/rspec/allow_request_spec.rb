require "evil/client/rspec"

describe "allow_request" do
  let(:client)  { Evil::Client.new "https://localhost/foo" }
  let(:request) { client.path(:bar, 1).query(foo: :foo).method(:post) }

  before do
    allow_any_request { request }
      .to_respond_with(200, foo: "bar")

    allow_request { request }
      .to_respond_with(200, foo: "foo")
  end

  it "stubs requests before partials regardless of declaration order" do
    response = request.post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.foo).to eql "foo"
  end

  it "ignores requests with different query" do
    response = request.query(bar: :bar).post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.foo).to eql "bar"
  end

  it "ignores requests with different body" do
    response = request.body(bar: :bar).post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.foo).to eql "bar"
  end

  it "ignores requests with different headers" do
    response = request.headers(Bar: :Bar).post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.foo).to eql "bar"
  end
end
