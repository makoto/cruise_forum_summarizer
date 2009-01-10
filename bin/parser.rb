$KCODE='UTF8'
require 'open-uri'
require '../lib/keiji_parser'
pages = []
(0..10).to_a.each do |num |
# [1].each do |num |
  # html = open("../data/sample_input/ezbbs#{num}.html")
  html = open("http://www3.ezbbs.net/cgi/bbs?id=fujiwara&dd=33&p=#{num}")
  
  page = Page.new(html)
  page.topics.each do |t| 
    # p "topic"
    # p t.thread_id 
    # p t.title 
    # p t.user 
    # p t.date 
    print "#{t.thread_id}: #{t.title}, #{t.user}, #{t.date}: #{t.comments[-1].date if t.comments[-1] },#{t.comments.size}  \n"
    # p t.context
    t.comments.each do |c|
      # p "comment"
      # p c.thread_id 
      # p c.title 
      # p c.user 
      # p c.date 
    end
  end
  pages << page
end

# pages.each{|page| p page.topics.}

