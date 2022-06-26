RSpec.describe "scope options" do
  before { load "spec/fixtures/test_client.rb" }

  let(:params) { { subdomain: "europe", user: "andy", token: "foo", foo: 0 } }
  let(:client) { Test::Client.new(**params) }
  let(:crm)    { client.crm(version: 4) }

  shared_examples :valid_client do |details = "properly"|
    it "[assigns scope options #{details}]" do
      expect(subject.options).to eq options
    end
  end

  it_behaves_like :valid_client, "with defined options" do
    subject { crm.users }
    let(:options) do
      { subdomain: "europe", user: "andy", token: "foo", version: 4 }
    end
  end

  it_behaves_like :valid_client, "with reloaded scope options" do
    subject { crm.users(version: 8) }
    let(:options) do
      { subdomain: "europe", user: "andy", token: "foo", version: 8 }
    end
  end

  it_behaves_like :valid_client, "with reloaded root options" do
    subject { crm.users(user: "leo") }
    let(:options) do
      { subdomain: "europe", user: "leo", token: "foo", version: 4 }
    end
  end

  context "when required options missed" do
    subject { client.crm }

    it "raises StandardError" do
      expect { subject }
        .to raise_error StandardError, /version/
    end
  end

  context "when some validation failed" do
    subject { crm.users(token: nil) }

    it "raises StandardError" do
      expect { subject }
        .to raise_error StandardError, /token/
    end
  end
end
