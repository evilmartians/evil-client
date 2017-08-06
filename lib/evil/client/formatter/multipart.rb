module Evil::Client::Formatter
  #
  # Utility module to format file (IO) as a part of multipart body
  #
  # @example
  #   Evil::Client::Formatter::Form.call foo: { bar: :baz }
  #   # => "foo[bar]=baz"
  #
  module Multipart
    extend self
    require_relative "part"

    # Formats nested hash as a string
    #
    # @param  [Array<IO>] value
    # @option opts [String] :boundary
    # @return [String]
    #
    def call(*sources, boundary:, **)
      parts = sources.flatten.map.with_index(1) do |src, num|
        "--#{boundary}\r\n#{part(src, num)}"
      end

      [nil, nil, parts, "--#{boundary}--", nil].join("\r\n")
    end

    private

    def part(source, index)
      Part.call(source, index)
    end
  end
end
