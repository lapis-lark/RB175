require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |para, idx| 
      "<p id=#{idx}>#{para}<\p>" 
    end.join('')
  end

  def highlight(line, term)
    line.gsub(term, "<strong>#{term}</strong>")
  end
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    results << {number: number, name: name} if contents.include?(query)
  end

  results
end

def paragraphs_matching(text, query)
  hash = {}
  text.split("\n\n").each_with_index do |para, idx| 
    hash[idx] = para if para.include?(query)
  end

  hash
end

def sentences_matching(para, query)
  matches = []
  lines = para.split("\n").join(' ').split(/(\.|\?|!)/)
  lines.each { |l| matches << l if l.include?(query) }
  
  matches
end

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  @chp = params[:number]
  @title = "Chapter #{@chp}"


  redirect "/" unless (1..@contents.size).cover? @chp.to_i

  @chapter = File.read("data/chp#{@chp}.txt")
  erb :chapters
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

not_found do
  redirect '/'
end

