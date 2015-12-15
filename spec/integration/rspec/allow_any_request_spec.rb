require "evil/client/rspec"

describe "allow_any_request" do
  let!(:client) { Evil::Client.new "https://localhost/foo" }

  before do
    allow_any_request { client.path(:bar, 1).query(foo: :foo).method(:post) }
      .to_respond_with(200, bar: "foo")

    allow_any_request { client.path(:bar, 1).query(foo: :bar).method(:post) }
      .to_respond_with(200, bar: "bar")

    allow_any_request { client.path(:bar, 1).method(:get) }
      .to_respond_with(400)

    allow_any_request { client.path(:bar, 2).method(:post) }
      .to_respond_with(404)
  end

  it "stubs described requests" do
    response = client.path(:bar, 1).query(foo: "foo", bar: "bar").post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.bar).to eql "foo"
  end

  it "raises when unexpected request has been sent" do
    expect { client.path(:bar, 3).get }.to raise_error(StandardError)
  end

  it "differs requests by data" do
    response = client.path(:bar, 1).query(foo: "bar", baz: "baz").post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.bar).to eql "bar"
  end

  it "differs requests by methods" do
    response = client.path(:bar, 1).query(foo: "bar", baz: "baz").get

    expect(response).to be_kind_of Hashie::Mash
    expect(response.meta.http_code).to eql 400
  end

  it "differs requests by paths" do
    response = client.path(:bar, 2).query(foo: "bar", baz: "baz").post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.meta.http_code).to eql 404
  end
end
