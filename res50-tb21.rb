#!/usr/bin/ruby

#TABLE 21 แพทย์ ทันตาภิบาล นวกสาธารณสุข จ.บริหารสาธารณสุข จ.สสช พ.วิชาชีพ พ.เทคนิค

require 'postgres'

#Get info
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb21_f1 order by pak"
res = con.exec(sql)

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 21</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 21 จำนวนบุคลากรทางการแพทย์ สถานีอนามัย รายภาค ปี 2550</h4>\n"
html += "<table width='75%' border='1'>\n"
html += "<tr><th>ภาค</th><th>แพทย์</th><th>ทันตาภิบาล</th>"
html += "<th>นวก.สาธารณสุข</th><th>จ.บริหารงานสาธารณสุข</th><th>จ.สาธารณสุขชุมชน</th>"
html += "<th>พยาบาลวิชาชีพ</th><th>พยาบาลเทคนิค</th></tr>\n"

p1x = p2x = p3x = p4x = p5x = p6x = p7x = 0

res.each do |rec|
  pak = rec[0].to_s
  p1 = rec[1].to_s.to_i
  p2 = rec[2].to_s.to_i
  p3 = rec[3].to_s.to_i
  p4 = rec[4].to_s.to_i
  p5 = rec[5].to_s.to_i
  p6 = rec[6].to_s.to_i
  p7 = rec[7].to_s.to_i
  p1x += p1
  p2x += p2
  p3x += p3
  p4x += p4
  p5x += p5
  p6x += p6
  p7x += p7

  html += "<tr><th align='left'>#{pak}</th><th>#{p1}</th><th>#{p2}</th>"
  html += "<th>#{p3}</th><th>#{p4}</th><th>#{p5}</th><th>#{p6}</th>"
  html += "<th>#{p7}</th></tr>\n"
end

html += "<tr><th align='right'>TOTAL</th><th>#{p1x}</th>"
html += "<th>#{p2x}</th><th>#{p3x}</th><th>#{p4x}</th>"
html += "<th>#{p5x}</th><th>#{p6x}</th><th>#{p7x}</th>"
html += "</tr>\n"
html += "</table>\n"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb21.html","w").write(html)
