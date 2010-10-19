#!/usr/bin/ruby

#TABLE 43 Equipment (form3+form7) by pak/khet/province

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
html += "<title>TABLE 43</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 43 อุปกรณ์การแพทย์ที่มีราคาแพง รายภาค</h4>\n"
html += "<table border='1' width='75%'>\n"
html += "<tr><th width='25%'>ภาค</th><th>CT</th><th>MRI</th><th>EWSL</th>"
html += "<th>GAMMA</th><th>US</th><th>DIALYSES</th><th>AMBULANCE</th></tr>\n"

ctx = mrix = eswlx = gammax = usx = dialysex = ambulancex = 0

(0..4).each do |n|
  pak = res1[n][1]
  ct = res1[n][2].to_i + res2[n][2].to_i
  ctx += ct
  mri = res1[n][3].to_i + res2[n][3].to_i
  mrix += mri
  eswl = res1[n][4].to_i + res2[n][4].to_i
  eswlx += eswl
  gamma = res1[n][5].to_i + res2[n][5].to_i
  gammax += gamma
  us = res1[n][6].to_i + res2[n][6].to_i
  usx += us
  dialyse = res1[n][7].to_i + res2[n][7].to_i
  dialysex += dialyse
  ambulance = res1[n][8].to_i + res2[n][8].to_i
  ambulancex += ambulance
  html += "<tr><th align='left'>#{pak}</th><th>#{ct}</th><th>#{mri}</th>"
  html += "<th>#{eswl}</th><th>#{gamma}</th><th>#{us}</th><th>#{dialyse}</th>"
  html += "<th>#{ambulance}</th></tr>\n"
end

html += "<tr><th width='25%' align='right'>TOTAL</th><th>#{ctx}</th>"
html += "<th>#{mrix}</th><th>#{eswlx}</th><th>#{gammax}</th><th>#{usx}</th>"
html += "<th>#{dialysex}</th><th>#{ambulancex}</th></tr>\n"
html += "</table>\n"

#Get equipment from form3 khet
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select khet,sum(int2(ct)) as ct,sum(int2(mri)) as mri,"
sql += "sum(int2(eswl)) as eswl,sum(int2(gamma)) as gamma,sum(int2(us)) as us,"
sql += "sum(int2(dialyse)) as dialyse,sum(int2(ambulance)) as ambulance "
sql += "from v_equip_form3 group by khet "
sql += "order by khet"
res1 = con.exec(sql)

sql = "select khet,sum(int2(ct)) as ct,sum(int2(mri)) as mri,"
sql += "sum(int2(eswl)) as eswl,sum(int2(gamma)) as gamma,sum(int2(us)) as us,"
sql += "sum(int2(dialyse)) as dialyse,sum(int2(ambulance)) as ambulance "
sql += "from v_equip_form7 group by khet "
sql += "order by khet"
res2 = con.exec(sql)
con.close

html += "<h4>ตาราง 43 อุปกรณ์การแพทย์ที่มีราคาแพง รายเขต</h4>\n"
html += "<table border='1' width='75%'>\n"
html += "<tr><th>เขต</th><th>CT</th><th>MRI</th><th>EWSL</th>"
html += "<th>GAMMA</th><th>US</th><th>DIALYSES</th><th>AMBULANCE</th></tr>\n"

ctx = mrix = eswlx = gammax = usx = dialysex = ambulancex = 0

(0..19).each do |n|
  khet = res1[n][0]
  khet = 'กทม.' if khet.to_i == 0
  ct = res1[n][1].to_i + res2[n][1].to_i
  ctx += ct
  mri = res1[n][2].to_i + res2[n][2].to_i
  mrix += mri
  eswl = res1[n][3].to_i + res2[n][3].to_i
  eswlx += eswl
  gamma = res1[n][4].to_i + res2[n][4].to_i
  gammax += gamma
  us = res1[n][5].to_i + res2[n][5].to_i
  usx += us
  dialyse = res1[n][6].to_i + res2[n][6].to_i
  dialysex += dialyse
  ambulance = res1[n][7].to_i + res2[n][7].to_i
  ambulancex += ambulance
  html += "<tr><th width='25%'>#{khet}</th><th>#{ct}</th>"
  html += "<th>#{mri}</th><th>#{eswl}</th><th>#{gamma}</th><th>#{us}</th>"
  html += "<th>#{dialyse}</th><th>#{ambulance}</th></tr>\n"
