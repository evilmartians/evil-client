describe "plain request", :fake_api do
  before { stub_request :any, /localhost/ }

  let(:client) { Evil::Client.new("http://localhost") }
  let(:params) { { foo: { bar: ["баз", 1] } } }
  let(:body)   { "foo[bar][]=%D0%B1%D0%B0%D0%B7&foo[bar][]=1" }

  context "using method GET" do
    before  { client.get params }
    subject { a_request(:get, "http://localhost?#{body}") }

    it { is_expected.to have_been_made_with_body(nil) }
  end

  context "using method POST" do
    before  { client.post params }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body(body) }
  end

  context "using method PATCH" do
    before  { client.patch params }
    subject { a_request(:patch, "http://localhost") }

    it { is_expected.to have_been_made_with_body(body) }
  end

  context "using method PUT" do
    before  { client.put params }
    subject { a_request(:put, "http://localhost") }

    it { is_expected.to have_been_made_with_body(body) }
  end

  context "using method DELETE" do
    before  { client.delete params }
    subject { a_request(:delete, "http://localhost") }

    it { is_expected.to have_been_made_with_body(body) }
  end

  context "using method HEAD (arbitrary)" do
    before  { client.request :head }
    subject { a_request(:head, "http://localhost") }

    it { is_expected.to have_been_made }
  end
end
