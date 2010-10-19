#!/usr/bin/ruby

require 'postgres'
require 'cgi'
require 'res_util.rb'

c = CGI::new
pcode = c['pcode'].to_s.split('').join('')

area = "จังหวัด"
area = "อำเภอ" if pcode.length == 4

provname = ''
if pcode.length == 4
  pn = getProvName(pcode[0..1])
  provname = "จังหวัด#{pn}"
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
if (pcode.length == 2)
  if (pcode == '10')
    sql = "SELECT o_province,o_code,o_name,o_type FROM office53 "
    sql += "WHERE o_provid='#{pcode}' "
    sql += "ORDER BY o_type,o_code "
  else
    sql = "SELECT o_province,o_code,o_name,o_type FROM office53 "
    sql += "WHERE o_provid='#{pcode}' AND o_ampid2='00' "
    sql += "ORDER BY o_type,o_code "
  end
elsif (pcode.length == 4) # DHO
  sql = "SELECT o_amphoe,o_code,o_name,o_type FROM office53 "
  sql += "WHERE o_provid||o_ampid2='#{pcode}' "
  sql += "ORDER BY o_type,o_code "
end
log("res-04.rb: #{sql}")
res = con.exec(sql)
con.close

h = ord = nil
n = total = 0
bgcol = '#FFFFFF'

provamp = res[0][0]

h = "<table border='1' width='100%'>"
h += "<tr><th>ลำดับที่</th><th>รหัส</th><th>หน่วยงาน</th><th>ประเภท</th></tr>\n"
public = false

res.each do |rec|
  total += 1
  n += 1
  hc = rec[1]
  hn = rec[2].to_s.split(',').first
  ot = rec[3]
  if (ot == 'P' && public == false)
    public = true
    bgcol = '#CCCCCC'
    n = 1
  end
  ord = sprintf("%03d", n)
  h += "<tr bgcolor='#{bgcol}'><th>#{ord}</th><th>#{hc}</th><td>&nbsp;#{hn}</td><th>#{ot}</th></tr>\n"  
end

h += "</table>\n"

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<body bgcolor='#AAEDFE'>
<h4>รายชื่อหน่วยงานในความรับผิดชอบของ #{area}#{provamp} #{provname} (รวม 
#{total})</h4>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
<p>#{h}<p>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
</body>
</html>
EOF
