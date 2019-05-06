RSpec.describe "operation request" do
  before { load "spec/fixtures/test_client.rb" }
  before { stub_request(:any, //) }

  let(:users) do
    Test::Client.new(subdomain: "europe", user: "andy", password: "foo")
                .crm(version: 4)
                .users
  end

  shared_examples :valid_client do |details = "properly"|
    let(:request) { a_request(meth, path).with(body: body, headers: head) }

    it "[builds a request #{details}]" do
      subject
      expect(request).to have_been_made
    end
  end

  it_behaves_like :valid_client do
    subject    { users.fetch id: 87 }

    let(:path) { "https://europe.example.com/crm/v4/users/87" }
    let(:meth) { :get }
    let(:body) { nil }
    let(:head) { { "Content-Type" => "application/json" } }
  end

  it_behaves_like :valid_client, "using current definition" do
    subject    { users.filter id: 89 }

    let(:path) { "https://europe.example.com/crm/v4/users" }
    let(:meth) { :get }
    let(:body) { nil }
    let(:head) { { "Content-Type" => "application/json" } }
  end

  it_behaves_like :valid_client, "with a proper query" do
    subject    { users.create id: 89, name: "Andy", language: :de }

    let(:path) { "https://europe.example.com/crm/v4/users?language=de" }
    let(:meth) { :post }
    let(:body) { '{"name":"Andy"}' }
    let(:head) do
      {
        "Authorization" => "Basic YW5keTpmb28=",
        "Content-Type" => "application/json"
      }
    end
  end

  it_behaves_like :valid_client, "with a proper query" do
    subject    { users.create id: 89, name: "Andy", language: :de }

    let(:path) { "https://europe.example.com/crm/v4/users?language=de" }
    let(:meth) { :post }
    let(:body) { '{"name":"Andy"}' }
    let(:head) do
      {
        "Authorization" => "Basic YW5keTpmb28=",
        "Content-Type" => "application/json"
      }
    end
  end

  it_behaves_like :valid_client, "using current settings" do
    subject    { users.update id: 89, name: "Joe", language: "it" }

    let(:path) { "https://europe.example.com/crm/v4/users/89?language=it" }
    let(:meth) { :patch }
    let(:body) { '{"name":"Joe"}' }
    let(:head) { {} }
    let(:head) do
      {
        "Authorization" => "Basic YW5keTpmb28=",
        "Content-Type" => "application/json"
      }
    end
  end

  it_behaves_like :valid_client, "using reloaded settings" do
    subject    { users.update id: 89, name: "Joe", language: "it", version: 0 }

    let(:path) { "https://europe.example.com/crm/v0/users/89?language=it" }
    let(:meth) { :put }
    let(:body) { "name=Joe" }
    let(:head) do
      {
        "Authorization" => "Basic YW5keTpmb28=",
        "Content-Type" => "application/x-www-form-urlencoded"
      }
    end
  end
end
