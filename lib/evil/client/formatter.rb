class Evil::Client
  # Utility to format body/query into one of formats: :json, :form, :multipart
  module Formatter
    extend self

    # Loads concrete formatters called by factory method [#call]
    require_relative "formatter/text"
    require_relative "formatter/form"
    require_relative "formatter/multipart"

    # Factory that knows how to format source depending on given format
    #
    # @param  [Object] source
    # @param  [:json, :form, :multipart, :text] format
    # @option opts [String] :boundary The boundary for a multipart body
    # @return [String] formatted body
    #
    def call(source, format, **opts)
      return unless source
      return to_json(source) if format == :json
      return to_yaml(source) if format == :yaml
      return to_form(source) if format == :form
      return to_text(source) if format == :text

      to_multipart(source, **opts)
    end

    private

    def to_json(source)
      JSON.dump source
    end

    def to_yaml(source)
      YAML.dump source
    end

    def to_text(source)
      Text.call source
    end

    def to_form(source)
      Form.call source
    end

    def to_multipart(source, **opts)
      Multipart.call [source], **opts
    end
  end
end
