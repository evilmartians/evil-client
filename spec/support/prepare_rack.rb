# Stubs rack application
#
# @return [Class]
#
def prepare_rack(status, body)
  response = proc do
    def self.call(env)
      [status, {}, [body]]
    end
  end

  @rack_app = Class.new(&response)
end
