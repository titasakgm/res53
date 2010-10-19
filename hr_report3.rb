#!/usr/bin/ruby

require 'postgres'
require 'res_util.rb'
require 'cgi'

c = CGI::new
provid = c['provid']
province = getProvName(provid)

today = todayThai()

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT provid,ampid,amphoe,reporter,tel,total,"
sql += "govt,private,balance,totgovt,totpriv FROM report2 "
sql += "WHERE provid='#{provid}' "
sql += "ORDER BY ampid"
res = con.exec(sql)
con.close

print <<EOF
Content-type: text/html

<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<body text='purple'>
<center>
<h4>REPORT 3: ความคืบหน้าการบันทึกข้อมูลทรัพยากร จังหวัด#{province}<p>
<font size=3><i><b>#{today}</b></i></font></h4>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
<p>
<table width='90%' border='1'>
<tr bgcolor='yellow'>
  <th rowspan='2'>อำเภอ</th><th rowspan='2'>ผู้รายงาน</th><th rowspan='2'>โทรฯ</th>
  <th rowspan='2'>Total</th><th colspan='3'>ภาครัฐ</th>
  <th colspan='3'>ภาคเอกชน</th>
  <th rowspan='2'>คงเหลือ</th>
  <th rowspan='2'width='15%'>รายละเอียด</th>
</tr>
<tr bgcolor='yellow'>
  <th>ยอด<br />รวม</th><th>บันทึก<br />แล้ว</th><th>คง<br />เหลือ</th>
  <th>ยอด<br />รวม</th><th>บันทึก<br />แล้ว</th><th>คง<br />เหลือ</th>
</tr>
EOF
ttx = gox = pvx = bax = 0
totg = totp = 0
totgx = totpx = 0

res.each do |rec|
  pc = rec[0].to_s
  ac = rec[1].to_s
  amp = rec[2]
  rep = rec[3]
  tel = rec[4]
  tt = rec[5].to_i
  go = rec[6].to_i
  pv = rec[7].to_i
  ba = rec[8].to_i
  totg = rec[9].to_i
  totp = rec[10].to_i
  
  amp += " (สสจ.)" if ac == '00'
  amp += " (สสอ.)" if ac == '01'
  ttx += tt
  gox += go
  pvx += pv
  bax += ba
  totgx += totg
  totpx += totp 
  tel = '&nbsp;' if tel.nil?

  trCol =(ba == 0) ? '#D0F6D6' : 'white'
  if (tt == ba)
    trCol = '#F8C1C2'
  end
  print "<tr bgcolor='#{trCol}'>"
  print "<th align='left'>&nbsp;&nbsp;#{amp}</th>"
  print "<td>#{rep}</td><td>#{tel}</td>"
  print "<td align='right'>#{tt}</td>"
  print "<td align='right'>#{totg}</td>"
  print "<td align='right'><font color='green'><b>#{go}</b></font></td>"
  print "<td align='right'>#{totg-go}</td>"
  print "<td align='right'>#{totp}</td>"
  print "<td align='right'><font color='green'><b>#{pv}</b></font></td>"
  print "<td align='right'>#{totp-pv}</td>"
  print "<td align='right'>#{ba}</td>"
  print "<td width='10%'><input type='button' value='More..' style='width:100%;' "
  print "onClick=\"document.location.href='hr_report4.rb?"
  print "provid=#{pc}#{ac}'\" /></td></tr>\n"
end

# For grand Total
print "<tr bgcolor='#C9C9C9'>"
print "<th align='left'>&nbsp;</th>"
print "<th align='right'>Grand Total</th><td>&nbsp;</td>"
print "<td align='right'>#{ttx}</td>"
print "<td align='right'>#{totgx}</td>"
print "<td align='right'><font color='green'><b>#{gox}</b></font></td>"
print "<td align='right'>#{totgx-gox}</td>"
print "<td align='right'>#{totpx}</td>"
print "<td align='right'><font color='green'><b>#{pvx}</b></font></td>"
print "<td align='right'>#{totpx-pvx}</td>"
print "<td align='right'>#{bax}</td>"
print "<td width='10%'>&nbsp;</td></tr>\n"

print <<EOF
</table>
<p>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
</center>
</body>
</html>
EOF
