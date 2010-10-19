#!/usr/bin/ruby

#TABLE 15 Pharmacist by Office Type By Pak

require 'postgres'

#Get pharmacist from form1
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select pak,otype,sum(int2(pharmacist)) as pharmacist "
sql += "from v_tb15_f1 "
sql += "group by pak,otype "
sql += "having sum(int2(pharmacist)) > 0 "
sql += "order by pak,otype"
res1 = con.exec(sql)

#Get pharmacist from form5
sql = "select pak,otype,sum(int2(pharmacist)) as pharmacist "
sql += "from v_tb15_f5 "
sql += "group by pak,otype "
sql += "having sum(int2(pharmacist)) > 0 "
sql += "order by pak,otype"
res2 = con.exec(sql)

#Get pop 2550
sql = "select pak,p2550 "
sql += "FROM v_pop"
res3 = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 15</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 15 จำนวนและสัดส่วนเภสัชกรต่อประชากร จำแนกตามสังกัด รายภาค ปี 2550</h4>\n"

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

File.open("/res53/res50-tb15.html","w").write(html)
