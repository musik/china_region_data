require 'pp'
require 'anemone'
class F58
  def run
    cities = fetch_cities 
    seeds = cities.collect{|r| r[:url] + ""}
  end
  def fetch_cities
    url = 'http://www.58.com/changecity.aspx'
    page = Anemone::HTTP.new.fetch_page url
    cities = []
    page.doc.css('#clist dd a').each do |node|
      cities <<  {name: node.content,url: node.attr('href')}
    end
  end
end
F58.new.run
