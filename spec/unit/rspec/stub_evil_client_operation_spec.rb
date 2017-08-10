RSpec.describe Evil::Client::RSpec, "#stub_evil_client_operation" do
  include described_class
  before { load "spec/fixtures/test_client.rb" }

  let(:client)  { Test::Client.new(subdomain: "x", user: "y", token: "z") }
  let(:perform) { client.crm(version: 7).users.fetch id: 5 }

  context "with client class" do
    let(:klass) { Test::Client }

    it "stubs the call with nil" do
      stub_evil_client_operation(klass).to_return nil

      expect(perform).to be_nil
    end

    it "stubs the call with any object" do
      result = double
      stub_evil_client_operation(klass).to_return result

      expect(perform).to eq result
    end

    it "stubs the call with the original implementation" do
      stub_evil_client_operation(klass).to_call_original

      expect(perform).to eq [200, {}, []]
    end

    it "stubs the call with StandardError" do
      stub_evil_client_operation(klass).to_raise

      expect { perform }.to raise_error StandardError
    end

    it "stubs the call with an exception of given type" do
      stub_evil_client_operation(klass).to_raise(TypeError)

      expect { perform }.to raise_error TypeError
    end

    it "stubs the call with given exception" do
      stub_evil_client_operation(klass).to_raise(TypeError, "foobar")

      expect { perform }.to raise_error TypeError, /foobar/
    end
  end

  context "with client's superclass" do
    let(:klass) { Evil::Client }

    it "stubs the call" do
      stub_evil_client_operation(klass).to_return
      expect(perform).to be_nil
    end
  end

  context "without params" do
    it "stubs the call" do
      stub_evil_client_operation.to_return
      expect(perform).to be_nil
    end
  end

  context "with neither a client nor its superclass" do
    let(:klass) { String }

    it "don't stubs the call" do
      stub_evil_client_operation(klass).to_return
      expect { perform }.to raise_error RSpec::Mocks::MockExpectationError
    end
  end

  context "with client class and fully qualified name" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }

    it "stubs the call" do
      stub_evil_client_operation(klass, name).to_return
      expect(perform).to be_nil
    end
  end

  context "with client class and underqualified name" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users" }

    it "don't stubs the call" do
      stub_evil_client_operation(klass, name).to_return
      expect { perform }.to raise_error RSpec::Mocks::MockExpectationError
    end
  end

  context "with client class and partially qualified name" do
    let(:klass) { Test::Client }
    let(:name)  { /crm\.users/ }

    it "stubs the call" do
      stub_evil_client_operation(klass, name).to_return
      expect(perform).to be_nil
    end
  end

  context "with client class and wrongly qualified name" do
    let(:klass) { Test::Client }
    let(:name)  { /^crm.users$/ }

    it "don't stubs the call" do
      stub_evil_client_operation(klass, name).to_return
      expect { perform }.to raise_error RSpec::Mocks::MockExpectationError
    end
  end

  context "with client class and expected options" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }
    let(:opts) do
      { subdomain: "x", user: "y", token: "z", version: 7, id: 5 }
    end

    it "stubs the call" do
      stub_evil_client_operation(klass, name).with(opts).to_return
      expect(perform).to be_nil
    end
  end

  context "with client class and block expectation" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }
    let(:opts) do
      { subdomain: "x", user: "y", token: "z", version: 7, id: 5 }
    end

    it "stubs the call" do
      stub_evil_client_operation(klass, name).with { |o| o == opts }.to_return
      expect(perform).to be_nil
    end

    it "stubs the call to any returned value" do
      stub_evil_client_operation(klass, name).with { |o| true }.to_return 42
      expect(perform).to eq 42
    end
  end

  context "with client class and overexpected options" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }
    let(:opts) do
      { subdomain: "x", user: "y", token: "z", version: 7 }
    end

    it "don't stubs the call" do
      stub_evil_client_operation(klass, name).with { |o| o == opts }.to_return
      expect { perform }.to raise_error RSpec::Mocks::MockExpectationError
    end
  end

  context "with client class and partially expected options" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }
    let(:opts)  { hash_including subdomain: "x" }

    it "stubs the call" do
      stub_evil_client_operation(klass, name).with(opts).to_return
      expect(perform).to be_nil
    end
  end
end
