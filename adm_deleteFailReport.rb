#!/usr/bin/ruby

require 'postgres'
require 'cgi'
require 'res_util.rb'

c = CGI::new
hcode = c['hcode']

chk = checkExist(hcode)
msg = "HCODE: #{hcode} not found"

if (chk)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM failreport WHERE f_hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  msg = "1 record deleted"
end

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" /><body>
<h4>#{msg}</h4>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
</body>
</html>
EOF

