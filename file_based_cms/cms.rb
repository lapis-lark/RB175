require "sinatra"
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require "tilt/erubis"
require 'redcarpet'

root = File.expand_path("..", __FILE__)

before do
  @title = "CMS"
end

helpers do 
  def render_markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(text)
  end
end

configure do
  enable :sessions
  set :session_secret,
      "5dc69783347e8b8e37a6ce824691a09bd72f7ce2a0542afbc10f9416150f9a24"
end

def load_file_content(filepath)
  filetype = filepath.split(".")[-1] # e.g. txt, md, jpeg
  file = File.read(filepath)

  case filetype
  when 'txt'
    headers["Content-Type"] = "text/plain"
    file
  when 'md'
    headers["Content-Type"] = "text/html;charset=utf-8"
    render_markdown(file)
  end
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
    load_file_content(filepath)
  else
    session[:error] = "#{filename} does not exist."
    redirect '/'
  end
end

=begin
  Requirements:
    Handle user loading .md files and txt files (case statement for each file type?)
    Render the markdown as HTML
  General steps:
    Create case statement for handling different file types


  Algorithm/Concrete:

=end