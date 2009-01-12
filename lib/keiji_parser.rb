require 'rubygems'
require 'hpricot'
require 'nkf'
require 'time'
require 'net/http'


SITE = "www3.ezbbs.net"
OUTDIR = "data/output/"

class JPDate
  def self.parse(str)
    month = str.slice(/(.*)月(.*)日/, 1)
    day = str.slice(/(.*)月(.*)日/, 2)
    hour =  str.slice(/(.*)月(.*)日.* (\d*)時(\d*)分/, 3)
    min =  str.slice(/(.*)月(.*)日.* (\d*)時(\d*)分/, 4)
    
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
    if time.respond_to?(:wday)
      week_day = one_week[time.wday]
      time.strftime("%Y年%m月%d日(#{week_day}) %H時%M分")
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
      @thread_id = input.attributes['value']
      @title =  NKF.nkf("-w", input.parent.inner_text).delete(@thread_id + "．")
      @user =   NKF.nkf("-w", element.search('tr')[@name_and_date_position].inner_text).slice(/名前：(.*) 日付/, 1).gsub(/\?/,"").strip
      @date = JPDate.parse(NKF.nkf("-w", element.search('tr')[@name_and_date_position].inner_text).slice(/日付：(.*$)/, 1))
      @photos = element.search('a[@href]').map{|a| a.attributes['href']}.find_all{|a| a.match(/jpg$/)}.map{|a| Photo.new(a)}
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
    p "SITE: #{SITE}"
    [@url, @thumbnail_url].each do |url|
      
      file_path = File.dirname(url)
      file_name = File.basename(url)
      unless Dir.glob(OUTDIR + file_name) == [OUTDIR + file_name]
        Net::HTTP.start(SITE) { |http|
          resp = http.get(url)
          open(OUTDIR + file_name, "wb") { |file|
            file.write(resp.body)
           }
        }
      end
    end
  end
end

class Topic < Message
  attr_reader :comments

  def initialize(element)
    @name_and_date_position = 2
    super(element)

    context_lines = element.search('table')[1].search('td')[0..1].inner_html.split("\n")
    contexts = []
    context_lines.each{|c| break if c.match(/<table/); contexts << c}
    @context = NKF.nkf("-w", contexts.join("\n"))
    if @context.empty? # This is because an topic with an icon has extra table
      @context =  NKF.nkf("-w", (element.search('table')[2].search('td')[0..1].inner_html))
    end
    
    @comments =  element.search('table')[2..-1].map{|comment_element| Comment.new(comment_element)}
  end
end

class Comment < Message
  
  def initialize(element)
    @name_and_date_position = 1
    
    super(element)
    # To skip duplicate comment errro for comment with icons
    if @thread_id
      @context = NKF.nkf("-w", element.search('tr')[2].search('td')[0].inner_html).strip
    end
  end
end