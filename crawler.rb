require 'nokogiri'
require 'open-uri'
require 'csv'

def parse(article)
  article_info = {}
  article_info[:title] = parse_title(article)
  article_info[:url] = parse_url(article)
  article_info[:tags] = parse_tags(article)
  article_info[:created_at] = parse_created_at(article)
  article_info
end

def parse_title(article)
  article.at_css('h2').text.strip
end

def parse_url(article)
  article.at_css('h2 a')[:href]
end

def parse_tags(article)
  tags = article.css('div.css-vvapww a')
  tags.map(&:text).join(',')
end

def parse_created_at(article)
  article.at_css('time').text[/\d+-\d+-\d+/].gsub('-', '/')
end

url = 'https://qiita.com/'
sleep 1
html = open(url).read
doc = Nokogiri::HTML.parse(html)

today = Time.now
File.open("cralwer_#{today.strftime("%F")}.csv", 'w') do |csv|
  csv.write "\uFEFF"
  csv << %w[title url tags created_at].to_csv(force_quotes: true)
  articles = doc.css('article')
  articles.each do |article|
    article_info = parse(article)
    csv << [article_info[:title],
            article_info[:url],
            article_info[:tags],
            article_info[:created_at]].to_csv(force_quotes: true)
  end
end
