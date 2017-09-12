RSpec.describe Evil::Client::Policy do
  it "subsclasses Tram::Policy" do
    expect(described_class.superclass).to eq Tram::Policy
  end

  it "takes a parameter (settings) to validate" do
    expect(described_class[double]).to be_valid
  end

  it "delegates instance methods to settings" do
    settings = double :settings, foo: :BAR
    policy   = described_class[settings]
    expect(policy.foo).to eq :BAR
  end

  describe ".for" do
    let(:settings) { class_double Evil::Client::Settings, to_s: "Foo" }
    subject { described_class.for settings }

    it "builds a subclass of its own" do
      expect(subject.superclass).to eq described_class
    end

    it "keeps reference to the settings" do
      expect(subject.model).to eq settings
    end

    it "takes the name from settings class" do
      expect(subject.name).to eq "Foo.policy"
    end
  end
end
