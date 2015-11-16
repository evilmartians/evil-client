require 'webmock/rspec'

NotEmpty = Class.new

RSpec::Matchers.define :have_been_made_with_header do |key, value = NotEmpty|
  match do |actual|
    request = actual.with do |req|
      header = req.headers[key.to_s]

      if value == NotEmpty then
        expect(header).not_to be_nil
        expect(header).not_to be_empty
      elsif value.is_a? Regexp
        expect(header).to match(value)
      else
        expect(header).to eq value
      end

      req
    end

    expect(request).to have_been_made
  end
end

RSpec::Matchers.define :have_been_made_with_headers do |hash|
  match do |actual|
    hash.each do |key, value|
      expect(actual).to have_been_made_with_header key, value
    end
  end
end

RSpec::Matchers.define :have_been_made_with_body do |*content|
  match do |actual|
    request = actual.with do |req|
      body = req.body

      content.each do |chunk|
        if chunk.is_a? Regexp
          expect(body).to match(chunk)
        else
          expect(body).to eq(chunk)
        end
      end

      req
    end

    expect(request).to have_been_made
  end
end
