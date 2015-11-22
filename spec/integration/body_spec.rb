describe "body", :fake_api do
  before { %i(get post).each { |type| stub_request type, %r{localhost} } }

  let(:client) { Evil::Client.with(base_url: "http://localhost") }

  context "in POST request" do
    before  { client.post! baz: :qux }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/baz=qux/) }
  end

  context "in FOO (arbitrary) request" do
    before  { client.foo! baz: :qux }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/baz=qux/) }
    it { is_expected.to have_been_made_with_body(/_method=foo/) }
  end
end
