RSpec.describe "operation with nested responses" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::User < Evil::Client::Model
      attribute :name
    end

    class Test::Client < Evil::Client
      operation do
        http_method :get
        path { "users" }

        response :success, 200, format: :plain
      end

      operation :example do
        responses format: :plain do
          response :created, 201 do |body|
            body.to_sym
          end

          responses raise: true do
            response :not_found, 404

            response :error, 422 do |body|
              body.to_sym
            end
          end
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
      expect(error.data).to eq "Hi!"
    else
      raise
    end
  end

  it "can raise ResponseError with coercion" do
    stub_request(:get, //).to_return status: 422,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    begin
      subject
    rescue Evil::Client::Operation::ResponseError => error
      expect(error.data).to eq :Hi!
    else
      raise
    end
  end

  it "raises UnexpectedResponseError when a status not expected" do
    stub_request(:get, //).to_return status: 400,
                                     headers: { "Foo" => "BAR" },
                                     body: "Hi!"

    begin
      subject
    rescue Evil::Client::Operation::UnexpectedResponseError => error
      expect(error.data).to eq "Hi!"
    else
      raise
    end
  end
end
