#!/usr/bin/ruby

#TABLE 25 จำนวน รพศ. รพท. รพร. รพช.และเตียง รายจังหวัด ปี 2550

require 'postgres'

#Get BEDS from form4
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb25 order by khet,pcode,otype"
res = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 25</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 25 จำนวน รพศ. รพท. รพร. รพช.และเตียง รายจังหวัด ปี 2550</h4>"
html += "<pre>\n"
html += "ภาค|เขต|รหัสจังหวัด|จังหวัด|สังกัด|จำนวนแห่ง|จำนวนเตียง\n"

res.each do |rec|
  html += rec.join('|')
  html += "\n"
end

html += "</pre>\n"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb25.html","w").write(html)
