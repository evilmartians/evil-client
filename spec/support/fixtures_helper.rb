def fixture_file_path(filename)
  File.expand_path "spec/fixtures/#{filename}"
end

def yaml_fixture_file(filename)
  YAML.load_file(fixture_file_path(filename))
end
