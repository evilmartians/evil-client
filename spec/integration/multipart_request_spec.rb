describe "multipart request", :fake_api do

  subject do
    stub_request :any, /localhost/
    client.post(file: { example: tmpfile }, foo: [:BAR, :BAZ])
    a_request(:post, "http://localhost")
  end

  let(:client)  { Evil::Client.new("http://localhost") }
  let(:tmpfile) { Tempfile.create("example.txt") }

  it "uses proper headers" do
    expect(subject).to have_been_made_with_headers(
      "Content-Type"        => %r{multipart/form-data},
      "Accept"              => "application/json"
    )
  end

  it "uses proper body" do
    expect(subject).to have_been_made_with_body(
      /name=\"file\[example\]\"/,
      /filename="example\.txt.*"/,
      /name=\"foo\[\]\"/,
      /BAR/,
      /BAZ/
    )
  end

  after do
    tmpfile.close
    File.unlink(tmpfile)
  end
end
