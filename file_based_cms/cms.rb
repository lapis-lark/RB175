require "sinatra"
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require "tilt/erubis"
require 'redcarpet'
require 'yaml'

valid_users = [
  {"admin" => "secret"},
  {"steve" => 'baseball'},
  {"anna" => 'tea'}
]



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
  file = data_path + '/' + filename
  if File.file?(file)
    file
  else
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
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
  when 'yml'
    file
  end
end

def valid_credentials?(user, pass)
  valid_users = YAML.load(File.read(path_from_filename("users.yml")))
  valid_users[user] == pass
end

def redirect_unless_signed_in
  if session[:current_user].nil?
    session[:message] = "you must be signed in to do that"
    redirect '/'
  end
end

def redirect_unless_admin(filename)
  if filename == 'users.yml' && session[:current_user] != 'admin'
    session[:message] = "you don't have the proper credentials to access this file"
    redirect '/'
  end
end


get "/" do
  @title = "CMS"
  @user = session[:current_user]
  return erb :signin_link unless @user

  @files = Dir.glob(data_path + "/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get '/new' do
  redirect_unless_signed_in

  erb :new
end

post '/new' do
  redirect_unless_signed_in

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
  redirect_unless_admin(filename)
  
  load_file_content(filepath)
end

get "/:filename/edit" do |filename|
  redirect_unless_signed_in
  redirect_unless_admin(filename)

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
  redirect_unless_signed_in
  redirect_unless_admin(filename)

  filepath = path_from_filename(filename)
  File.write(filepath, params["new_content"])
  session[:message] = "#{filename} successfully updated"
  params.inspect
  redirect '/'
end

post '/:filename/destroy' do |filename|
  redirect_unless_signed_in

  File.delete(path_from_filename(filename))
  session[:message] = "#{filename} successfully deleted"
  redirect '/'
end

get '/users/signin' do 
  erb :signin
end

post '/users/signin' do
  if valid_credentials?(params["username"], params["password"])
    session[:message] = "Welcome!"
    session[:current_user] = params["username"]
    redirect '/'
  else
    session[:message] = "Invalid credentials"
    status 422
    erb :signin
  end
end

post '/users/signout' do
  session[:current_user] = nil
  session[:message] = "you have been signed out"
  redirect '/'
end

=begin
  Requirements:
    allow the admin to modify list of users who may sign into the application

  Overview:
    create txt file of users/passwords
    prevent viewing or editing this unless admin
    have it be in yaml format for easy translation?
      

  
  
  Tests!


  Algo/Concrete:


=end