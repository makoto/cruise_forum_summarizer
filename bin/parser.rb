$KCODE='UTF8'
require '../lib/keiji_parser'

(0..9).to_a.each do |num |
# [1].each do |num |
  html = open("../data/sample_input/ezbbs#{num}.html")
  page = Page.new(html)
  page.topics.each do |t| 
    p "topic"
    p t.thread_id 
    p t.title 
    p t.user 
    p t.date 
    p "Topic #{t.thread_id} EMPTY" if t.context.empty?
    p t.context
    p "comment"
      t.comments.each do |c|
        p c.thread_id 
        p c.title 
        p c.user 
        p c.date 
        p "Comment #{c.thread_id} EMPTY" if c.context == ""
        p c.context 
    end
  end
end

