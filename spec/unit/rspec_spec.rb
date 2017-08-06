RSpec.describe "rspec matcher :perform_operation" do
  before { load "spec/fixtures/test_client.rb" }

  let(:client) { Test::Client.new(subdomain: "foo", user: "bar", token: "baz") }
  let(:users)  { client.crm(version: 7).users }

  let(:fetch)    { users.fetch id: 5 }
  let(:update_7) { users.update id: 5, name: "Joe", language: "en" }
  let(:update_8) { users.update id: 5, name: "Joe", language: "en", version: 8 }

  let(:name)  { "Test::Client.crm.users.update" }
  let(:block) { proc { |version:, **| version == 7 } }

  describe "base matcher" do
    context "in a positive check" do
      subject { expect { code }.to perform_operation(name) }

      context "when operaton with expected name was performed" do
        let(:code) { fetch; update_7 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when operation with expected name wasn't performed" do
        let(:code) { fetch }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end
    end

    context "in a negative check" do
      subject { expect { code }.not_to perform_operation(name) }

      context "when operaton with expected name was performed" do
        let(:code) { fetch; update_7 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when operation with expected name wasn't performed" do
        let(:code) { fetch }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end
    end
  end

  describe "block argument" do
    context "in a positive check" do
      subject { expect { code }.to perform_operation(name, &block) }

      context "when operaton with expected name/options was performed" do
        let(:code) { fetch; update_7 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when options differ from expected" do
        let(:code) { fetch; update_8 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when operation wasn't performed" do
        let(:code) { fetch }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end
    end

    context "in a negagive check" do
      subject { expect { code }.not_to perform_operation(name, &block) }

      context "when operaton with expected name/options was performed" do
        let(:code) { fetch; update_7 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when options differ from expected" do
        let(:code) { fetch; update_8 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when operation wasn't performed" do
        let(:code) { fetch }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end
    end
  end

  describe "#with modifier" do
    let(:opts) { { version: 7 } }

    context "in a positive check" do
      subject { expect { code }.to perform_operation(name).with(opts) }

      context "when operaton with expected name/options was performed" do
        let(:code) { fetch; update_7 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when options differ from expected" do
        let(:code) { fetch; update_8 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when operation wasn't performed" do
        let(:code) { fetch }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end
    end

    context "in a negative check" do
      subject { expect { code }.not_to perform_operation(name).with(opts) }

      context "when operaton with expected name/options was performed" do
        let(:code) { fetch; update_7 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when options differ from expected" do
        let(:code) { fetch; update_8 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when operation wasn't performed" do
        let(:code) { fetch }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end
    end
  end

  describe "#with_exactly modifier" do
    let(:opts) do
      {
        id:        5,
        language:  "en",
        name:      "Joe",
        subdomain: "foo",
        token:     "baz",
        user:      "bar",
        version:   7
      }
    end

    context "in a positive check" do
      subject { expect { code }.to perform_operation(name).with_exactly(opts) }

      context "when operaton with expected name/options was performed" do
        let(:code) { fetch; update_7 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when some options differ from expected" do
        let(:code) { fetch; update_8 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when some options are not expected" do
        before { opts.delete :version }
        let(:code) { fetch; update_7 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when operation wasn't performed" do
        let(:code) { fetch }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end
    end

    context "in a negative check" do
      subject do
        expect { code }.not_to perform_operation(name).with_exactly(opts)
      end

      context "when operaton with expected name/options was performed" do
        let(:code) { fetch; update_7 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when some options differ from expected" do
        let(:code) { fetch; update_8 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when some options are not expected" do
        before { opts.delete :version }
        let(:code) { fetch; update_7 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when operation wasn't performed" do
        let(:code) { fetch }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end
    end
  end

  describe "#without modifier" do
    context "in a positive check" do
      subject { expect { code }.to perform_operation(name).without(opts) }

      context "when operaton without options was performed" do
        let(:opts) { %i[phone] }
        let(:code) { fetch; update_7 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when operation contains a forbidden option" do
        let(:opts) { %i[id] }
        let(:code) { fetch; update_7 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when operation wasn't performed" do
        let(:opts) { %i[phone] }
        let(:code) { fetch }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end
    end

    context "in a negative check" do
      subject { expect { code }.not_to perform_operation(name).without(opts) }

      context "when operaton without options was performed" do
        let(:opts) { %i[phone] }
        let(:code) { fetch; update_7 }

        it "fails" do
          expect { subject }
            .to raise_error RSpec::Expectations::ExpectationNotMetError
        end
      end

      context "when operation contains a forbidden option" do
        let(:opts) { %i[id] }
        let(:code) { fetch; update_7 }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end

      context "when operation wasn't performed" do
        let(:opts) { %i[phone] }
        let(:code) { fetch }

        it "passes" do
          expect { subject }.not_to raise_error
        end
      end
    end
  end
end
