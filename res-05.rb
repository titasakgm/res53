#!/usr/bin/ruby

# Report failed to complete forms

require 'postgres'
require 'cgi'
require 'res_util.rb'

c = CGI::new
pcode = c['pcode'].to_s.split('').join('')
errMsg("Unauthorize Access") if (pcode.length != 2)

area = "จังหวัด"
pc = pcode
pn = getProvName(pcode)
provname = "จังหวัด#{pn}"

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT m_desc,o_type,o_code,o_name "
sql += "FROM office53,minisid "
sql += "WHERE o_provid='#{pcode}' AND " 
sql += "o_minisid=m_code "
sql += "ORDER BY o_type,o_code "
log("res-05.rb: #{sql}")
res = con.exec(sql)
con.close

h = ord = nil
n = total = 0
bgcol = '#FFFFFF'

h = "<table border='1' width='100%'>"
h += "<tr><th>ลำดับที่</th><th>รหัสจังหวัด</th><th>จังหวัด</th>"
h += "<th>สังกัด</th><th>OTYPE</th><th>รหัส</th><th>หน่วยงาน</th>"
h += "<th>เหตุผลไม่ส่งรายงาน</th></tr>\n"

public = false

res.each do |rec|
  total += 1
  n += 1
  minis = rec[0]
  ot = rec[1]
  bgcol = '#FFFFFF'
  #if (ot == 'P' && public == false)
  if (ot == 'P')
    #public = true
    bgcol = '#CCCCCC'
  end
  hc = rec[2]
  failFlag = checkFailreport(hc)
  bgcol = 'pink' if (failFlag == true)
  hn = rec[3].to_s.split(',').first
  ord = sprintf("%03d", n)
  h += "<tr bgcolor='#{bgcol}'><th>#{ord}</th>"
  h += "<th>#{pc}</th><td>#{pn}</td><td>#{minis}</td>"
  h += "<th>#{ot}</th><th>#{hc}</th><td>&nbsp;#{hn}</td>"
  h += "<td><input type='button' value='ระบุเหตุผล' style='width:100%' "
  h += "onclick='window.open(\"res-06.rb?hcode=#{hc}\")'/></td></tr>\n"  
end

h += "</table>\n"

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<body>
<h4>รายชื่อหน่วยงานในความรับผิดชอบของ #{provname} (รวม #{total})</h4>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
<p>#{h}<p>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
</body>
</html>
EOF
