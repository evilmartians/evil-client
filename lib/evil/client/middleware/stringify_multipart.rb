class Evil::Client::Middleware
  class StringifyMultipart < Base
    require_relative "stringify_multipart/part"

    private

    def build(env)
      return env unless env[:format] == "multipart"

      env.dup.tap do |hash|
        bound = SecureRandom.hex(10)
        hash[:headers] ||= {}
        hash[:headers]["content-type"] = \
          "multipart/form-data; boundary=#{bound}"
        hash[:body_string] = body_string(hash[:files], bound)
      end
    end

    def body_string(list, bound)
      return if list.empty?
      [nil, nil, parts(list, bound), "--#{bound}--", nil].join("\r\n")
    end

    def parts(list, bound)
      list.map.with_index { |item, index| part(bound, index + 1, item) }
    end

    def part(bound, index, data)
      "--#{bound}\r\n#{Part.new(name: "AttachedFile#{index}", **data)}"
    end
  end
end
