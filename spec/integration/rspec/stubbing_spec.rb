describe "stubbing client" do
  let(:client) { Evil::Client.new "localhost" }

  let(:expectation_error) { RSpec::Mocks::MockExpectationError }

  it "specifies method" do
    allow(client)
      .to receive_request(:get)
      .and_respond(200, "name" => "Luka")

    allow(client)
      .to receive_request(:put)
      .and_respond(200, "name" => "Matthew")

    expect(client.put.name)
      .to eql "Matthew"

    expect(client.get!.name)
      .to eql "Luka"

    expect { client.patch.name }
      .to raise_error(expectation_error)
  end

  it "can specify path" do
    allow(client)
      .to receive_request(:get, "/users/3")
      .and_respond(200, "name" => "Mark")

    allow(client)
      .to receive_request(:get, "/users/4")
      .and_respond(200, "name" => "John")

    expect(client.path(:users, 3).get.name)
      .to eql "Mark"

    expect(client.path(:users, 4).get.name)
      .to eql "John"

    expect { client.path(:users, 5).get.name }
      .to raise_error(expectation_error)
  end

  it "supports Rails path syntax" do
    allow(client)
      .to receive_request(:get, "/users/:id")
      .and_respond(200, "name" => "Mark")

    expect(client.path(:users, 3).get.name)
      .to eql "Mark"

    expect { client.path(:users).get.name }
      .to raise_error(expectation_error)
  end

  it "supports complex restriction for the request" do
    allow(client).to receive_request(:post, "/users/6")
      .where { |req| req.body == { name: "Simon" } }
      .where { |req| req.query == { key: "secret" } }
      .and_respond(201, "id" => 6, "name" => "Simon")

    expect { client.path(:users, 6).query(key: "secret").post(name: "Simon") }
      .not_to raise_error

    expect { client.path(:users, 6).post(name: "Simon") }
      .to raise_error(expectation_error)

    expect { client.path(:users, 6).query(key: "secret").put(name: "Simon") }
      .to raise_error(expectation_error)

    expect { client.path(:users, 7).query(key: "secret").post(name: "Simon") }
      .to raise_error(expectation_error)

    expect { client.path(:users, 6).query(key: "secret").post(name: "Judith") }
      .to raise_error(expectation_error)
  end

  it "supports body #==" do
    allow(client).to receive_request(:post)
      .where { |req| req.body == { user: { name: "Tobit" } } }
      .and_respond(200)

    expect { client.post user: { name: "Tobit" } }
      .not_to raise_error

    expect { client.post user: { name: "Tobit", id: 1 } }
      .to raise_error expectation_error

    expect { client.post user: { name: "Tobit" }, id: 1 }
      .to raise_error expectation_error
  end

  it "supports body #include?" do
    allow(client).to receive_request(:post)
      .where { |req| req.body.include?(user: { name: "Andrew" }) }
      .and_respond(200)

    expect { client.post user: { name: "Andrew", id: 1 } }
      .not_to raise_error

    expect { client.post name: "Andrew" }
      .to raise_error expectation_error
  end

  it "supports body flattened #[]" do
    allow(client).to receive_request(:post)
      .where { |req| req.body['user[name]'] == "Theodorus" }
      .and_respond(200)

    expect { client.post user: { name: "Theodorus", id: 16 } }
      .not_to raise_error

    expect { client.post name: "Theodorus" }
      .to raise_error expectation_error
  end

  it "supports body #keys" do
    allow(client).to receive_request(:post)
      .where { |req| req.body.keys.include? "user[name]" }
      .and_respond(200)

    expect { client.post user: { name: "Bartholomew", id: 1 } }
      .not_to raise_error

    expect { client.post name: "Bartholomew" }
      .to raise_error expectation_error
  end

  it "supports query #==" do
    allow(client).to receive_request(:get)
      .where { |req| req.query == { user: { name: "Tobit" } } }
      .and_respond(200)

    expect { client.get user: { name: "Tobit" } }
      .not_to raise_error

    expect { client.get user: { name: "Tobit", id: 1 } }
      .to raise_error expectation_error

    expect { client.get user: { name: "Tobit" }, id: 1 }
      .to raise_error expectation_error
  end

  it "supports query #include?" do
    allow(client).to receive_request(:get)
      .where { |req| req.query.include?(user: { name: "James" }) }
      .and_respond(200)

    expect { client.get user: { name: "James", id: 1 } }
      .not_to raise_error

    expect { client.get name: "James" }
      .to raise_error expectation_error
  end

  it "supports query #keys" do
    allow(client).to receive_request(:get)
      .where { |req| req.query.keys.include? "user[name]" }
      .and_respond(200)

    expect { client.get user: { name: "Thaddeus", id: 1 } }
      .not_to raise_error

    expect { client.get name: "Thaddeus" }
      .to raise_error expectation_error
  end

  it "supports headers #==" do
    allow(client).to receive_request(:get)
      .where { |req| req.headers == { "X-Name" => "Peter" } }
      .and_respond(200)

    expect { client.headers("X-Name" => "Peter").get }
      .not_to raise_error

    expect { client.headers("X-Name" => "Peter", "Y-Name" => "Paul").get }
      .to raise_error expectation_error
  end

  it "supports headers #include?" do
    allow(client).to receive_request(:get)
      .where { |req| req.headers.include?("X-Name" => "Silas") }
      .and_respond(200)

    expect { client.headers("X-Name" => "Silas", "Y-Name" => "Timothy").get }
      .not_to raise_error

    expect { client.headers("X-Name" => "Timothy").get }
      .to raise_error expectation_error
  end

  it "supports headers #keys" do
    allow(client).to receive_request(:get)
      .where { |req| req.headers.keys.include? "X-Name" }
      .and_respond(200)

    expect { client.headers("X-Name" => "Apollos", "Y-Name" => "Junia").get }
      .not_to raise_error

    expect { client.headers("Y-Name" => "Junia").get }
      .to raise_error expectation_error
  end

  it "supports path equality to Rails path pattern" do
    allow(client).to receive_request(:get)
      .where { |req| req.path == "/users/:id" }
      .and_respond(200)

    expect { client.path(:users, 8).get! }
      .not_to raise_error

    expect { client.path(:users, 8, :check).get! }
      .to raise_error expectation_error
  end
end
