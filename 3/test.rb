require 'rack'
class MyApp
  def call(env)
    ['200', { "Content-Type" => "text/plain" }, [env.to_s]]
  end
end
Rack::Handler::WEBrick.run MyApp.new