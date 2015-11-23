describe "request", :fake_api do
  before { stub_request :any, /localhost/ }

  let(:client) { Evil::Client.with(base_url: "http://localhost") }

  context "in GET request" do
    before  { client.get "baz" => "qux" }
    subject { a_request(:get, "http://localhost?baz=qux") }

    it { is_expected.to have_been_made_with_body "" }
  end

  context "in POST request" do
    before  { client.post "baz" => "qux" }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body("baz=qux") }
  end

  context "in PATCH request" do
    before  { client.patch "baz" => "qux" }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/baz=qux/) }
    it { is_expected.to have_been_made_with_body(/_method=patch/) }
  end

  context "in PUT request" do
    before  { client.put "baz" => "qux" }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/baz=qux/) }
    it { is_expected.to have_been_made_with_body(/_method=put/) }
  end

  context "in DELETE request" do
    before  { client.delete "baz" => "qux" }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/baz=qux/) }
    it { is_expected.to have_been_made_with_body(/_method=delete/) }
  end

  context "in FOO (arbitrary) request" do
    before  { client.request :foo, "baz" => "qux" }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/baz=qux/) }
    it { is_expected.to have_been_made_with_body(/_method=foo/) }
  end

  context "in FOO (arbitrary) request without params" do
    before  { client.request :foo }
    subject { a_request(:post, "http://localhost") }

    it { is_expected.to have_been_made_with_body(/_method=foo/) }
  end
end
