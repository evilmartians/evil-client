require_relative "../../lib/rspec"

describe "stub for rspec" do
  let!(:client) { Evil::Client.with base_url: "https://localhost/foo" }

  before do
    allow_client { client.path(:bar, 1).query(foo: :foo) }
      .to_request(:post)
      .and_respond(200, bar: "foo")

    allow_client { client.path(:bar, 1).query(foo: :bar) }
      .to_request(:post)
      .and_respond(200, bar: "bar")

    allow_client { client.path(:bar, 1) }
      .to_request(:get, foo: :bar)
      .and_respond(400)

    allow_client { client.path(:bar, 2) }
      .to_request(:post)
      .and_respond(404)
  end

  it "stubs described requests" do
    response = client.path(:bar, 1).query(foo: "foo", bar: "bar").post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.bar).to eql "foo"
  end

  it "differs requests by data" do
    response = client.path(:bar, 1).query(foo: "bar", baz: "baz").post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.bar).to eql "bar"
  end

  it "differs requests by types" do
    response = client.path(:bar, 1).query(foo: "bar", baz: "baz").get

    expect(response).to be_kind_of Hashie::Mash
    expect(response.meta.http_code).to eql 400
  end

  it "differs requests by paths" do
    response = client.path(:bar, 2).query(foo: "bar", baz: "baz").post

    expect(response).to be_kind_of Hashie::Mash
    expect(response.meta.http_code).to eql 404
  end

  it "raises when unexpected request has been sent" do
    expect { client.path(:bar, 3).get }.to raise_error(StandardError)
  end
end
