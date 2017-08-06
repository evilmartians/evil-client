#
# Checks that an operation has been performed with given options
#
# @example
#   subject do
#     MyClient.new(token: "foo").users(version: 3).fetch(token: "bar", id: 42)
#   end
#
#   # call only matcher
#   expect { subject }.to perform_operation("MyClient.users.fetch")
#
#   # exact matcher
#   expect { subject }
#     .to perform_operation("MyClient.users.fetch")
#     .with_exactly(token: "bar", version: 3, id: 42)
#
#   # partial matcher
#   expect { subject }
#     .to perform_operation("MyClient.users.fetch")
#     .with(token: "bar", version: 3)
#
#   # absence matcher
#   expect { subject }
#     .to perform_operation("MyClient.users.fetch")
#     .without(:user, :password)
#
#   # block syntax
#   expect { subject }
#     .to perform_operation("MyClient.users.fetch")
#     .with { |token:, **| expect(token).to eq "bar" }
#
# @param [String] name The full name of the operation
#
RSpec::Matchers.define :perform_operation do |name|
  supports_block_expectations

  description { "perform operation #{name} " }

  chain :with do |**options|
    @some_options = options
  end

  chain :with_exactly do |**options|
    @exact_options = options
  end

  chain :without do |*options|
    @no_options = options.flatten.map(&:to_sym)
  end

  def full_signature(name)
    name.dup.tap do |text|
      text << " with options #{@exact_options}"              if @exact_options
      text << " with options including #{@some_options}"     if @some_options
      text << " without options :#{@no_options.join(', :')}" if @no_options
    end
  end

  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Style/InverseMethods
  def expected_options?(options, check)
    return if @exact_options && options != @exact_options
    return if @some_options  && !(options >= @some_options)
    return if (options.keys & @no_options.to_a).any?
    check.nil? || check.call(options)
  end
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Style/InverseMethods

  def stub_resolver
    resolver = Evil::Client::Resolver::Request

    allow(resolver).to receive(:call) do |schema, settings|
      register(schema, settings)
      resolver.new(schema, settings).send(:__call__)
    end
  end

  def actual_operations
    @actual_operations ||= []
  end

  def register(schema, settings)
    actual_operations << [schema.to_s, settings.options]
  end

  def performed(name, check)
    @performed ||= actual_operations.find do |(key, options)|
      (key == name) && expected_options?(options, check)
    end
  end

  match do |block|
    stub_resolver
    block.call
    !performed(name, block_arg).nil?
  end

  match_when_negated do |block|
    stub_resolver
    block.call
    performed(name, block_arg).nil?
  end

  def describe_expectations(name, perform)
    "It was expected the operation #{full_signature(name)}" \
    " #{'NOT ' unless perform}to be performed.\n" \
    "The following operations has been actually performed:"
  end

  failure_message do
    text = describe_expectations(name, true)
    actual_operations.each.with_index(1) do |(key, opts), index|
      text << format("\n   %02d) #{key} with #{opts}", index)
    end
    text
  end

  failure_message_when_negated do
    text = describe_expectations(name, false)
    actual_operations.each.with_index(1) do |(key, opts), index|
      marker = performed(name, block_arg) == [key, opts] ? "->" : "  "
      text << format("\n#{marker} % 2d) #{key} with #{opts}", index)
    end
    text
  end
end
