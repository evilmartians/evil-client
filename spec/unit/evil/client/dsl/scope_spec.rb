RSpec.describe Evil::Client::DSL, ".scope" do
  before do
    class Test::Foo
      extend Evil::Client::DSL

      scope :foo do
        param :bar

        scope do
          param :baz

          def find
            qux(bar: bar, baz: baz)
          end
        end
      end

      def qux(bar:, baz:)
        "#{bar}/#{baz}"
      end
    end
  end

  let(:client) { Test::Foo.new }
  subject { client.foo("users")[54].find }

  it "provides access to params and methods via nested scopes" do
    expect(subject).to eq "users/54"
  end
end
