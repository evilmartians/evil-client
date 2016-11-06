RSpec.describe "instantiation" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  let(:client)    { Test::Client.new subdomain, options }
  let(:subdomain) { "foo" }
  let(:options)   { { version: 3, user: "bar", password: "baz", token: "qux" } }

  context "with valid settings:" do
    it "is accepted" do
      expect(client).to be_kind_of Test::Client
    end
  end

  context "with settings that still conforms to contract:" do
    let(:options) { { user: "bar" } }

    it "is accepted" do
      expect(client).to be_kind_of Test::Client
    end
  end

  context "with unexpected param settings:" do
    let(:client) { Test::Client.new(subdomain, subdomain, **options) }

    it "is rejected" do
      expect { client }.to raise_error(ArgumentError)
    end
  end

  context "with missing param settings:" do
    let(:client) { Test::Client.new(**options) }

    it "is rejected" do
      expect { client }.to raise_error(KeyError)
    end
  end

  context "with a broken contract for param:" do
    let(:subdomain) { 1 }

    it "is rejected" do
      expect { client }.to raise_error(TypeError)
    end
  end

  context "with unexpected option settings:" do
    before { options[:foo] = "bar" }

    it "is accepted" do
      expect { client }.not_to raise_error
    end
  end

  context "with missing option settings:" do
    before { options.delete :user }

    it "is rejected" do
      expect { client }.to raise_error(KeyError)
    end
  end

  context "with a broken contract for option:" do
    before { options[:user] = 1 }

    it "is rejected" do
      expect { client }.to raise_error(TypeError)
    end
  end
end
