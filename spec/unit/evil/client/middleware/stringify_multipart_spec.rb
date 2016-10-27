RSpec.describe Evil::Client::Middleware::StringifyMultipart do
  let(:app)  { double :app }
  let(:type) { "file" }
  let(:env) do
    {
      format:  "multipart",
      headers: {},
      files:   [
        {
          file:     StringIO.new('{"text":"Hello!"}'),
          type:     MIME::Types["application/json"].first,
          charset:  "utf-16",
          filename: "greetings.json"
        }
      ]
    }
  end

  def update!(result)
    @result = result
  end

  before  { allow(app).to receive(:call) { |env| update!(env) } }
  subject { described_class.new(app).call(env) }

  context "with a multipart format:" do
    let(:body_string) { @result[:body_string] }

    it "builds multipart body_string" do
      subject
      expect(body_string).to include '{"text":"Hello!"}'
    end

    it "uses name and filename" do
      subject
      expect(body_string).to include "Content-Disposition: form-data;" \
                                     ' name="AttachedFile1";' \
                                     ' filename="greetings.json"'
    end

    it "uses content-type and charset" do
      subject
      expect(body_string)
        .to include "Content-Type: application/json; charset=utf-16"
    end

    it "adds the header" do
      subject
      expect(@result[:headers]["content-type"])
        .to include "multipart/form-data; boundary="
    end
  end

  context "with non-multipart format:" do
    before { env[:format] = "json" }

    it "does nothing" do
      subject
      expect(@result).to eq env
    end
  end
end
