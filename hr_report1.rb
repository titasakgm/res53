#!/usr/bin/ruby

require 'postgres'
require 'res_util.rb'

today = todayThai()

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT provid,province,sum(total) as xtotal,"
sql += "sum(govt) as xgovt,sum(private) as xprivate,"
sql += "sum(balance) as xbalance,sum(totgovt) as xtotg,"
sql += "sum(totpriv) as xtotp FROM report2 "
sql += "GROUP BY provid,province "
sql += "ORDER BY provid"
res = con.exec(sql)
con.close

print <<EOF
Content-type: text/html

<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<body text='purple' bgcolor='#EBE9ED'>
<center>
<h4>REPORT 1: ความคืบหน้าการบันทึกข้อมูลทรัพยากร<p>
<font size=3><i><b>#{today}</b></i></font></h4>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
<p>
<table width='90%' border='1'>
<tr bgcolor='yellow'>
  <th rowspan='2'>จังหวัด</th><th rowspan='2'>ผู้รายงาน</th><th rowspan='2'>โทรฯ</th>
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
totgx = totpx = 0
res.each do |rec|
  id = rec[0].to_s
  pr = rec[1].to_s
  tt = rec[2].to_i
  go = rec[3].to_i
  pv = rec[4].to_i
  ba = rec[5].to_i
  totg = rec[6].to_i
  totp = rec[7].to_i

  ttx += tt
  gox += go
  pvx += pv
  bax += ba
  totgx += totg
  totpx += totp

  reptel = getProvReporter(id)
  rep = reptel.split('|')[0]
  tel = reptel.split('|')[1]
  tel = '&nbsp;' if tel.nil?

  trCol =(ba == 0) ? '#D0F6D6' : 'white'
  if tt == ba
    trCol = '#F8C1C2'
  end
  print "<tr bgcolor='#{trCol}'>"
  print "<td><input type='button' value='#{pr}' style='width:100%;' "
  print "onClick=\"document.location.href='hr_report3.rb?provid=#{id}'\"></td>"
  print "<td>#{rep}</td><td>#{tel}</td>"
  print "<td align='right'>#{tt}</td>"
  print "<td align='right'>#{totg}</td>"
  print "<td align='right'><font color='green'><b>#{go}</b></font></td>"
  print "<td align='right'>#{totg-go}</td>"
  print "<td align='right'>#{totp}</td>"
  print "<td align='right'><font color='green'><b>#{pv}</b></font></td>"
  print "<td align='right'>#{totp-pv}</td>"
  print "<td align='right'>#{ba}</td>"
  print "<td><input type='button' value='More..' style='width:100%;' "
  print "onclick=\"document.location.href='hr_report2.rb?provid=#{id}'\"></td></tr>\n"
end

# print Grand Total
print "<tr bgcolor='#C9C9C9'>"
print "<td>&nbsp;</td>"
print "<th align='right'>Grand Total</th><td>&nbsp;</td>"
print "<td align='right'>#{ttx}</td>"
print "<td align='right'>#{totgx}</td>"
print "<td align='right'><font color='green'><b>#{gox}</b></font></td>"
print "<td align='right'>#{totgx-gox}</td>"
print "<td align='right'>#{totpx}</td>"
print "<td align='right'><font color='green'><b>#{pvx}</b></font></td>"
print "<td align='right'>#{totpx-pvx}</td>"
print "<td align='right'>#{bax}</td>"
print "<td>&nbsp;</td></tr>\n"

print <<EOF
</table>
<p>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
</center>
</body>
</html>
EOF

