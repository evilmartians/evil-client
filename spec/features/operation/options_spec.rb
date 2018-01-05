RSpec.describe "operation options" do
  before { load "spec/fixtures/test_client.rb" }

  let(:params) { { subdomain: "europe", user: "andy", token: "foo", foo: 0 } }
  let(:users)  { Test::Client.new(params).crm(version: 4).users }

  shared_examples :valid_client do |details = "properly"|
    it "[assigns operation options #{details}]" do
      expect(subject.options).to eq options
    end
  end

  it_behaves_like :valid_client, "with defined options" do
    subject { users.operations[:fetch].new(id: 9, baz: :QUX) }
    let(:options) do
      { subdomain: "europe", user: "andy", token: "foo", version: 4, id: 9 }
    end
  end

  it_behaves_like :valid_client, "with reloaded scope options" do
    subject { users.operations[:fetch].new(id: 9, version: 8) }
    let(:options) do
      { subdomain: "europe", user: "andy", token: "foo", version: 8, id: 9 }
    end
  end

  it_behaves_like :valid_client, "with reloaded root options" do
    subject { users.operations[:fetch].new(id: 9, user: "leo") }
    let(:options) do
      { subdomain: "europe", user: "leo", token: "foo", version: 4, id: 9 }
    end
  end

  it_behaves_like :valid_client, "with operation-specific options" do
    subject { users.operations[:create].new(name: "Joe", language: "en") }
    let(:options) do
      {
        subdomain: "europe",
        user: "andy",
        token: "foo",
        version: 4,
        name: "Joe",
        language: "en"
      }
    end
  end

  context "when required options missed" do
    subject { users.operations[:create].new(language: "it") }

    it "raises StandardError" do
      expect { subject }.to raise_error StandardError, /name/
    end
  end

  context "when operation validation failed" do
    subject { users.operations[:filter].new }

    it "raises StandardError" do
      expect { subject }.to raise_error StandardError, /id/
    end
  end

  context "when scope validation failed" do
    subject { users.operations[:fetch].new id: 8, token: nil }

    it "raises StandardError" do
      expect { subject }.to raise_error StandardError, /token/
    end
  end
end
