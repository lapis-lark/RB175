require "sinatra"
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

before do
  @title = "CMS"
end

configure do
  enable :sessions
  set :session_secret,
      "5dc69783347e8b8e37a6ce824691a09bd72f7ce2a0542afbc10f9416150f9a24"
end

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do |filename|
  filepath = root + "/data/" + filename

  if File.file?(filepath)
    headers["Content-Type"] = "text/plain"
    File.read(filepath)
  else
    session[:error] = "#{filename} does not exist."
    redirect '/'
  end
end