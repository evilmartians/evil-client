RSpec.describe Evil::Client::RSpec, "#expect_client_operation" do
  include described_class
  before { load "spec/fixtures/test_client.rb" }
  before { stub_client_operation.to_return }

  let(:client)  { Test::Client.new(subdomain: "x", user: "y", token: "z") }
  let(:perform) { client.crm(version: 7).users.fetch id: 5 }

  before { perform }

  context "with client class" do
    let(:klass) { Test::Client }

    it "passes" do
      expect { expect_client_operation(klass).to_have_been_performed }
        .not_to raise_error
    end
  end

  context "with client's superclass" do
    let(:klass) { Evil::Client }

    it "passes" do
      expect { expect_client_operation(klass).to_have_been_performed }
        .not_to raise_error
    end
  end

  context "with neither a client nor its superclass" do
    let(:klass) { String }

    it "fails" do
      expect { expect_client_operation(klass).to_have_been_performed }
        .to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end

  context "with client class and fully qualified name" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }

    it "passes" do
      expect do
        expect_client_operation(klass, name).to_have_been_performed
      end.not_to raise_error
    end
  end

  context "with client class and underqualified name" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users" }

    it "fails" do
      expect do
        expect_client_operation(klass, name).to_have_been_performed
      end.to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end

  context "with client class and partially qualified name" do
    let(:klass) { Test::Client }
    let(:name)  { /crm\.users/ }

    it "passes" do
      expect do
        expect_client_operation(klass, name).to_have_been_performed
      end.not_to raise_error
    end
  end

  context "with client class and wrongly qualified name" do
    let(:klass) { Test::Client }
    let(:name)  { /^crm.users$/ }

    it "fails" do
      expect do
        expect_client_operation(klass, name).to_have_been_performed
      end.to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end

  context "with client class and expected options" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }
    let(:opts) do
      { subdomain: "x", user: "y", token: "z", version: 7, id: 5 }
    end

    it "passes" do
      expect do
        expect_client_operation(klass, name)
          .with(opts)
          .to_have_been_performed
      end.not_to raise_error
    end
  end

  context "with client class and block expectation" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }
    let(:opts) do
      { subdomain: "x", user: "y", token: "z", version: 7, id: 5 }
    end

    it "passes" do
      expect do
        expect_client_operation(klass, name)
          .with { |o| o == opts }
          .to_have_been_performed
      end.not_to raise_error
    end
  end

  context "with client class and overexpected options" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }
    let(:opts) do
      { subdomain: "x", user: "y", token: "z", version: 7 }
    end

    it "fails" do
      expect do
        expect_client_operation(klass, name)
          .with { |o| o == opts }
          .to_have_been_performed
      end.to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end

  context "with client class and partially expected options" do
    let(:klass) { Test::Client }
    let(:name)  { "crm.users.fetch" }
    let(:opts)  { hash_including subdomain: "x" }

    it "passes" do
      expect do
        expect_client_operation(klass, name)
          .with(opts)
          .to_have_been_performed
      end.not_to raise_error
    end
  end
end
