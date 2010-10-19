#!/usr/bin/ruby

#TABLE 22 จำนวนแพทย์เฉพาะสาขาต่างๆรายภาค ปี 2550

require 'postgres'

#Get info
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql1 = "select * from v_tb22_f2 order by pak"
res1 = con.exec(sql1)
sql2 = "select * from v_tb22_f6 order by pak"
res2 = con.exec(sql2)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 22</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 22 จำนวนแพทย์เฉพาะสาขาต่างๆรายภาค ปี 2550</h4>\n"
html += "<table width='100%' border='1'>\n"
html += "<tr><th>ความเชี่ยวชาญเฉพาะทาง</th><th>#{res1[0][0]}</th><th>#{res1[1][0]}</th>"
html += "<th>#{res1[2][0]}</th><th>#{res1[3][0]}</th><th>#{res1[4][0]}</th><th>รวม</th></tr>\n"

tot = total = 0
p1t = p2t = p3t = p4t = p5t = 0

(0..78).each do |n|
  p1f2 = res1[0][n+1].to_s.to_i # ภาค 1 form 2
  p1f6 = res2[0][n+1].to_s.to_i # ภาค 1 form 6
  p2f2 = res1[1][n+1].to_s.to_i # ภาค 2 form 2
  p2f6 = res2[1][n+1].to_s.to_i # ภาค 2 form 6
  p3f2 = res1[2][n+1].to_s.to_i # ภาค 3 form 2
  p3f6 = res2[2][n+1].to_s.to_i # ภาค 3 form 6
  p4f2 = res1[3][n+1].to_s.to_i # ภาค 4 form 2
  p4f6 = res2[3][n+1].to_s.to_i # ภาค 4 form 6
  p5f2 = res1[4][n+1].to_s.to_i # ภาค 5 form 2
  p5f6 = res2[4][n+1].to_s.to_i # ภาค 5 form 6

  p1x = p1f2+p1f6
  p2x = p2f2+p2f6
  p3x = p3f2+p3f6
  p4x = p4f2+p4f6
  p5x = p5f2+p5f6

  tot = p1x+p2x+p3x+p4x+p5x
  p1t += p1x
  p2t += p2x
  p3t += p3x
  p4t += p4x
  p5t += p5x

  html += "<tr>"
  html += "<th align='left'>Spec #{n}</th><th>#{p1x}</th><th>#{p2x}</th>"
  html += "<th>#{p3x}</th><th>#{p4x}</th><th>#{p5x}</th><th>#{tot}</th>"
  html += "</tr>\n"
end

html += "<tr><th align='right'>TOTAL</th><th>#{p1t}</th>"
html += "<th>#{p2t}</th><th>#{p3t}</th><th>#{p4t}</th>"
html += "<th>#{p5t}</th><th>#{p1t+p2t+p3t+p4t+p5t}</th>"
html += "</tr>\n"
html += "</table>\n"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb22.html","w").write(html)
