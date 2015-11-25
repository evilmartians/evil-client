describe "plain request", :fake_api do
  before { stub_request :any, /localhost/ }

  let(:client) { Evil::Client.with(base_url: "http://localhost") }
  let(:params) { { baz: :qux } }
  let(:body)   { "baz=qux" }

  context "using method GET" do
    before  { client.get params }
    subject { a_request(:get, "http://localhost?baz=qux") }

    it { is_expected.to have_been_made_with_body "" }
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

  context "using method FOO (arbitrary)" do
    before  { client.request :foo, params }
    subject { a_request(:foo, "http://localhost") }

    it { is_expected.to have_been_made_with_body(body) }
  end

  context "using method FOO (arbitrary) without params" do
    before  { client.request :foo }
    subject { a_request(:foo, "http://localhost") }

    it { is_expected.to have_been_made_with_body("") }
  end
end
