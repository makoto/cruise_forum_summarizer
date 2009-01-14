$KCODE='UTF8'
require '../lib/keiji_parser'
pages = []

page_num = 0
duration_in_month = 2

def prev_month(topics, index)
  topics[index - 1].thread_id unless index == 0
end

def next_month(topics, index)
  topics[index + 1].thread_id unless index == (topics.size - 1)
end

duration_in_month.times do |num|
  target_date =  (Date.new(Time.now.year, Time.now.month, Time.now.day) << num )
  summary = Summary.new(:date => target_date, :page_num => page_num)
  
  page_num = summary.generate
  topics = summary.topics
  topics.each_with_index do |topic, index|
    p "pre:#{prev_month(topics, index)} now:#{topic.thread_id} next:#{next_month(topics, index)}"
    header = <<-EOF

    <table width="90%" cellpadding="5" border="0">
    <tbody>
      <tr>    
          <td width="40%" align="right">
        <div class="tuki">#{summary.now.year}年#{summary.now.month}月</div>
        </td>
        <td align="right" width="40%">
          <a href="#{prev_month(topics, index)}.html">前へ</a>
          ＞現在＜
          <a href="#{next_month(topics, index)}.html">次へ</a>
        </td>
        <td align="right" width="40%">
          <a href="../index.html">トップへ</a>＞
          <a href="../#{summary.this_month}.html">#{summary.now.year}年#{summary.now.month}月</a>
        </td>
      </tr>
    </tbody>
    </table>
    EOF
    
    File.open("../" + OUTDIR + "#{topic.thread_id}.html", "w") { |file|
     file.write header
     file.write topic.element.to_html
    }
    
  end
end
