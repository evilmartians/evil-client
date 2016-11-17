class Evil::Client::DSL::Responses
  # Add settings shared by several responses
  #
  # @param [#to_sym] name
  # @param [#to_i]   status
  # @param [Hash<Symbol, Object>] options
  # @param [Proc] block
  #
  def response(name, status, **options, &block)
    @client.send :response, name, status, @options.merge(options), &block
  end

  # Add settings shared by several responses
  #
  # @param [Hash<Symbol, Object>] options
  # @param [Proc] block
  #
  def responses(**options, &block)
    self.class.new(@client, @options.merge(options), &block)
  end

  private

  def initialize(client, **options, &block)
    @client  = client
    @options = options
    instance_eval(&block)
  end
end
