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

        response 200
      end

      operation :example do
        response 201 do |body:, header:, response:|
          [body, header, response]
        end

        response 404, raise: true

        response 422, raise: true do |body:, header:, response:|
          [body, header, response]
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

    expect(subject).to be_kind_of Rack::Response
    expect(subject.headers).to include "foo" => ["BAR"]
    expect(subject.body).to eq ["Hi!"]
  end

  it "applies block to coerce data" do
    stub_request(:get, //).to_return status: 201,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    body, headers, response = subject

    expect(response.headers).to include "foo" => ["BAR"]
    expect(response.body).to eq ["Hi!"]

    expect(body).to eq response.body
    expect(headers).to eq response.headers
  end

  it "raises ResponseError when necessary" do
    stub_request(:get, //).to_return status: 404,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    begin
      subject
    rescue Evil::Client::Operation::ResponseError => error
      expect(error.response).to be_kind_of Rack::Response
      expect(error.response.headers).to include "foo" => ["BAR"]
      expect(error.response.body).to eq ["Hi!"]
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
      body, headers, response = error.response

      expect(response.headers).to include "foo" => ["BAR"]
      expect(response.body).to eq ["Hi!"]

      expect(body).to eq response.body
      expect(headers).to eq response.headers
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
