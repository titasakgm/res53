#!/usr/bin/ruby

#!/usr/bin/ruby

#TABLE 01 Number of beds by office type by service type

require 'postgres'

#Get beds from v_tb01_f4 (G/M)
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "SELECT stype,otype,count(*),sum(int2(bed)) as bed "
sql += "FROM v_tb01_f4 "
sql += "GROUP BY stype,otype "
sql += "ORDER BY stype"
res1 = con.exec(sql)

sql = "SELECT stype,otype,count(*),sum(int2(bed)) as bed "
sql += "FROM v_tb01_f8 "
sql += "GROUP BY stype,otype "
sql += "ORDER BY stype"
res2 = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 01</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 01 จำนวนเตียง รายประเภทหน่วยงาน รายประเภทบริการ</h4>\n"
html += "<table border='1' width='50%'>\n"
html += "<tr><th colspan='3'>ประเภทบริการทั่วไป</th></tr>\n"
html += "<tr><th width='50%'>ประเภทหน่วยงาน</th><th>จำนวนแห่ง</th><th>จำนวนเตียง</th></tr>\n"

res1.each do |rec|
  stype = rec[0].to_s.strip
  otype = rec[1].to_s.strip
  count = rec[2].to_s.strip
  bed = rec[3].to_s.strip
  if (stype == 'G')
    html += "<tr><th align='left'>#{otype}</th><th align='right'>"
    html += "#{count}</th><th align='right'>#{bed}</th></tr>\n"
  end
end

res2.each do |rec|
  stype = rec[0].to_s.strip
  otype = rec[1].to_s.strip
  count = rec[2].to_s.strip
  bed = rec[3].to_s.strip
  if (stype == 'G')
    html += "<tr><th align='left'>#{otype}</th><th align='right'>"
    html += "#{count}</th><th align='right'>#{bed}</th></tr>\n"
  end
end

html += "</table>"
html += "<p>"

html += "<table border='1' width='50%'>\n"
html += "<tr><th colspan='3'>ประเภทบริการเฉพาะ</th></tr>\n"
html += "<tr><th width='50%'>ประเภทหน่วยงาน</th><th>จำนวนแห่ง</th><th>จำนวนเตียง</th></tr>\n"

res1.each do |rec|
  stype = rec[0].to_s.strip
  otype = rec[1].to_s.strip
  count = rec[2].to_s.strip
  bed = rec[3].to_s.strip
  if (stype == 'S')
    html += "<tr><th align='left'>#{otype}</th><th align='right'>"
    html += "#{count}</th><th align='right'>#{bed}</th></tr>\n"
  end
end

res2.each do |rec|
  stype = rec[0].to_s.strip
  otype = rec[1].to_s.strip
  count = rec[2].to_s.strip
  bed = rec[3].to_s.strip
  if (stype == 'S')
    html += "<tr><th align='left'>#{otype}</th><th align='right'>"
    html += "#{count}</th><th align='right'>#{bed}</th></tr>\n"
  end
end

html += "</table>"
html += "</body>\n"
html += "</html>\n"

File.open("/res53/res50-tb01.html","w").write(html)
