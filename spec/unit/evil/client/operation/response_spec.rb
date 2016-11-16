RSpec.describe Evil::Client::Operation::Response do
  let(:response) { [status, {}, ["foo"]] }
  let(:schema) do
    {
      key: :find_user,
      doc: "http://example.com/users",
      responses: {
        success: {
          status:  200,
          coercer: proc { |body| body.upcase.to_sym },
          raise:   false
        },
        error: {
          status:  400,
          coercer: proc { |body| body.upcase.to_sym },
          raise:   true
        }
      }
    }
  end

  subject { described_class.new(schema).handle(response) }

  context "when response status should not cause an exception:" do
    let(:status) { 200 }

    it "returns coerced body" do
      expect(subject).to eq :FOO
    end
  end

  context "when response status should cause an exception:" do
    let(:status) { 400 }

    it "raises ResponseError with coerced response" do
      begin
        subject
      rescue Evil::Client::Operation::ResponseError => error
        expect(error.message).to include "find_user"
        expect(error.data).to eq :FOO
      else
        raise
      end
    end
  end

  context "when response status is unknown:" do
    let(:status) { 404 }

    it "raises UnexpectedResponseError with raw response" do
      begin
        subject
      rescue Evil::Client::Operation::UnexpectedResponseError => error
        expect(error.message).to include "find_user"
        expect(error.message).to include "http://example.com/users"
        expect(error.data).to eq "foo"
        expect(error.status).to eq 404
      else
        raise
      end
    end
  end
end
