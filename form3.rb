#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'hr_util.rb'
require 'res_util.rb'

allnil = Array.new

c = CGI::new
f3year = c['f3year'].to_s
f3pname = c['f3pname'].to_s
f3pcode = c['f3pcode'].to_s
f3hname = c['f3hname'].to_s
f3hcode  = c['f3hcode'].to_s
f301000 = c['f301000'].to_s.tr('-,','')
allnil.push(f301000)
f301000 = '0' if (f301000.to_s.length == 0)
f302000 = c['f302000'].to_s.tr('-,','')
allnil.push(f302000)
f302000 = '0' if (f302000.to_s.length == 0)
f303000 = c['f303000'].to_s.tr('-,','')
allnil.push(f303000)
f303000 = '0' if (f303000.to_s.length == 0)
f304000 = c['f304000'].to_s.tr('-,','')
allnil.push(f304000)
f304000 = '0' if (f304000.to_s.length == 0)
f305000 = c['f305000'].to_s.tr('-,','')
allnil.push(f305000)
f305000 = '0' if (f305000.to_s.length == 0)
f306000 = c['f306000'].to_s.tr('-,','')
allnil.push(f306000)
f306000 = '0' if (f306000.to_s.length == 0)
f307000 = c['f307000'].to_s.tr('-,','')
allnil.push(f307000)
f307000 = '0' if (f307000.to_s.length == 0)

if (allnil.to_s.length == 0)
  errMsg("กรุณาบันทึก 0 ในช่องใดช่องหนึ่ง ก่อนกดปุ่ม [บันทึกข้อมูล]")
  exit
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")

chk = checkDup("form3", "f3year", "f3hcode", f3year, f3hcode)

chkDigit('f301000',f301000)
chkDigit('f302000',f302000)
chkDigit('f303000',f303000)
chkDigit('f304000',f304000)
chkDigit('f305000',f305000)
chkDigit('f306000',f306000)
chkDigit('f307000',f307000)

if chk.to_s == 'NODUP'

sql = "INSERT INTO form3(f3year,f3pname,f3pcode,f3hname,f3hcode,"
sql = sql <<  "f301000,f302000,f303000,f304000,f305000,f306000,f307000)"
sql = sql << "VALUES('#{f3year}','#{f3pname}','#{f3pcode}','#{f3hname}','#{f3hcode}',"
sql = sql << "'#{f301000}','#{f302000}','#{f303000}','#{f304000}','#{f305000}','#{f306000}','#{f307000}')"
res = con.exec(sql)

elsif chk == 'DUP'

sql = "UPDATE form3 SET "
sql = sql << "f301000='#{f301000.to_s}',f302000='#{f302000.to_s}',"
sql = sql << "f303000='#{f303000.to_s}',f304000='#{f304000.to_s}',"
sql = sql << "f305000='#{f305000.to_s}',f306000='#{f306000.to_s}',"
sql = sql << "f307000='#{f307000.to_s}' "
sql = sql << "WHERE f3year='#{f3year}' and f3hcode='#{f3hcode}' "
res = con.exec(sql)

end

con.close

updateReportMon(f3hcode.to_s,f3year.to_s,"form3")

# Routine check if all forms (f1-f4 or f5-f8) for hcode is complete?
checkComplete(f3hcode)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<body text='blue'>
<center>
<h2>บันทึกแบบฟอร์ม 3 สำหรับ #{ f3hname.to_s }(#{ f3hcode.to_s }) เรียบร้อยแล้ว</h2>
<h3>โปรดบันทึกแบบฟอร์มที่ 4 ต่อไป</h3>
<p>
<input type='button' value='Back' onClick='history.back();'>
</center>
</body>
</html>
EOF
