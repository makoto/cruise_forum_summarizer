$KCODE='UTF8'
require 'open-uri'
require '../lib/keiji_parser'
pages = []
# File.open("summary.html", "w") do |file |
File.open("../" + OUTDIR + "summary.html", "w") { |file|
  file.write  "<html>\n<head>\n</head>\n<body>\n<table border='1'>\n"
  file.write  "<tr><th>id</th><th>title</th><th>user</th><th>date</th><th>comments</th><th>last comments date</th></tr>"

    (0..10).to_a.each do |num |
      p num
    # [1].each do |num |
      # html = open("../data/sample_input/ezbbs#{num}.html")
      html = open("http://www3.ezbbs.net/cgi/bbs?id=fujiwara&dd=33&p=#{num}")
  
      page = Page.new(html)
      page.topics.each do |t| 
        file.write  "<tr>\n"
        # p "topic"
        file.write  "<td>"
        file.write  t.thread_id 
        file.write  "</td><td>"
        file.write  t.title 
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
      
        # file.puts "#{t.thread_id}: #{t.title}, #{t.user}, #{t.date}: #{t.comments[-1].date if t.comments[-1] },#{t.comments.size}  \n"
        # file.write  "#{t.thread_id}: #{t.title}, #{t.user}, #{t.date}: #{t.comments[-1].date if t.comments[-1] },#{t.comments.size}  \n"
        # p t.context
        t.comments.each do |c|
          # p "comment"
          # p c.thread_id 
          # p c.title 
          # p c.user 
          # p c.date 
        end
        file.write  "</tr>\n"
        
      end
      pages << page
      
    end
  file.write  "</table>\n</body>\n</html>"
 
}
  
# end
# pages.each{|page| p page.topics.}

