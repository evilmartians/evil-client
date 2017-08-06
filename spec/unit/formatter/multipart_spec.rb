RSpec.describe Evil::Client::Formatter::Multipart do
  subject { described_class.call(*parts, boundary: "foobar") }

  let(:parts)     { [string_io, string] }
  let(:string_io) { StringIO.new "Hola!" }
  let(:string)    { "Hello!" }

  it "converts values to multipart body" do
    expect(subject).to eq \
      "\r\n\r\n" \
      "--foobar\r\n" \
      "Content-Disposition: form-data; name=\"Part1\"\r\n" \
      "Content-Type: text/plain; charset=utf-8\r\n" \
      "\r\n" \
      "Hola!\r\n" \
      "--foobar\r\n" \
      "Content-Disposition: form-data; name=\"Part2\"\r\n" \
      "Content-Type: text/plain; charset=utf-8\r\n" \
      "\r\n" \
      "Hello!\r\n" \
      "--foobar--\r\n"
  end
end
