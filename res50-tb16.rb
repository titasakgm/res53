#!/usr/bin/ruby

#TABLE 16 Professionnal Nurse by Office Type By Pak

require 'postgres'

#Get Prof. Nurse + Anaest from form1
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb16_f1 where nurse > 0 order by pak,otype"
res1 = con.exec(sql)

#Get Prof. Nurse + Anaest from form5
sql = "select * from v_tb16_f5 where nurse > 0 order by pak,otype"
res2 = con.exec(sql)

#Get pop 2550
sql = "select pak,p2550 "
sql += "FROM v_pop"
res3 = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 16</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 16 จำนวนและสัดส่วนพยาบาลวิชาชีพต่อประชากร จำแนกตามสังกัด รายภาค ปี 2550</h4>\n"

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

File.open("/res53/res50-tb16.html","w").write(html)
