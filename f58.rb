require 'pp'
require 'anemone'
require 'active_support/hash_with_indifferent_access'
require 'yaml'
class F58
  def run
    cities = fetch_cities 
    seeds = cities.collect{|r| r[1][:url] + "ershoufang/"}
    # seeds = seeds[0,1]
    Anemone.crawl seeds,verbose: true do |a|
      a.focus_crawl do |page|
        []
      end
      a.on_every_page do |page|
        subdomain = page.url.to_s.match(/\/\/(.+?)\./)[1]
        parent = cities[subdomain]
        parent[:children] = [] unless parent.key? :children
        begin
          page.doc.at_css('#region.secitem').css('dd a').each do |node|
            next unless node.attr('class').nil?
            next unless !node.attr('onclick').nil? and node.attr('onclick').match(/_area_/)
            data = {}
            data[:name] = node.content.strip
            data[:slug] = node.attr('href').match(/^(?:http:\/)*\/(.+?(city))*[\/\.]/)[1] rescue nil
            puts "slug nil #{data[:name]}" if data[:slug].nil?
            parent[:children] << data
          end
          cities[subdomain] = parent
        rescue Exception => e
          puts "\tError: "+ e.message
        end
      end
      a.after_crawl do
        dump_to_file cities
      end
    end
  end
  def fetch_cities
    url = 'http://www.58.com/changecity.aspx'
    page = Anemone::HTTP.new.fetch_page url
    cities = {}
    page.doc.css('#clist dd a').each do |node|
      url = node.attr('href')
      slug = url.match(/\/\/(.+?)\./)[1]
      next if %w(diaoyudao cn hk tw am kel).include?(slug)
      cities[slug] =  {name: node.content,url: url,slug: slug}
    end
    cities
  end
  def dump_to_file data,file='f58.yml'
    File.open(file,'w') { |f|
      f.write data.deep_stringify_keys.to_yaml
    }
  end
end
F58.new.run
