require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'

get "/" do
  @title = "Sherlock Holmes"
  @toc = File.readlines("data/toc.txt")
  erb :home
end

get "/chapters/1" do
  @title = "Sherlock Holmes"
  @chapter = "Chapter 1"
  @toc = File.readlines("data/toc.txt")
  @text = File.read("data/chp1.txt")
  erb :chapters
end
