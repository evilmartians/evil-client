module Evil::Client::Formatter
  #
  # Utility module to format data as a single text
  #
  module Text
    extend self

    # Formats data as a text
    #
    # @param  [Object] source
    # @return [String]
    #
    def call(source)
      case source
      when File, Tempfile then source.read
      when StringIO       then source.string
      else source.to_s
      end
    end
  end
end
