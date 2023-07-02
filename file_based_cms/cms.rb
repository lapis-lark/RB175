require "sinatra"
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

before do
  @title = "CMS"
end

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do |filename|
  filepath = root + "/data/" + filename

  headers["Content-Type"] = "text/plain"
  File.read(filepath)
end
