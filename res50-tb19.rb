#!/usr/bin/ruby

#TABLE 19 DOCTORS|DENTISTS|PHARMACISTS|PN|TN รพศ. By Pak

require 'postgres'

#Get info
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb19_f1 order by pak"
res = con.exec(sql)

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 19</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 19 จำนวนบุคลากรทางการแพทย์ รพท. รายภาค ปี 2550</h4>\n"
html += "<table width='75%' border='1'>\n"
html += "<tr><th>ภาค</th><th>แพทย์</th><th>ทันตแพทย์</th>"
html += "<th>เภสัชกร</th><th>พยาบาลวิชาชีพ</th><th>พยาบาลเทคนิค</th></tr>\n"

md = dt = ph = pn = tn = 0
res.each do |rec|
  pak = rec[0].to_s
  doctor = rec[1].to_s.to_i
  dentist = rec[2].to_s.to_i
  pharmacist = rec[3].to_s.to_i
  profnurse = rec[4].to_s.to_i
  technurse = rec[5].to_s.to_i
  md += doctor
  dt += dentist
  ph += pharmacist
  pn += profnurse
  tn += technurse

  html += "<tr><th align='left'>#{pak}</th><th>#{doctor}</th>"
  html += "<th>#{dentist}</th><th>#{pharmacist}</th><th>#{profnurse}</th>"
  html += "<th>#{technurse}</th></tr>\n"
end

html += "<tr><th align='right'>TOTAL</th><th>#{md}</th><th>#{dt}</th>"
html += "<th>#{ph}</th><th>#{pn}</th><th>#{tn}</th></tr>\n"
html += "</table>\n"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb19.html","w").write(html)
