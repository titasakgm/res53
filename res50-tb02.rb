#!/usr/bin/ruby

#!/usr/bin/ruby

#TABLE 02 Number of beds by office type by service type

require 'postgres'

#Get beds,opd1,opd2,ipd,los from v_tb02_f4 (G/M)
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "SELECT stype,otype,count(*),sum(int4(bed)) as bed,"
sql += "sum(int4(opd1)) as opd1,sum(int4(opd2)) as opd2,"
sql += "sum(int4(ipd)) as ipd,sum(int4(los)) as los "
sql += "FROM v_tb02_f4 "
sql += "GROUP BY stype,otype "
sql += "ORDER BY stype"
res1 = con.exec(sql)

#Get beds,opd1,opd2,ipd,los from v_tb02_f8 (P)
sql = "SELECT stype,otype,count(*),sum(int4(bed)) as bed,"
sql += "sum(int4(opd1)) as opd1,sum(int4(opd2)) as opd2,"
sql += "sum(int4(ipd)) as ipd,sum(int4(los)) as los "
sql += "FROM v_tb02_f8 "
sql += "GROUP BY stype,otype "
sql += "ORDER BY stype"
res2 = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 02</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>ตาราง 02 จำนวนเตียง/OPD1/OPD2/IPD/LOS รายประเภทหน่วยงาน รายประเภทบริการ</h4>\n"
html += "<table border='1' width='75%'>\n"
html += "<tr><th colspan='7'>ประเภทบริการทั่วไป</th></tr>\n"
html += "<tr><th width='30%'>ประเภทหน่วยงาน</th><th>จำนวนแห่ง</th><th>จำนวนเตียง</th>"
html += "<th>OPD1</th><th>OPD2</th><th>IPD</th><th>LOS</th></tr>\n"


res1.each do |rec|
  stype = rec[0].to_s.strip
  otype = rec[1].to_s.strip
  count = rec[2].to_s.strip
  bed = rec[3].to_s.strip
  opd1 = rec[4].to_s.strip
  opd2 = rec[5].to_s.strip
  ipd = rec[6].to_s.strip
  los = rec[7].to_s.strip
  if (stype == 'G')
    html += "<tr><th align='left'>#{otype}</th><th align='right'>"
    html += "#{count}</th><th align='right'>#{bed}</th><th align='right'>#{opd1}</th>"
    html += "<th align='right'>#{opd2}</th><th align='right'>#{ipd}</th><th align='right'>#{los}</th></tr>\n"
  end
end

res2.each do |rec|
  stype = rec[0].to_s.strip
  otype = rec[1].to_s.strip
  count = rec[2].to_s.strip
  bed = rec[3].to_s.strip
  opd1 = rec[4].to_s.strip
  opd2 = rec[5].to_s.strip
  ipd = rec[6].to_s.strip
  los = rec[7].to_s.strip
  if (stype == 'G')
    html += "<tr><th align='left'>#{otype}</th><th align='right'>"
    html += "#{count}</th><th align='right'>#{bed}</th><th align='right'>#{opd1}</th>"
    html += "<th align='right'>#{opd2}</th><th align='right'>#{ipd}</th><th align='right'>#{los}</th></tr>\n"
  end
end

html += "</table>"
html += "<p>"

html += "<table border='1' width='75%'>\n"
html += "<tr><th colspan='7'>ประเภทบริการเฉพาะ</th></tr>\n"
html += "<tr><th width='30%'>ประเภทหน่วยงาน</th><th>จำนวนแห่ง</th><th>จำนวนเตียง</th>"
html += "<th>OPD1</th><th>OPD2</th><th>IPD</th><th>LOS</th></tr>\n"

res1.each do |rec|
  stype = rec[0].to_s.strip
  otype = rec[1].to_s.strip
  count = rec[2].to_s.strip
  bed = rec[3].to_s.strip
  opd1 = rec[4].to_s.strip
  opd2 = rec[5].to_s.strip
  ipd = rec[6].to_s.strip
  los = rec[7].to_s.strip
  if (stype == 'S')
    html += "<tr><th align='left'>#{otype}</th><th align='right'>"
    html += "#{count}</th><th align='right'>#{bed}</th><th align='right'>#{opd1}</th>"
    html += "<th align='right'>#{opd2}</th><th align='right'>#{ipd}</th><th align='right'>#{los}</th></tr>\n"
  end
end

res2.each do |rec|
  stype = rec[0].to_s.strip
  otype = rec[1].to_s.strip
  count = rec[2].to_s.strip
  bed = rec[3].to_s.strip
  opd1 = rec[4].to_s.strip
  opd2 = rec[5].to_s.strip
  ipd = rec[6].to_s.strip
  los = rec[7].to_s.strip
  if (stype == 'S')
    html += "<tr><th align='left'>#{otype}</th><th align='right'>"
    html += "#{count}</th><th align='right'>#{bed}</th><th align='right'>#{opd1}</th>"
    html += "<th align='right'>#{opd2}</th><th align='right'>#{ipd}</th><th align='right'>#{los}</th></tr>\n"
  end
end

html += "</table>"
html += "</body>\n"
html += "</html>\n"

File.open("/res53/res50-tb02.html","w").write(html)
