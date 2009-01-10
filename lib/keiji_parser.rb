require 'hpricot'
require 'nkf'
class Page
  attr_reader :topics
  def initialize(doc)
    doc = Hpricot(doc)
    topic_elements = doc.search('table[@width="90%"]')
    @topics = topic_elements.map{|e| Topic.new(e)}
  end
end

class Thread 
  attr_reader :thread_id, :title, :date, :user, :context
  
  def initialize(element)
    input = element.search('input[@name=del]').first
    @thread_id = input.attributes['value']
    @title =  NKF.nkf("-w", input.parent.inner_text).delete(@thread_id + "．")

    @user =   NKF.nkf("-w", element.search('tr')[@name_and_date_position].inner_text).slice(/名前：(.*) 日付/, 1).gsub(/\?/,"").strip
    @date = NKF.nkf("-w", element.search('tr')[@name_and_date_position].inner_text).slice(/日付：(.*$)/, 1)
  end
end

class Topic < Thread
  attr_reader :comments

  def initialize(element)
    @name_and_date_position = 2
    
    super(element)
    
    context_lines = element.search('table')[1].search('td')[0].inner_html.split("\n")
    contexts = []
    context_lines.each{|c| break if c.match(/<table/); contexts << c}
    @context = NKF.nkf("-w", contexts.join("\n"))
    @comments =  element.search('table')[2..-1].map{|comment_element| Comment.new(comment_element)}
  end
end

class Comment < Thread
  
  def initialize(element)
    @name_and_date_position = 1
    
    super(element)

    @context = NKF.nkf("-w", element.search('tr')[2].search('td')[0].inner_html).strip
  end
end