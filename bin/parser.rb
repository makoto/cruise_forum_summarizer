$KCODE='UTF8'
"UTF8"
require 'keiji_parser'

(0..9).to_a.each do |num |
  html = open("../data/sample_input/ezbbs#{num}.html")
  page = Page.new(html)
  page.topics.each {|t| 
    p t.thread_id 
    p t.title 
    p t.user 
    p t.date 
    p t.context 
  }
end

