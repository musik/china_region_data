require 'pp'
require 'anemone'
class F58
  def run
    url = 'http://www.58.com/changecity.aspx'
    page = Anemone::HTTP.new.fetch_page url
    cities = []
    page.doc.css('#clist dd a').each do |node|
      cities <<  {name: node.content,url: node.attr('href')}
    end
    p cities
  end
end
F58.new.run
