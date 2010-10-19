#!/usr/bin/ruby

#TABLE 17 Technical Nurse by Office Type By Pak

require 'postgres'

#Get Technical Nurse from form1
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb17_f1 where nurse > 0 order by pak,otype"
res1 = con.exec(sql)

#Get Technical Nurse from form5
sql = "select * from v_tb17_f5 where nurse > 0 order by pak,otype"
res2 = con.exec(sql)

#Get pop 2550
sql = "select pak,p2550 "
sql += "FROM v_pop"
res3 = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 17</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 17 จำนวนและสัดส่วนพยาบาลเทคนิคต่อประชากร จำแนกตามสังกัด รายภาค ปี 2550</h4>\n"

html += "<pre>\n"
res1.each do |rec|
  html += rec.join('|')
  html += "\n"
end
html += "<hr>"
res2.each do |rec|
  html += rec.join('|')
  html += "\n"
end
html += "<hr>"
html += "<b>ประชากรรายภาค ปี 2550</b>\n"
res3.each do |rec|
  html += rec.join('|')
  html += "\n"
end
html += "</pre>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb17.html","w").write(html)
