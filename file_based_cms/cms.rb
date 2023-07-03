require "sinatra"
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require "tilt/erubis"
require 'redcarpet'

ROOT = File.expand_path("..", __FILE__)

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

def path_from_filename(filename)
  ROOT + "/data/" + filename
end

# e.g. txt, md, jpeg
def get_filetype(filepath)
  filepath.split(".")[-1]
end

def filename_from_path(filepath)
  filepath.split("/")[-1]
end

def load_file_content(filepath)
  filetype =  get_filetype(filepath)
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
  @files = Dir.glob(ROOT + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do |filename|
  filepath = path_from_filename(filename)

  if File.file?(filepath)
    load_file_content(filepath)
  else
    session[:error] = "#{filename} does not exist."
    redirect '/'
  end
end

get "/:filename/edit" do |filename|
  @filename = filename
  filepath = path_from_filename(filename)

  if File.file?(filepath)
    @content = load_file_content(filepath)
    headers["Content-Type"] = "text/html;charset=utf-8"
    erb :edit
  else
    session[:error] = "#{filename} does not exist."
    redirect '/'
  end
end

post '/:filename/edit' do |filename|
    # update file contents based on which param?
    filepath = path_from_filename(filename)
    File.write(filepath, params["new_content"])
    session[:success] = "#{filename} successfully updated"
    params.inspect
    redirect '/'
    
end

=begin
  Requirements:
    Create an edit link next to each document
    Direct to edit page upon clicking edit link
    The document's content will appear within a textarea
    Changes can be saved with the "save changes" button
      User then redirected to index page
      Flash message about the update

  Overview:
    #*Create an edit button link that is printed with each filename (index.erb)
    #*Create get "/:file/edit"
      #*create @contents, @filepath/name?
    Create post "/:file/edit"
      redirect to '/'
      add success message
    Create edit.erb
      #* Label for textarea
      #* Look up how to make a textarea with contents loaded in
      Save Changes button



  Algo/Concrete:


=end