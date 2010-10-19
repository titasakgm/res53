#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'hr_util.rb'
require 'res_util.rb'

allnil = Array.new

c = CGI::new

f7year = c['f7year'].to_s
f7pname = c['f7pname'].to_s
f7pcode = c['f7pcode'].to_s
f7hname = c['f7hname'].to_s
f7hcode  = c['f7hcode'].to_s
f701000 = c['f701000'].to_s.tr('-,','')
allnil.push(f701000)
f701000 = '0' if (f701000.to_s.length == 0)
f702000 = c['f702000'].to_s.tr('-,','')
allnil.push(f702000)
f702000 = '0' if (f702000.to_s.length == 0)
f703000 = c['f703000'].to_s.tr('-,','')
allnil.push(f703000)
f703000 = '0' if (f703000.to_s.length == 0)
f704000 = c['f704000'].to_s.tr('-,','')
allnil.push(f704000)
f704000 = '0' if (f704000.to_s.length == 0)
f705000 = c['f705000'].to_s.tr('-,','')
allnil.push(f705000)
f705000 = '0' if (f705000.to_s.length == 0)
f706000 = c['f706000'].to_s.tr('-,','')
allnil.push(f706000)
f706000 = '0' if (f706000.to_s.length == 0)
f707000 = c['f707000'].to_s.tr('-,','')
allnil.push(f707000)
f707000 = '0' if (f707000.to_s.length == 0)

if (allnil.to_s.length == 0)
  errMsg("กรุณาบันทึก 0 ในช่องใดช่องหนึ่ง ก่อนกดปุ่ม [บันทึกข้อมูล]")
  exit
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")

chk = checkDup("form7", "f7year", "f7hcode", f7year, f7hcode)

chkDigit('f701000',f701000)
chkDigit('f702000',f702000)
chkDigit('f703000',f703000)
chkDigit('f704000',f704000)
chkDigit('f705000',f705000)
chkDigit('f706000',f706000)
chkDigit('f707000',f707000)


if chk.to_s == 'NODUP'

sql = "INSERT INTO form7(f7year,f7pname,f7pcode,f7hname,f7hcode,"
sql = sql << "f701000,f702000,f703000,f704000,f705000,f706000,f707000) "
sql = sql << "VALUES('#{f7year}','#{f7pname}','#{f7pcode}','#{f7hname}','#{f7hcode}',"
sql = sql << " '#{f701000}','#{f702000}','#{f703000}','#{f704000}','#{f705000}','#{f706000}','#{f707000}')"
res = con.exec(sql)

elsif chk == 'DUP'

sql = "UPDATE form7 SET "
sql = sql << "f701000='#{ f701000 }',f702000='#{ f702000 }',"
sql = sql << "f703000='#{ f703000 }',f704000='#{ f704000 }',"
sql = sql << "f705000='#{ f705000 }',f706000='#{ f706000 }',"
sql = sql << "f707000='#{ f707000 }' "
sql = sql << "WHERE f7year='#{f7year}' and f7hcode='#{f7hcode}' "
res = con.exec(sql)

end

con.close

updateReportMon(f7hcode,f7year,"form7")

# Routine check if all forms (f1-f4 or f5-f8) for hcode is complete?
checkComplete(f7hcode)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<body text='blue'>
<center>
<h2>บันทึกแบบฟอร์ม 3 สำหรับ #{ f7hname.to_s }(#{ f7hcode.to_s }) เรียบร้อยแล้ว</h2>
<h3>โปรดบันทึกแบบฟอร์มที่ 4 ต่อไป</h3>
<p>
<input type='button' value='Back' onClick='history.back();'>
</center>
</body>
</html>
EOF

