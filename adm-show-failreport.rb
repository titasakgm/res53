#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'hr_util.rb'

c = CGI::new
pcode = c['user']

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT * FROM v_failreport "
if (pcode.length == 2) # Province Admin
  sql += "WHERE o_provid='#{pcode}' "
end
sql += "ORDER BY f_hcode "
res = con.exec(sql)
con.close

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<body>
<h4>สรุปรายงานหน่วยงานที่ไม่ส่งรายงาน</h4>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
<p>
<table border='1' width='90%'>
<tr>
  <th>ลำดับ</th><th>รหัสจังหวัด</th><th>จังหวัด</th>
  <th>สังกัด</th><th>Otype</th><th>รหัสหน่วยงาน</th><th>หน่วยงาน</th>
  <th>เหตุผล</th><th>หมายเหตุ</th>
</tr>
EOF

n = 0
res.each do |rec|
  n += 1
  ord = sprintf("%02d", n)
  hcode = rec[0]
  reason = rec[1]
  remark = rec[2]
  remark = '&nbsp;' if (remark.to_s.length == 0)
  info = getOfficeInfo(hcode)
  i = info.split('|')
  pc = i[3]
  pn = i[1]
  mn = i[5]
  ot = i[4]
  hn = i[0]
  print "<tr>\n<th>#{ord}</th><th>#{pc}</th><td>&nbsp;#{pn}</td>"
  print "<td>&nbsp;#{mn}</td><th>#{ot}</th><th>#{hcode}</th>"
  print "<td>&nbsp;#{hn}</td><td>#{reason}</td><td>#{remark}</td></tr>\n"      
end

print <<EOF
</table>
<p>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
</body>
</html>
EOF
