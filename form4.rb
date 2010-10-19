#!/usr/bin/ruby
                                                                                
require 'cgi'
require 'postgres'
require 'hr_util.rb'
require 'res_util.rb'

allnil = Array.new

c = CGI::new

f4year = c['f4year'].to_s
f4pname = c['f4pname'].to_s
f4pcode  = c['f4pcode'].to_s
f4hname = c['f4hname'].to_s
f4hcode  = c['f4hcode'].to_s
f401010 = c['f401010'].to_s.tr('-,','')
f401010 = '0' if (f401010.to_s.length == 0)
f402010 = c['f402010'].to_s.tr('-,','') 
allnil.push(f402010)
f402010 = '0' if (f402010.to_s.length == 0)
f402020 = c['f402020'].to_s.tr('-,','')
allnil.push(f402020)
f402020 = '0' if (f402020.to_s.length == 0)
f402030 = c['f402030'].to_s.tr('-,','') 
allnil.push(f402030)
f402030 = '0' if (f402030.to_s.length == 0)
f402040 = c['f402040'].to_s.tr('-,','')
allnil.push(f402040)
f402040 = '0' if (f402040.to_s.length == 0)
f402050 = c['f402050'].to_s.tr('-,','') 
allnil.push(f402050)
f402050 = '0' if (f402050.to_s.length == 0)
f402060 = c['f402060'].to_s.tr('-,','')
allnil.push(f402060)
f402060 = '0' if (f402060.to_s.length == 0)
f402070 = c['f402070'].to_s.tr('-,','') 
allnil.push(f402070)
f402070 = '0' if (f402070.to_s.length == 0)
f402080 = c['f402080'].to_s.tr('-,','') 
allnil.push(f402080)
f402080 = '0' if (f402080.to_s.length == 0)
f402090 = c['f402090'].to_s.tr('-,','') 
allnil.push(f402090)
f402090 = '0' if (f402090.to_s.length == 0)
f402100 = c['f402100'].to_s.tr('-,','') 
allnil.push(f402100)
f402100 = '0' if (f402100.to_s.length == 0)
f402110 = c['f402110'].to_s.tr('-,','') 
allnil.push(f402110)
f402110 = '0' if (f402110.to_s.length == 0)
f402120 = c['f402120'].to_s.tr('-,','') 
allnil.push(f402120)
f402120 = '0' if (f402120.to_s.length == 0)

# Validate Hospitals must have beds (f402010)
isHospital = chkHospital(f4hcode)
if (isHospital)
  if (f402010.to_s.to_i == 0) # Hospital with no bed!!
    popupMsg("กรุณาบันทึกจำนวนเตียง #{f4hname}")
  end
end

# Validate 2.8 > 2.7 / 2.10 > 2.9 / 2.11 <==> 2.1 / 2.12 > 2.11
msg = nil
if (f402080.to_s.to_i < f402070.to_s.to_i)
  msg = "#{msg}จำนวนครั้ง (2.8) ต้องไม่น้อยกว่าจำนวนคน (2.7)<br />"
end
if (f402100.to_s.to_i < f402090.to_s.to_i)
  msg = "#{msg}จำนวนรับบริการทั้งหมด (2.10) ต้องไม่น้อยกว่าจำนวนรับบริการครั้งแรก (2.9)<br />"
end
if (f402010.to_s.to_i > 0 && f402110.to_s.to_i == 0)
  msg = "#{msg}จำนวนผู้ป่วยใน (2.11) ต้องมากกว่า 0 ในกรณีทีมีจำนวนเตียง (2.1) = #{f402010}<br />"
end
if (f402010.to_s.to_i > 0 && f402120.to_s.to_i == 0)
  msg = "#{msg}จำนวนวันนอน (2.12) ต้องมากกว่า 0 ในกรณีทีมีจำนวนเตียง (2.1) = #{f402010}<br />"
end
if (f402110.to_s.to_i > 0 && f402010.to_s.to_i == 0)
  msg = "#{msg}จำนวนผู้ป่วยใน (2.11) จะมีค่าได้ในกรณีทีจำนวนเตียง (2.1) ต้องมากกว่า 0<br />"
end
if (f402120.to_s.to_i < f402110.to_s.to_i)
  msg = "#{msg}จำนวนวันนอน(2.12) ต้องไม่น้อยกว่าจำนวนผู้ป่วยใน (2.11)<br />"
end
if !(msg.nil?)
  popupMsg("#{f4hname}<p>#{msg}")
end

if (allnil.to_s.length == 0)
  errMsg("กรุณาบันทึก 0 ในช่องใดช่องหนึ่ง ก่อนกดปุ่ม [บันทึกข้อมูล]")
  exit
end
  
con = PGconn.connect("localhost",5432,nil,nil,"resource53")

chk = checkDup("form4", "f4year", "f4hcode", f4year, f4hcode)

chkDigit('f401010',f401010)
chkDigit('f402010',f402010) 
chkDigit('f402020',f402020)
chkDigit('f402030',f402030) 
chkDigit('f402040',f402040)
chkDigit('f402050',f402050) 
chkDigit('f402060',f402060)
chkDigit('f402070',f402070) 
chkDigit('f402080',f402080) 
chkDigit('f402090',f402090) 
chkDigit('f402100',f402100) 
chkDigit('f402110',f402110) 
chkDigit('f402120',f402120) 

if chk.to_s == 'NODUP'

sql = "INSERT INTO  form4(f4year,f4pname,f4pcode,f4hname,f4hcode,"
sql = sql << "f401010,f402010,f402020,"
sql = sql << "f402030,f402040,f402050,f402060,f402070,"
sql = sql << "f402080,f402090,f402100,f402110,f402120)"
sql = sql << "VALUES('#{f4year}','#{f4pname}','#{f4pcode}','#{f4hname}','#{f4hcode}',"
sql = sql << "'#{f401010}','#{f402010}','#{f402020}',"
sql = sql << "'#{f402030}','#{f402040}','#{f402050}','#{f402060}','#{f402070}',"
sql = sql << "'#{f402080}','#{f402090}','#{f402100}','#{f402110}','#{f402120}')"
res = con.exec(sql)

elsif chk == 'DUP'

sql = "UPDATE form4 SET "
sql = sql << "f401010='#{f401010.to_s}',"
sql = sql << "f402010='#{f402010.to_s}',"
sql = sql << "f402020='#{f402020.to_s}',f402030='#{f402030.to_s}',"
sql = sql << "f402040='#{f402040.to_s}',f402050='#{f402050.to_s}',"
sql = sql << "f402060='#{f402060.to_s}',f402070='#{f402070.to_s}',"
sql = sql << "f402080='#{f402080.to_s}',f402090='#{f402090.to_s}',"
sql = sql << "f402100='#{f402100.to_s}',f402110='#{f402110.to_s}',"
sql = sql << "f402120='#{f402120.to_s}' "
sql = sql << "WHERE f4year='#{f4year}' and f4hcode='#{f4hcode}' "
res = con.exec(sql)

end

con.close

updateReportMon(f4hcode,f4year,"form4")

# Routine check if all forms (f1-f4 or f5-f8) for hcode is complete?
checkComplete(f4hcode)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<body text='blue'>
<center>
<h2>บันทึกแบบฟอร์ม 4 สำหรับ #{ f4hname.to_s }(#{ f4hcode.to_s }) เรียบร้อยแล้ว</h2>
<p>
<input type='button' value='Back' onClick='history.back();'>
</center>
</body>
</html>
EOF
