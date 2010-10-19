#!/usr/bin/ruby

require 'postgres'
require 'cgi'
require 'res_util.rb'

def displayReport(province,amphoe,res)

today = todayThai()
print <<EOF
Content-type: text/html

<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<body text='purple'>
<center>
<h4>REPORT 4: รายละเอียดการบันทึกข้อมูล#{amphoe} จังหวัด#{province}<p>
<font size=3><i><b>#{today}</b></i></font></h4>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
<p>
<table width='90%' border='1'>
<tr>
  <th>ลำดับ</th><th>รหัส</th><th>หน่วยงาน</th><th>F1</th><th>F2</th><th>F3</th>
  <th>F4</th><th>F5</th><th>F6</th><th>F7</th><th>F8</th><th>วันรายงาน</th>
</tr>
EOF

n = 0
res.each do |rec|
  hc = rec[0].to_s
  f1 =(rec[3].to_s.length == 0) ? '&nbsp;' : rec[3].to_s
  f2 =(rec[4].to_s.length == 0) ? '&nbsp;' : rec[4].to_s
  f3 =(rec[5].to_s.length == 0) ? '&nbsp;' : rec[5].to_s
  f4 =(rec[6].to_s.length == 0) ? '&nbsp;' : rec[6].to_s
  f5 =(rec[7].to_s.length == 0) ? '&nbsp;' : rec[7].to_s
  f6 =(rec[8].to_s.length == 0) ? '&nbsp;' : rec[8].to_s
  f7 =(rec[9].to_s.length == 0) ? '&nbsp;' : rec[9].to_s
  f8 =(rec[10].to_s.length == 0) ? '&nbsp;' : rec[10].to_s
  rd =(rec[11].to_s.length == 0) ? '&nbsp;' : rec[11].to_s
  off = getOffName(hc)
  otype = getOffType(hc)

  # Special char for f1 of MOPH
  f1 = '@' if (otype == 'M')
  #f1 = '@' if (hc == '02951' || hc == '02952')

  if (otype == 'P')
    f1bg = f2bg = f3bg = f4bg = '#CCCCCC'
    f5bg = f6bg = f7bg = f8bg = '#FFFFFF'
  else
    f1bg = f2bg = f3bg = f4bg = '#FFFFFF'
    f5bg = f6bg = f7bg = f8bg = '#CCCCCC'
    # check if HC -> f2 disabled
    if (chkOtypeHC(hc) == 'DISABLED')
      f2 = '&nbsp;'
      f2bg = '#CCCCCC'
    end
  end
  f1 = '&#8730;' if (f1 == 'X')
  f2 = '&#8730;' if (f2 == 'X')
  f3 = '&#8730;' if (f3 == 'X')
  f4 = '&#8730;' if (f4 == 'X')
  f5 = '&#8730;' if (f5 == 'X')
  f6 = '&#8730;' if (f6 == 'X')
  f7 = '&#8730;' if (f7 == 'X')
  f8 = '&#8730;' if (f8 == 'X')
  n += 1
  print "<tr><th>#{n}</th><th>#{hc}</th>"
  print "<td>(#{otype})#{off}</td>"
  print "<th bgcolor='#{f1bg}'>#{f1}</th>"
  print "<th bgcolor='#{f2bg}'>#{f2}</th>"
  print "<th bgcolor='#{f3bg}'>#{f3}</th>"
  print "<th bgcolor='#{f4bg}'>#{f4}</th>"
  print "<th bgcolor='#{f5bg}'>#{f5}</th>"
  print "<th bgcolor='#{f6bg}'>#{f6}</th>"
  print "<th bgcolor='#{f7bg}'>#{f7}</th>"
  print "<th bgcolor='#{f8bg}'>#{f8}</th>"
  print "<th>#{rd}</th></tr>\n"
end

print <<EOF
</table>
</center>
<pre>
<b>หมายเหตุ:</b>
  @ = แยกอยู่ในฐานโปรแกรม PIS
  &#8730; =   บันทึกข้อมูลแล้ว
  สีเทา = ไม่ต้อง key ข้อมูล
</pre>
<center>
<p>
<input type='button' value='กลับหน้าที่แล้ว' onclick='history.back()' />
</center>
</body>
</html>
EOF

end

def getProvName(provid)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_province FROM prov WHERE o_provid='#{provid}'"
  res = con.exec(sql)
  numRes = res.num_tuples
  province = 'n/a'
  if numRes == 1
    province = res[0][0].to_s
  end
  res.clear
  con.close
  province
end

def getOffName(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT trim(o_name),trim(o_province) FROM office53 "
  sql += "WHERE o_code='#{hcode}'"
  res = con.exec(sql)
  numRes = res.num_tuples
  office = 'n/a'
  if numRes == 1
    office = res[0][0].to_s.split(',').first
  end
  res.clear
  con.close
  office
end

def getOffType(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_type FROM office53 "
  sql += "WHERE o_code='#{hcode}'"
  res = con.exec(sql)
  con.close
  numRes = res.num_tuples
  otype = 'n/a'
  if numRes == 1
    otype = res[0][0]
  end
  res.clear
  otype
end

c = CGI::new
id = c['provid'].split('').join('')
pcode = id[0..1]
acode = id[2..3]

province = getProvName(pcode)
amphoe = nil
amphoe = "อำเภอ" + getAmpName(pcode,acode) 

if (pcode == '10')
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM reportmon WHERE pcode='10' "
  sql += "ORDER BY hcode"
  res = con.exec(sql)
  con.close
  displayReport(province,'',res)
else
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM reportmon "
  sql += "WHERE pcode='#{pcode}' AND acode='#{acode}' "
  sql += "ORDER BY hcode,acode"
  res = con.exec(sql)
  con.close
  log("hr_report2: #{sql}")
  displayReport(province,amphoe,res)
end
