By default, Evil Client uses [Net::HTTP][net-http]-based connection to send requests.

If you need another user agent, change it to you client via connection writer. The connection can be an object with method `#call` that takes [rack environment][rack-env] (from stack of middleware) and returns [rack response][rack-response] back.

```ruby
conn = Object.new do
  def self.call(env)
    [200, {"Content-Type"=>"application/json"}, ['{"age":7}']]
  end
end

class CatsClient < Evil::Client
  connection = conn
end
```

[net-http]: http://ruby-doc.org/stdlib-2.4.1/libdoc/net/http/rdoc/Net/HTTP.html
[rack-env]: http://www.rubydoc.info/github/rack/rack/file/SPEC#The_Environment
[rack-response]: http://www.rubydoc.info/github/rack/rack/file/SPEC#The_Response