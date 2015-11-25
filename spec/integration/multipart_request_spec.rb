describe "multipart request", :fake_api do

  subject do
    stub_request :any, /localhost/
    client.post file: tmpfile, foo: :bar
    a_request(:post, "http://localhost")
  end

  let(:client)  { Evil::Client.with(base_url: "http://localhost") }
  let(:tmpfile) { Tempfile.create("example.txt") }

  it "uses proper headers" do
    expect(subject).to have_been_made_with_headers(
      "Content-Disposition" => "form-data",
      "Content-Type"        => %r{multipart/form-data},
      "Accept"              => "plain/text; application/json"
    )
  end

  it "uses proper body" do
    expect(subject).to have_been_made_with_body(/filename="example\.txt.*"/)
  end

  after do
    tmpfile.close
    File.unlink(tmpfile)
  end
end
