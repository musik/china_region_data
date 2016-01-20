require 'yaml'
require 'pp'
# require 'ruby-pinyin'
require 'chinese_pinyin'
# require 'active_support/hash'
require 'active_support/hash_with_indifferent_access'
$custom = YAML.load_file("custom.yml")
def parse_city k,val
  # puts k
  val[:cities] = parse_cities(val[:cities]) if val.key?(:cities)
  val[:districts] = parse_cities(val[:districts]) if val.key?(:districts)
  # val[:nicename] = parse_nicename k
  rewrite_pinyin = false
  if k.length == 2
    val[:nicename] = k
    rewrite_pinyin = true
  else 
    if k.match(/自治/)
      val[:nicename] = duozu_replace k
      rewrite_pinyin = true
    end
  end
  if !val.key?(:nicename)
    val[:nicename] = k.sub(/(省|特别行政区|地区|市|区|县)$/,'')
    # p [val[:nicename],k,val[:pinyin],val[:pinyin_abbr]]
  end
  #特殊处理 
  if $custom.key?(k)
    val[:pinyin] = $custom[k]["pinyin"]
    val[:pinyin_abbr] = $custom[k]["abbr"]
    val[:name] = $custom[k]["name"] if $custom[k].key? "name"
  end
  if rewrite_pinyin
    val[:pinyin] = Pinyin.t(k,splitter: '')
    val[:pinyin_abbr] = Pinyin.t(k){|l| l[0]}
    # p [k,val[:nicename],val[:pinyin],val[:pinyin_abbr]]
  end
  val
end
def duozu_replace str
  str.gsub!(/自治(区|县|州|旗)/,'')
  if str.length > 3
    patt = %w(满 回 藏 蒙古 达斡尔 朝鲜 畲 土家 侗 苗 瑶 仫佬 毛南 黎 羌 彝 仡佬 布依 傣 哈尼 拉祜 佤 布朗 壮 白 独龙 傈僳 景颇 裕固 哈萨克 保安 东乡 撒拉 土 怒 普米 水 各 纳西).join('|')
    str.gsub!(/(#{patt})族/,'')
    str.gsub!(/(柯尔克孜|哈萨克|蒙古|维吾尔|锡伯|塔吉克)$/,'') if str.length > 3
  end
  str
end
def parse_nicename name
  if name.length == 2
    name
  else
    # name.gsub(//,'')
  end
end
def parse_cities hash
  hash.each do |k,v|
    data = parse_city k.to_s,v
    name = data.delete(:name) || k
    hash[k] = data
  end
  hash
end
data = YAML.load_file 'regions-original.yml'
data.deep_symbolize_keys!
data = parse_cities data
File.open('regions.yml','w') { |f|
  f.write data.deep_stringify_keys.to_yaml
}
