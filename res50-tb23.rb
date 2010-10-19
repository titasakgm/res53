#!/usr/bin/ruby

#TABLE 23 Equipment (form3+form7) by Pak

require 'postgres'

#Get equipment from form3
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select pak,p_name,sum(int2(ct)) as ct,sum(int2(mri)) as mri,"
sql += "sum(int2(eswl)) as eswl,sum(int2(gamma)),sum(int2(us)),"
sql += "sum(int2(dialyse)) as dialyse,sum(int2(ambulance)) as ambulance "
sql += "from v_equip_form3,pak where pak=p_code group by pak,p_name "
sql += "order by pak,p_name"
res1 = con.exec(sql)

sql = "select pak,p_name,sum(int2(ct)) as ct,sum(int2(mri)) as mri,"
sql += "sum(int2(eswl)) as eswl,sum(int2(gamma)),sum(int2(us)),"
sql += "sum(int2(dialyse)) as dialyse,sum(int2(ambulance)) as ambulance "
sql += "from v_equip_form7,pak where pak=p_code group by pak,p_name "
sql += "order by pak,p_name"
res2 = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 23</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 23 อุปกรณ์การแพทย์ที่มีราคาแพง รายภาค</h4>\n"
html += "<table border='1'>\n"
html += "<tr><th>ภาค</th><th>CT</th><th>MRI</th><th>EWSL</th>"
html += "<th>GAMMA</th><th>US</th><th>DIALYSES</th><th>AMBULANCE</th></tr>\n"

(0..4).each do |n|
  pak = res1[n][1]
  ct = res1[n][2].to_i + res2[n][2].to_i
  mri = res1[n][3].to_i + res2[n][3].to_i
  eswl = res1[n][4].to_i + res2[n][4].to_i
  gamma = res1[n][5].to_i + res2[n][5].to_i
  us = res1[n][6].to_i + res2[n][6].to_i
  dialyse = res1[n][7].to_i + res2[n][7].to_i
  ambulance = res1[n][8].to_i + res2[n][8].to_i
  html += "<tr><th align='left'>#{pak}</th><th>#{ct}</th><th>#{mri}</th>"
  html += "<th>#{eswl}</th><th>#{gamma}</th><th>#{us}</th><th>#{dialyse}</th>"
  html += "<th>#{ambulance}</th></tr>\n"
end

html += "</table>"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res50/res50-tb23.html","w").write(html)
