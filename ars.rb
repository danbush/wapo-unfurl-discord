#!/usr/bin/env ruby
$LOAD_PATH.unshift ("./gems/httparty-0.16.4/lib")
$LOAD_PATH.unshift ("./gems/multi_xml-0.6.0/lib")
$LOAD_PATH.unshift ("./gems/mime-types-3.2.2/lib")
$LOAD_PATH.unshift ("./gems/mime-types-data-3.2018.0812/lib")
$LOAD_PATH.unshift ("./gems/alfred-3_workflow-0.1.0/lib")
$LOAD_PATH.unshift ("./gems/news-api-0.0.0/lib") 


require 'httparty'
require 'alfred-3_workflow'
require 'news-api'

require 'open-uri'
require 'fileutils'
require 'json'

workflow = Alfred3::Workflow.new

newsapi = News.new("b63ccdb5b78a4731827f2308ec70018c")

query = ARGV[0]

logo = "./ars.png"

initial_search =
  HTTParty.get("https://newsapi.org/v2/everything?apiKey=b63ccdb5b78a4731827f2308ec70018c&sortBy=publishedAt&sources=ars-technica&q=" + query)

all_articles = initial_search["articles"]

headlines_search = 
HTTParty.get("https://newsapi.org/v2/top-headlines?apiKey=b63ccdb5b78a4731827f2308ec70018c&sortBy=publishedAt&sources=ars-technica")

top_headlines = headlines_search["articles"]
puts query
if query == nil || query == ""
  top_headlines.each do |article|
    the_subtitle = article["description"].to_s
    unfurl = "```" + article["title"].to_s + "\n\n" + article["content"].to_s + "```" + article["url"]

    workflow.result
      .title(article["title"])
      .subtitle(the_subtitle)
      .arg(article["url"])
      .shift('Copy to Clipboard', article["url"])
      .cmd(the_subtitle.to_s[60..-1], article["url"])
      .icon(logo)
  end
else
  all_articles.each do |article|
    the_subtitle = article["description"].to_s
    unfurl = "```" + article["title"].to_s + "\n\n" + article["content"].to_s + "```" + article["url"]

    workflow.result
      .title(article["title"])
      .subtitle(the_subtitle)
      .arg(article["url"])
      .shift('Copy to Clipboard', article["url"])
      .cmd(the_subtitle.to_s[60..-1], article["url"])
      .icon(logo)
  end
end

if query == "update!"
  workflow.result
      .title("Hit enter to update the workflow")
      .subtitle("This will pull the latest version from git. Any modifications will be overwritten.")
      .arg("update!")
elsif initial_search["totalResults"] < 1
  workflow.result
      .title("Can't find any results.")
      .subtitle("Sorry :(")
      .arg(query)
      .icon(logo)
end

print workflow.output