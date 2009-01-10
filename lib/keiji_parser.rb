require 'rubygems'
require 'hpricot'
require 'nkf'
require 'time'

class JPDateParser
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
  attr_reader :thread_id, :title, :date, :user, :context
  
  def initialize(element)
    input = element.search('input[@name=del]').first
    if input
      @thread_id = input.attributes['value']
      @title =  NKF.nkf("-w", input.parent.inner_text).delete(@thread_id + "．")
      @user =   NKF.nkf("-w", element.search('tr')[@name_and_date_position].inner_text).slice(/名前：(.*) 日付/, 1).gsub(/\?/,"").strip
      @date = JPDateParser.parse(NKF.nkf("-w", element.search('tr')[@name_and_date_position].inner_text).slice(/日付：(.*$)/, 1))
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