end

html += "<tr><th width='25%' align='right'>TOTAL</th><th>#{ctx}</th>"
html += "<th>#{mrix}</th><th>#{eswlx}</th><th>#{gammax}</th><th>#{usx}</th>"
html += "<th>#{dialysex}</th><th>#{ambulancex}</th></tr>\n"
html += "</table>\n"

#Get equipment from form3 province
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select pcode,pname,sum(int2(ct)) as ct,sum(int2(mri)) as mri,"
sql += "sum(int2(eswl)) as eswl,sum(int2(gamma)) as gamma,sum(int2(us)) as us,"
sql += "sum(int2(dialyse)) as dialyse,sum(int2(ambulance)) as ambulance "
sql += "from v_equip_form3 group by pcode,pname "
sql += "order by pcode"
res1 = con.exec(sql)

sql = "select pcode,pname,sum(int2(ct)) as ct,sum(int2(mri)) as mri,"
sql += "sum(int2(eswl)) as eswl,sum(int2(gamma)) as gamma,sum(int2(us)) as us,"
sql += "sum(int2(dialyse)) as dialyse,sum(int2(ambulance)) as ambulance "
sql += "from v_equip_form7 group by pcode,pname "
sql += "order by pcode"
res2 = con.exec(sql)
con.close

html += "<h4>ตาราง 43 อุปกรณ์การแพทย์ที่มีราคาแพง รายจังหวัด</h4>\n"
html += "<table border='1' width='75%'>\n"
html += "<tr><th>จังหวัด</th><th>CT</th><th>MRI</th><th>EWSL</th>"
html += "<th>GAMMA</th><th>US</th><th>DIALYSES</th><th>AMBULANCE</th></tr>\n"

ctx = mrix = eswlx = gammax = usx = dialysex = ambulancex = 0

(0..75).each do |n|
  pcode = res1[n][0]
  pname = res1[n][1]
  ct7 = (res2[n]) ? res2[n][2].to_i : 0
  ct = res1[n][2].to_i + ct7
  ctx += ct

  mri7 = (res2[n]) ? res2[n][3].to_i : 0
  mri = res1[n][3].to_i + mri7
  mrix += mri

  eswl7 = (res2[n]) ? res2[n][4].to_i : 0
  eswl = res1[n][4].to_i + eswl7
  eswlx += eswl

  gamma7 = (res2[n]) ? res2[n][5].to_i : 0
  gamma = res1[n][5].to_i + gamma7
  gammax += gamma

  us7 = (res2[n]) ? res2[n][6].to_i : 0
  us = res1[n][6].to_i + us7
  usx += us

  dialyse7 = (res2[n]) ? res2[n][7].to_i : 0
  dialyse = res1[n][7].to_i + dialyse7
  dialysex += dialyse

  ambulance7 = (res2[n]) ? res2[n][8].to_i : 0
  ambulance = res1[n][8].to_i + ambulance7
  ambulancex += ambulance

  html += "<tr><th width='25%' align='left'>#{pname}</th><th>#{ct}</th>"
  html += "<th>#{mri}</th><th>#{eswl}</th><th>#{gamma}</th><th>#{us}</th>"
  html += "<th>#{dialyse}</th><th>#{ambulance}</th></tr>\n"
end

html += "<tr><th width='25%' align='right'>TOTAL</th><th>#{ctx}</th>"
html += "<th>#{mrix}</th><th>#{eswlx}</th><th>#{gammax}</th><th>#{usx}</th>"
html += "<th>#{dialysex}</th><th>#{ambulancex}</th></tr>\n"
html += "</table>\n"

html += "</body>\n"
html += "</html>\n"

File.open("/res50/res50-tb43.html","w").write(html)
