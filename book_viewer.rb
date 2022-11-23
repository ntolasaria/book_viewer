require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  
  erb :home
end

get "/chapters/:number" do  
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  redirect '/' unless (1..@contents.size).include?(number)

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/show/:name" do
  params[:name]
end

get '/search' do
  @results = chapters_matching(params[:query])
  erb :search
end

not_found do
  redirect '/'
end

helpers do

  def in_paragraphs(text)
    paragraphs = text.split("\n\n")
    paragraphs.map.with_index do |paragraph, index|
      "<p id=\"paragraph#{index}\">#{paragraph}</p>"
    end.join
  end

  def highlight(text, match_text)
    text.gsub(match_text, %(<strong>#{match_text}</strong>))
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

  return results if query.nil? || query.empty?

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    
    results << {number: number, name: name, paragraphs: matches} unless matches.empty?
  end

  results
end