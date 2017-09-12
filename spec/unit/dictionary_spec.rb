RSpec.describe Evil::Client::Dictionary do
  shared_examples :a_dictionary do |scope|
    before do
      class Test::Dictionary < String
        def initialize(value)
          super(value.downcase)
        end
      end
    end

    let(:klass) { Test::Dictionary }

    describe "#all (#{scope})" do
      subject { klass.all }

      it "returns all items from a dictionary" do
        expect(subject).to eq %w[one two]
      end
    end

    describe "#each (#{scope})" do
      subject { klass.map(&:reverse) }

      it "iterates over dictionary items" do
        expect(subject).to eq %w[eno owt]
      end
    end

    describe "#call (#{scope})" do
      it "returns dictionary item" do
        expect(klass.call("one")).to eq "one"
      end

      it "raises when the item not in the dictionary" do
        expect { klass.call "ONE" }
          .to raise_error Evil::Client::Dictionary::Error
      end
    end
  end

  it_behaves_like :a_dictionary, "when class extended by the module" do
    before do
      class Test::Dictionary < String
        extend Evil::Client::Dictionary["spec/fixtures/config.yml"]
      end
    end
  end

  it_behaves_like :a_dictionary, "when singleton class includes the module" do
    before do
      class Test::Dictionary < String
        class << self
          include Evil::Client::Dictionary["spec/fixtures/config.yml"]
        end
      end
    end
  end
end
