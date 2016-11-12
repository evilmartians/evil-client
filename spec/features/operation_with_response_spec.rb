RSpec.describe "operation with query" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::User < Evil::Client::Model
      attribute :name
    end

    class Test::Client < Evil::Client
      operation do
        http_method :get
        path { "users" }

        response 200, format: :plain
      end

      operation :example do
        response 201, format: :plain do |body|
          body.to_sym
        end

        response 404, raise: true, format: :plain

        response 422, raise: true, format: :plain do |body|
          body.to_sym
        end
      end
    end
  end

  let(:client) { Test::Client.new "foo", user: "bar", version: 3, token: "baz" }

  subject { client.operations[:example].call }

  it "takes default setting" do
    stub_request(:get, //).to_return status: 200,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    expect(subject).to eq "Hi!"
  end

  it "applies block to coerce data" do
    stub_request(:get, //).to_return status: 201,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    expect(subject).to eq :Hi!
  end

  it "raises ResponseError when necessary" do
    stub_request(:get, //).to_return status: 404,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    begin
      subject
    rescue Evil::Client::Operation::ResponseError => error
      expect(error.response).to eq "Hi!"
    else
      fail
    end
  end

  it "can raise ResponseError with coercion" do
    stub_request(:get, //).to_return status: 422,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    begin
      subject
    rescue Evil::Client::Operation::ResponseError => error
      expect(error.response).to eq :Hi!
    else
      fail
    end
  end

  it "raises UnexpectedResponseError when a status not expected" do
    stub_request(:get, //).to_return status: 400,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    begin
      subject
    rescue Evil::Client::Operation::UnexpectedResponseError => error
      expect(error.response).to be_kind_of Rack::Response
      expect(error.response.headers).to include "foo" => ["BAR"]
      expect(error.response.body).to eq ["Hi!"]
    else
      fail
    end
  end
end
