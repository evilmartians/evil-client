RSpec.describe Evil::Client::Model do
  before do
    class Test::User < Evil::Client::Model
      attributes type: Dry::Types["strict.string"] do
        option :name
        option :email, default:  proc { nil }
        option :phone, optional: true
      end
    end

    class Test::Order < Evil::Client::Model
      param :user,    type: Test::User
      attribute :sum, type: Dry::Types["strict.int"]
      option :items,  type: Dry::Types["array"].member(Dry::Types["strict.int"])
      option :qt,     default: proc { nil }
    end
  end

  describe ".new" do
    it "is tolerant to unknown options" do
      user = Test::User.new(name: "Andrew", foo: "bar")
      expect(user.to_h).to eq name: "Andrew", email: nil
    end

    it "checks types" do
      expect { Test::User.new(name: "Andrew", email: nil) }
        .to raise_error TypeError
    end

    it "accepts string keys" do
      user = Test::User.new("name" => "Andrew")
      expect(user).to eq Test::User.new(name: "Andrew")
    end
  end

  describe ".call" do
    it "is shortcuts filtering" do
      user = Test::User.call(name: "Andrew")
      expect(user).to eq name: "Andrew", email: nil
    end
  end

  describe ".[]" do
    it "is an alias for .call" do
      user = Test::User[name: "Andrew"]
      expect(user).to eq Test::User.call(name: "Andrew")
    end
  end

  describe "#to_h" do
    it "provides a hash with assigned values only" do
      user = Test::User[name: "Andrew"]
      expect(user.to_h).to eq name: "Andrew", email: nil

      user = Test::User[name: "Alan", email: "alan@example.com"]
      expect(user.to_h).to eq name: "Alan", email: "alan@example.com"

      user = Test::User[name: "Alice", phone: "12345"]
      expect(user.to_h).to eq name: "Alice", email: nil, phone: "12345"

      user = Test::User[name: "Avdi", phone: "12345"]
      expect(user.to_h).to eq name: "Avdi", email: nil, phone: "12345"
    end

    it "hashifies models it depth" do
      order = Test::Order[user: { name: "Bob" }, sum: 100, items: [1, 2]]
      expect(order.to_h).to eq user:  { name: "Bob", email: nil },
                               sum:   100,
                               items: [1, 2],
                               qt:    nil
    end
  end

  describe "#[]" do
    it "is an alias for #send" do
      user = Test::User.new(name: "Andrew")
      expect(user[:name]).to  eq user.name
      expect(user["name"]).to eq user.name
    end
  end

  describe "#==" do
    it "compares model to model with the same attributes" do
      user = Test::User[name: "Andrew"]
      expect(user).to eq Test::User[name: "Andrew"]
      expect(user).not_to eq Test::User[name: "Andrew", phone: "71112234455"]
    end

    it "compares model to some hash" do
      user = Test::User[name: "Andrew"]
      expect(user).to eq name: "Andrew", email: nil
    end

    it "makes comparison in depth" do
      order = Test::Order[user: { name: "Bob" }, sum: 100, items: [1, 2]]
      expect(order).to eq user:  { name: "Bob", email: nil },
                          sum:   100,
                          items: [1, 2],
                          qt:    nil
    end
  end
end
