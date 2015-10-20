# encoding: utf-8

guard :rspec, cmd: "bundle exec rspec" do

  watch(%r{^spec/.+_spec\.rb$})

  watch(%r{^lib/evil-client/(.+)\.rb}) do |m|
    "spec/unit/#{m[1]}_spec.rb"
  end

  watch("lib/evil-client.rb")  { "spec" }
  watch("spec/spec_helper.rb") { "spec" }

end # guard :rspec
