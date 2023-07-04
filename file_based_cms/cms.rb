require "sinatra"
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require "tilt/erubis"
require 'redcarpet'



def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end


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

def create_file(name, content = '')
  File.write("#{data_path}/#{name}", content)
end

def path_from_filename(filename)
  data_path + '/' + filename
end

# e.g. txt, md, jpeg
def get_filetype(filepath)
  filepath.split(".")[-1]
end

def filename_from_path(filepath)
  filepath.split("/")[-1]
end

def load_file_content(filepath, for_editing = false)
  filetype =  get_filetype(filepath)
  file = File.read(filepath)

  case filetype
  when 'txt'
    headers["Content-Type"] = "text/plain"
    file
  when 'md'
    headers["Content-Type"] = "text/html;charset=utf-8"
    for_editing ? file : erb(render_markdown(file))
  end
end

get "/" do
  @files = Dir.glob(data_path + "/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  # get_filetype(params["newfile"])

  filename = params["newfile"]

  unless filename.empty?
    case get_filetype(filename)
    when 'txt' || 'md'
      session[:message] = "#{filename} added to the system"
      create_file(filename)
      redirect '/'
    else
      session[:message] = "invalid file name. please create either '.txt' or '.md' files."
      erb :new
    end
  else
    session[:message] = "a name is required. please create either '.txt' or '.md' files"
    erb :new
  end
end

get "/:filename" do |filename|
  filepath = path_from_filename(filename)
  
  if File.file?(filepath)
    load_file_content(filepath)
  else
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
end

get "/:filename/edit" do |filename|
  @filename = filename
  filepath = path_from_filename(filename)

  if File.file?(filepath)
    @content = load_file_content(filepath, 'for editing')
    headers["Content-Type"] = "text/html;charset=utf-8"
    erb :edit
  else
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
end

post '/:filename/edit' do |filename|
    # update file contents based on which param?
    filepath = path_from_filename(filename)
    File.write(filepath, params["new_content"])
    session[:message] = "#{filename} successfully updated"
    params.inspect
    redirect '/'
end

=begin
  Requirements:
    Add button linking to add document page
    Create add document page
    Add label "Add a new document:" to text field
    Create button for the text field
    Add a success message, redirect to index
    Verify that users entered a name, otherwise flash message

  Overview:
    #* Create button that links to get '/new' at top of index
      #* erb new
    Add new.erb
      #*label
      #* text input field
      #* Create button (post '/new')
    Create post '/new'
      validate input
      valid?
        success message
        redirect to index
      invalid?
        error message
        erb new (preserve previous input)
    
    Write tests!!




  Algo/Concrete:


=end