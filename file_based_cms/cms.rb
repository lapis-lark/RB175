require "sinatra"
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require "tilt/erubis"
require 'redcarpet'

valid_users = [
  {"admin" => "secret"}

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
  end
end

def valid_credentials?(user, pass, valid_users)
  valid_users.include?({user => pass})
end

get "/" do
  @user = session[:current_user]
  return erb :signin_link unless @user

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
  
  load_file_content(filepath)
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
    filepath = path_from_filename(filename)
    File.write(filepath, params["new_content"])
    session[:message] = "#{filename} successfully updated"
    params.inspect
    redirect '/'
end

post '/:filename/destroy' do |filename|
  File.delete(path_from_filename(filename))
  session[:message] = "#{filename} successfully deleted"
  redirect '/'
end

get '/users/signin' do 
  erb :signin
end

post '/users/signin' do
  if valid_credentials?(params["username"], params["password"], valid_users)
    session[:message] = "Welcome!"
    session[:current_user] = 'admin'
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
    display link to login screen if not signed in
    build login screen
    flash welcome on login
    sign out button at bottom
    "signed in as..." message

  Overview:
    display link to login if not signed in
      link_to_signin.erb
      users/signin.erb
        username, pass fields; sign in button
        validation, flash message if invalid
        retain input information
          post '/signin'
            flash message 'welcome'
            redirect ot '/'
      update index.erb
        sign out button
        signed in as "#{}"
      

  
  
  Tests!


  Algo/Concrete:


=end