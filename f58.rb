require 'pp'
require 'anemone'
class F58
  def run
    cities = fetch_cities 
    seeds = cities.collect{|r| r[:url] + "ershoufang/"}
    seeds = seeds[0,1]
    Anemone.crawl seeds,verbose: true do |a|
      a.focus_crawl do |page|
        []
      end
      a.on_every_page do |page|
        page.doc.at_css('#region.secitem').css('dd a').each do |node|
          next unless node.attr('class').nil?
          next unless !node.attr('onclick').nil? and node.attr('onclick').match(/_area_/)
          p node.content.strip
        end
      end
    end
  end
  def fetch_cities
    url = 'http://www.58.com/changecity.aspx'
    page = Anemone::HTTP.new.fetch_page url
    cities = []
    page.doc.css('#clist dd a').each do |node|
      cities <<  {name: node.content,url: node.attr('href')}
    end
    cities
  end
end
F58.new.run
