$KCODE='UTF8'
require '../lib/keiji_parser'
pages = []

page_num = 0
duration_in_month = 2

duration_in_month.times do |num|
  target_date =  (Date.new(Time.now.year, Time.now.month, Time.now.day) << num )
  summary = Summary.new(:date => target_date, :page_num => page_num)
  page_num = summary.generate
end
