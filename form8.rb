#!/usr/bin/ruby
                                                                                
require 'cgi'                                                      
require 'postgres'                                              
require 'hr_util.rb'
require 'res_util.rb'

allnil = Array.new

c = CGI::new

f8year = c['f8year'].to_s
f8pname = c['f8pname'].to_s
f8pcode  = c['f8pcode'].to_s
f8hname = c['f8hname'].to_s
f8hcode  = c['f8hcode'].to_s
f801010 = c['f801010'].to_s.tr('-,','')
f801010 = '0' if (f801010.to_s.length == 0)
f802010 = c['f802010'].to_s.tr('-,','') 
allnil.push(f802010)
f802010 = '0' if (f802010.to_s.length == 0)
f802020 = c['f802020'].to_s.tr('-,','')
allnil.push(f802020)
f802020 = '0' if (f802020.to_s.length == 0)
f802030 = c['f802030'].to_s.tr('-,','') 
allnil.push(f802030)
f802030 = '0' if (f802030.to_s.length == 0)
f802040 = c['f802040'].to_s.tr('-,','')
allnil.push(f802040)
f802040 = '0' if (f802040.to_s.length == 0)
f802050 = c['f802050'].to_s.tr('-,','') 
allnil.push(f802050)
f802050 = '0' if (f802050.to_s.length == 0)
f802060 = c['f802060'].to_s.tr('-,','')
allnil.push(f802060)
f802060 = '0' if (f802060.to_s.length == 0)
f802070 = c['f802070'].to_s.tr('-,','') 
allnil.push(f802070)
f802070 = '0' if (f802070.to_s.length == 0)
f802080 = c['f802080'].to_s.tr('-,','') 
allnil.push(f802080)
f802080 = '0' if (f802080.to_s.length == 0)
f802090 = c['f802090'].to_s.tr('-,','') 
allnil.push(f802090)
f802090 = '0' if (f802090.to_s.length == 0)
f802100 = c['f802100'].to_s.tr('-,','') 
allnil.push(f802100)
f802100 = '0' if (f802100.to_s.length == 0)
f802110 = c['f802110'].to_s.tr('-,','') 
allnil.push(f802110)
f802110 = '0' if (f802110.to_s.length == 0)
f802120 = c['f802120'].to_s.tr('-,','') 
allnil.push(f802120)
f802120 = '0' if (f802120.to_s.length == 0)

# Validate Hospitals must have beds (f402010)
isHospital = chkHospital(f8hcode)
if (isHospital)
  if (f802010.to_s.to_i == 0) # Hospital with no bed!!
    popupMsg("กรุณาบันทึกจำนวนเตียง #{f8hname}")
  end
end

# Validate 2.8 > 2.7 / 2.10 > 2.9 / 2.11 <==> 2.1 / 2.12 > 2.11
msg = nil
if (f802080.to_s.to_i < f802070.to_s.to_i)
  msg = "#{msg}จำนวนครั้ง (2.8) ต้องไม่น้อยกว่าจำนวนคน (2.7)<br />"
end
if (f802100.to_s.to_i < f802090.to_s.to_i)
  msg = "#{msg}จำนวนรับบริการทั้งหมด (2.10) ต้องไม่น้อยกว่าจำนวนรับบริการครั้งแรก (2.9)<br />"
end
if (f802110.to_s.to_i > 0 && f802010.to_s.to_i == 0)
  msg = "#{msg}จำนวนผู้ป่วยใน (2.11) จะมีค่าได้ในกรณีทีจำนวนเตียง (2.1) ต้องมากกว่า 0<br />"
end
if (f802120.to_s.to_i < f802110.to_s.to_i)
  msg = "#{msg}จำนวนวันนอน(2.12) ต้องไม่น้อยกว่าจำนวนผู้ป่วยใน (2.11)<br />"
end
if !(msg.nil?)
  popupMsg("#{f8hname}<p>#{msg}")
end

if (allnil.to_s.length == 0)
  errMsg("กรุณาบันทึก 0 ในช่องใดช่องหนึ่ง ก่อนกดปุ่ม [บันทึกข้อมูล]")
  exit
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")

chk = checkDup("form8", "f8year", "f8hcode", f8year, f8hcode)

chkDigit('f801010',f801010)
chkDigit('f802010',f802010) 
chkDigit('f802020',f802020)
chkDigit('f802030',f802030) 
chkDigit('f802040',f802040)
chkDigit('f802050',f802050) 
chkDigit('f802060',f802060)
chkDigit('f802070',f802070) 
chkDigit('f802080',f802080) 
chkDigit('f802090',f802090) 
chkDigit('f802100',f802100) 
chkDigit('f802110',f802110) 
chkDigit('f802120',f802120) 


if chk.to_s == 'NODUP'

sql = "INSERT INTO form8(f8year,f8pname,f8pcode,f8hname,f8hcode,"
sql = sql << "f801010,"
sql = sql << "f802010,f802020,f802030,"
sql = sql << "f802040,f802050,f802060,"
sql = sql << "f802070,f802080,f802090,"
sql = sql << "f802100,f802110,f802120) "
sql = sql << "VALUES('#{f8year}','#{f8pname}','#{f8pcode}','#{f8hname}','#{f8hcode}',"
sql = sql << "'#{f801010}',"
sql = sql << "'#{f802010}','#{f802020}','#{f802030}',"  
sql = sql << "'#{f802040}','#{f802050}','#{f802060}',"
sql = sql << "'#{f802070}','#{f802080}','#{f802090}',"
sql = sql << "'#{f802100}','#{f802110}','#{f802120}')"
res = con.exec(sql)
   
elsif chk == 'DUP'

sql = "UPDATE form8 SET "
sql = sql << "f801010='#{ f801010 }',"
sql = sql << "f802010='#{ f802010 }',f802020='#{ f802020 }',f802030='#{ f802030 }',"
sql = sql << "f802040='#{ f802040 }',f802050='#{ f802050 }',f802060='#{ f802060 }',"
sql = sql << "f802070='#{ f802070 }',f802080='#{ f802080 }',f802090='#{ f802090 }',"
sql = sql << "f802100='#{ f802100 }',f802110='#{ f802110 }',f802120='#{ f802120 }' "
sql = sql << "WHERE f8year='#{f8year}' and f8hcode='#{f8hcode}' "
res = con.exec(sql)

end

con.close

updateReportMon(f8hcode,f8year,"form8")

# Routine check if all forms (f1-f4 or f5-f8) for hcode is complete?
checkComplete(f8hcode)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<body text='blue'>
<center>
<h2>บันทึกแบบฟอร์ม 4 สำหรับ #{ f8hname.to_s }(#{ f8hcode.to_s }) เรียบร้อยแล้ว</h2>
<p>
<input type='button' value='Back' onClick='history.back();'>
</center>
</body>
</html>
EOF

