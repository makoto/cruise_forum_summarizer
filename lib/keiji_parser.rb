# $KCODE="SJIS"

require 'rubygems'
require 'hpricot'
require 'nkf'
require 'time'
require 'net/http'
require 'open-uri'

SITE = "www3.ezbbs.net"
OUTDIR = "data/output/"

class JPDate
  
  def self.parse(str)
    tsuki = NKF.nkf("-Ws -m0 --cp932", "月")
    nichi = NKF.nkf("-Ws -m0 --cp932", "日")
    ji = NKF.nkf("-Ws -m0 --cp932", "時")
    fun = NKF.nkf("-Ws -m0 --cp932", "分")
    month = str.slice(/(.*)#{tsuki}(.*)#{nichi}.* (\d*)#{ji}(\d*)#{fun}/s, 1)
    day = str.slice(/(.*)#{tsuki}(.*)#{nichi}.* (\d*)#{ji}(\d*)#{fun}/s, 2)
    hour =  str.slice(/(.*)#{tsuki}(.*)#{nichi}.* (\d*)#{ji}(\d*)#{fun}/s, 3)
    min =  str.slice(/(.*)#{tsuki}(.*)#{nichi}.* (\d*)#{ji}(\d*)#{fun}/s, 4)
    
    this_year = Time.now.year
    year = this_year

    @time = Time.parse("#{year}/#{month}/#{day} #{hour}:#{min}")
    if Time.now < @time
      year = this_year - 1
      @time = Time.parse("#{year}/#{month}/#{day} #{hour}:#{min}")
    end
    return @time
  end
  
  def self.generate(time)
    one_week  = ['日','月','火','水','木','金','土']
    one_week = one_week.map{|day| NKF.nkf("-Ws -m0 --cp932", day)}
    if time.respond_to?(:wday)
      week_day = one_week[time.wday]
      NKF.nkf("-Ws -m0 --cp932", time.strftime("%Y年%m月%d日(#{week_day}) %H時%M分"))
    end
  end
end

class Page
  attr_reader :topics
  def initialize(doc)
    doc = Hpricot(doc)
    topic_elements = doc.search('table[@width="90%"]')
    @topics = topic_elements.map{|e|
      Topic.new(e)}
  end
end

class Message 
  attr_reader :thread_id, :title, :date, :user, :context, :photos
  
  def initialize(element)
    input = element.search('input[@name=del]').first
    if input
      name = NKF.nkf("-Ws -m0 --cp932", "名前")
      date = NKF.nkf("-Ws -m0 --cp932", "日付")
      colong = NKF.nkf("-Ws -m0 --cp932", "：")
      period = NKF.nkf("-Ws -m0 --cp932", "．")
      @thread_id = input.attributes['value']
      @title =  input.parent.inner_text.gsub(/#{@thread_id}#{colong}/,"")
      # @title =  input.parent.inner_text.delete(@thread_id + period)
      # @user =   element.search('tr')[@name_and_date_position].inner_text.slice(/名前：(.*) 日付/, 1).gsub(/\?/,"").strip
      # @date = JPDate.parse(element.search('tr')[@name_and_date_position].inner_text.slice(/日付：(.*$)/, 1))
      @date = JPDate.parse(element.search('tr')[@name_and_date_position].inner_text.slice(/#{date}#{colong}(.*$)/s, 1))
      @user =   element.search('tr')[@name_and_date_position].inner_text.slice(/#{name}#{colong}(.*)#{date}/s, 1).gsub(/\?/,"").strip
      
      @photos = element.search('a[@href]').map{|a| a.attributes['href']}.find_all{|a| a.match(/jpg$/)}.map{|a| Photo.new(a)}
      # @photos.each{|photo| photo.fetch}
    end
  end
end

class Photo
  attr_reader :url, :thumbnail_url
  def initialize(url)
    @site
    @url = url
    @thumbnail_url = @url.sub(/.jpg/, "s.jpg")
  end
  
  def fetch
    [@url, @thumbnail_url].each do |url|
      
      file_path = File.dirname(url)
      file_name = File.basename(url)
      p "fetching SITE: #{file_name}"
      
      unless Dir.glob("../" + OUTDIR + file_name) == ["../" + OUTDIR + file_name]

        Net::HTTP.start(SITE) { |http|
          resp = http.get(url)
          open("../" + OUTDIR + file_name, "wb") { |file|
            file.write(resp.body)
           }
        }
      end
    end
  end
end

class Topic < Message
  attr_reader :comments, :url, :element

  def initialize(element)
    @name_and_date_position = 2
    super(element)

    context_lines = element.search('table')[1].search('td')[0..1].inner_html.split("\n")
    contexts = []
    context_lines.each{|c| break if c.match(/<table/); contexts << c}
    @context = contexts.join("\n")
    @url = "/cgi/reply?id=fujiwara&dd=33&re=#{thread_id}"
    if @context.empty? # This is because an topic with an icon has extra table
      @context =  element.search('table')[2].search('td')[0..1].inner_html
    end

    # Replacing relative path to fqdn
    element.search("a[@href]").each do |e| 
      url =  e.attributes['href'] 
      e.set_attribute(:href, 'http://' + SITE + url ) if url.match(/^\/cgi/)
      e.set_attribute(:href, File.basename(url) ) if url.match(/^\/33\/fujiwara/)
    end
    
    element.search("img[@src]").each do |e| 
      img =  e.attributes['src'] 
      e.set_attribute(:src, File.basename(img) ) if img.match(/^\/33\/fujiwara\/img/)
      p img
      e.set_attribute(:src, "./images/" + File.basename(img) ) if img.match(/^\/images\/icon/)
    end
    
    @element = element

    @comments =  element.search('table')[2..-1].map{|comment_element| Comment.new(comment_element)}
  end
end

class Comment < Message
  
  def initialize(element)
    @name_and_date_position = 1
    
    super(element)
    # To skip duplicate comment errro for comment with icons
    if @thread_id
      @context = element.search('tr')[2].search('td')[0].inner_html.strip
    end
  end
end

class Summary
  attr_reader :now, :topics
  def initialize(params)
    @now = params[:date]
    @page_num = params[:page_num]
  end
  
  def this_month
    @now.strftime("%Y%m")
  end

  def last_month
    (@now << 1).strftime("%Y%m")
  end
  
  def next_month
    p "now: #{@now}, today: #{Date.today}"
    if @now.month  ==  Date.today.month
      nil
    else 
      (@now >> 1).strftime("%Y%m")
    end
  end
  
  def generate
    @topics = []
    
    loop  do
      html = open("http://www3.ezbbs.net/cgi/bbs?id=fujiwara&dd=33&p=#{@page_num}")
      page =  Page.new(html)
      this_month_topic = page.topics.find_all{|t| t.date.month == @now.month || t.comments.find_all{|c| c.date }.last.date.month == @now.month}
      @topics = @topics + this_month_topic
      p "#{@page_num},#{this_month_topic.size}, #{page.topics.size}"

      if this_month_topic.size == page.topics.size
        @page_num = @page_num + 1
      else
        break
      end
    end
    
    File.open("../" + OUTDIR + "#{this_month}.html", "w") { |file|
      header = <<-EOF
      <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=Shift_JIS" />
        <title>#{@now.year}年#{@now.month}月　クルーズファンの情報ボックス</title>
      </head><body>
      <table align="center" bgcolor="#ffffff" border="0" cellpadding="5" width="800">
        <tbody>
          <tr>
            <td align="center"><h4>#{@now.year}年#{@now.month}月</h4></td>
            <td align="center">
              <a href="#{last_month}.html">前へ</a>　　
              <a href="#{next_month || "index"}.html">次へ</a>
            </td>
            <td align="center">
            </td>
            <td align="center">
              <h4><a href="index.html">トップへ</a></h4>
            </td>
          </tr>
        </tbody>
      </table>
      <table align="center" border="1" bordercolor="#800000" cellpadding="5" cellspacing="3" width="800">
        <tbody><tr>
          <td><br>
          <br></td>
        </tr>
      </tbody>
      </table>
      <table border='1'>
      EOF
      file.write NKF.nkf("-Ws -m0 --cp932", header)
      file.write  NKF.nkf("-Ws -m0 --cp932", "<tr><th>タイトル</th><th>投稿者</th><th>投稿日</th><th>コメント数</th><th>最終コメント投稿日</th></tr>")
      @topics.each do |t| 
        file.write  "<tr>\n"
        # p "topic"
        file.write  "<td>"
        # file.write  t.thread_id 
        # file.write  "</td><td>"
        file.write  "<a href ='#{t.thread_id}.html' >"
        file.write  t.title 
        file.write  "</a>"
        file.write  "</td><td>"
        file.write  t.user 
        file.write  "</td><td>"
        file.write  JPDate.generate(t.date )
        file.write  "</td><td>"
        file.write  t.comments.size
        file.write  "</td><td>"
        if t.comments.size > 0
          file.write  JPDate.generate(t.comments.last.date )
        end
        file.write  "</td>\n"
        file.write  "</tr>\n"
      end

      file.write  "</table>\n</body>\n</html>"
    }
    
    @page_num
  end
end

class Icon
  def self.fetch
    18.times do | n |
      num = sprintf("%.2d", n + 1)
      Net::HTTP.start(SITE) { |http|
        resp = http.get("/images/icon#{num}.gif")
        open("icon#{num}.gif", "w") { |file|
          file.write(resp.body)
         }
      }
    end
  end
end
