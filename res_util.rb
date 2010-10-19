#!/usr/bin/ruby

require 'postgres'
require 'iconv'

class String
  def to_iso
    Iconv.conv('ISO-8859-11', 'utf-8', self)
  end
end

class NilClass
  def to_iso
    Iconv.conv('ISO-8859-11', 'utf-8', '')
  end
end

def log(msg)
  log = open("/tmp/res53.log","a")
  log.write(msg)
  log.write("\n")
  log.close
end

def notOwner(user,hcode)
print <<EOF
Content-type: text/html

<h4>ขออภัย ไม่พบรหัสหน่วยงาน #{hcode} สำหรับ User: #{user}</h4>
<p>
<input type="button" value="Back" onclick="history.back()" />
EOF
end


def errMsg(msg)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<body text="red">
<center>
#{msg}
<p>
<input type="button" value="Back" onClick='history.back();'>
</center>
</body>
</html>
EOF
exit

end

def checkOwnerOld(user,hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_code FROM office53 WHERE o_code='#{hcode}' "
  if (user.length == 2)
    sql += "AND o_provid='#{user}' " 
  elsif (user.length == 4)
    sql += "AND o_provid || o_ampid = '#{user}' "
  end
  res = con.exec(sql)
  con.close
  numRec = res.num_tuples
  flag = (numRec == 0) ? false : true
end

def authenUser(user,pass)
  admin = false
  sessid = "FAILED"
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  if (user == 'admin')
    sql = "SELECT adm_name FROM admin WHERE adm_name='#{user}' and adm_pwd='#{pass}'"
  else
    sql = "SELECT username FROM member WHERE username='#{user}' and password='#{pass}'"
  end
  res = con.exec(sql)
  con.close
  numRec = res.num_tuples

  #Check if province admin login
  if (user =~ /01$/) # maybe admin
    admin = user.to_s.split('').join('')[0..1]
    admin = checkAdminPass(admin,pass)
  end
  
  if numRec == 1 || admin
    r = rand() * 10000000000
    sessid = r.to_i
    setSession(user, sessid)
  end
  sessid

=begin
  if (pass == 'hic52')
    r = rand() * 10000000000
    sessid = r.to_i
    setSession(user, sessid)
  end
  sessid
=end
end

def checkAdminPass(user,pass)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT username FROM member WHERE username='#{user}' and password='#{pass}'"
  #log("checkAdminPass: #{user} #{pass}\n#{sql}")
  res = con.exec(sql)
  con.close
  numRec = res.num_tuples
  admin = (numRec == 1) ? true : false
end

def setSession(user, sessid)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT sess_user FROM  session WHERE sess_user='#{user}' "
  res = con.exec(sql)
  found = res.num_tuples
  if (found == 0) # not login yet
    sql = "INSERT INTO session VALUES ('#{user}', '#{sessid}') "
  else # previously logged in
    sql = "UPDATE session SET sess_id='#{sessid}' WHERE sess_user='#{user}' "
  end
  res = con.exec(sql)
  con.close
end

def checkSession(user, sessid)
  flag = false
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT sess_user FROM  session WHERE sess_user='#{user}'  "
  sql += "AND sess_id='#{sessid}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  if (found == 1) # valid session
    flag = true
  end
  flag
end

def getUserInfo(user)
  info = nil
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT fname,lname,telno,email FROM  member "
  sql += "WHERE username='#{user}'  "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  if (found == 1) # valid user
    res.each do |rec|
      fn = rec[0]
      ln = rec[1]
      tel = rec[2]
      eml = rec[3]
      info = "#{fn}|#{ln}|#{tel}|#{eml}"
    end
  end
  info
end

def todayThai()
  tmon = ['','ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.','ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.']
  tmonth = ['','มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน','กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม']
  twday = ['อาทิตย์','จันทร์','อังคาร','พุธ','พฤหัสบดี','ศุกร์','เสาร์']
  t = Time.now
  yyyy = t.year + 543
  mm = t.mon
  dd = t.day
  wd = t.wday
  tday = "#{twday[wd]} #{dd} #{tmonth[mm]} #{yyyy}"
end

def getWorkSummary(user)
  info = nil
  user = user.to_s.split('').join('')
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  if (user.length == 2)
    sql = "SELECT province,total,govt,private,balance FROM report2 "
    sql += "WHERE provid='#{user}' "
    sql += "AND ampid='00' " if (user != '10')
  elsif (user.length == 4) # DHO
    sql = "SELECT amphoe,total,govt,private,balance FROM  report2 "
    sql += "WHERE provid='#{user[0..1]}' AND ampid='#{user[2..3]}' "
  end
  #log("getWorkSummary: #{sql}")
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  if (found > 0) # valid provid/user
    res.each do |rec|
      pn = rec[0]
      tot = rec[1].to_s.to_i
      gov = rec[2].to_s.to_i
      prv = rec[3].to_s.to_i
      bal = rec[4].to_s.to_i
      info = "#{pn}|#{tot}|#{gov}|#{prv}|#{bal}"
    end
  end
  #log("info: #{info}")
  info
end

def getOffByProv(pcode)
  allHosp = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT hcode,stat,hname,otype FROM chkcomplete "
  sql += "WHERE pcode='#{pcode}' "
  if (pcode != '10')
    sql += "AND acode='00' "
    #sql += "AND (hname NOT LIKE 'สถานบริการสาธารณสุขชุมชน%' ) "
    #sql += "AND (hname NOT LIKE '%สอ.%' AND hname NOT LIKE '%สสอ.%' "
    #sql += "AND hname NOT LIKE '%อนามัย%') "
  end
  sql += "ORDER BY hcode"
  #log("getOffByProv: #{sql}")
  res = con.exec(sql)
  con.close
  res.each do |rec|
    hc = rec[0]
    stat = rec[1]
    hn = rec[2]
    ot = rec[3]
    info = "#{hc}|#{stat}|#{hn}|#{ot}"
    allHosp.push(info)
  end
  allHosp
end

def getOffByAmp(acode)
  allHosp = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT hcode,stat,hname,otype FROM chkcomplete "
  sql += "WHERE pcode||acode='#{acode}' "
  #sql += "AND (hname NOT LIKE 'สถานบริการสาธารณสุขชุมชน%' ) "
  #if (acode =~ /01$/)
    #sql += "AND (hname LIKE '%สอ.%' OR hname LIKE '%สสอ.%' OR hname LIKE '%อนามัย%') "
  #end
  sql += "ORDER BY hcode"
  res = con.exec(sql)
  con.close
  res.each do |rec|
    hc = rec[0]
    stat = rec[1]
    hn = rec[2]
    ot = rec[3]
    info = "#{hc}|#{stat}|#{hn}|#{ot}"
    allHosp.push(info)
  end
  allHosp
end

def getOffOK(offArr)
  optext = nil
  n = 0
  offArr.each do |i|
    f = i.to_s.split('|')
    hc = f[0]
    stat = f[1]
    hn = f[2]
    ot = f[3]
    next if stat == 'o'
    n += 1
    ord = sprintf("%03d", n)
    optext = "#{optext}<option value=#{hc}>[#{ord}] #{hc}-(#{stat}) #{hn} (#{ot})</option>\n"
  end
  optext
end

def getOffNOK(offArr)
  optext = nil
  n = 0
  offArr.each do |i|
    f = i.to_s.split('|')
    hc = f[0]
    stat = f[1]
    hn = f[2]
    ot = f[3]
    next if stat == 'x'
    n += 1
    ord = sprintf("%03d", n)
    optext = "#{optext}<option value=#{hc}>[#{ord}] #{hc}-(#{stat}) #{hn} (#{ot})</option>\n"
  end
  optext
end

def getProgress(code)
  pc = nil
  ac = nil
  code = code.to_s.split('').join('')
  if (code.length == 2)
    pc = code
    ac = '00'
  else
    pc = code[0..1]
    ac = code[2..3]
  end
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT otype,count(*) FROM chkcomplete "
  sql += "WHERE pcode='#{pc}' "
  sql += "AND acode='#{ac}' "  if (pc != '10')
  sql += "AND stat='x' "
  sql += "GROUP BY otype,stat "
  res = con.exec(sql)
  gok = pok = 0
  res.each do |rec|
    otype = rec[0]
    count = rec[1].to_i
    if (otype == 'G' || otype == 'M')
      gok += count
    else
      pok += count
    end
  end
  sql = "UPDATE report2 "
  sql += "SET govt=#{gok},private=#{pok},balance=total-#{gok}-#{pok} "
  sql += "WHERE provid='#{pc}' "
  sql += "AND ampid='#{ac}' " if (pc != '10')
  res = con.exec(sql)

  sql = "SELECT total,balance FROM report2 "
  sql += "WHERE provid='#{pc}' "
  sql += "AND ampid='#{ac}' " if (pc != '10') 
  res = con.exec(sql)
  con.close

  total = res[0][0].to_s.to_i
  balance = res[0][1].to_s.to_i

  if (total > 0)
    percent = (total-balance) / (total * 1.0) * 100
  else
    percent = 0
  end
  percent = sprintf("%.2f", percent.to_s)  
end

def getOtype(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_type FROM office53 WHERE o_code='#{hcode}' "
  sql += "AND o_provid <> '99' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  otype = (found == 1) ? res[0][0] : 'NA'
end

def f37header(type) 
  h1 = "ลำดับที่,ปี,จังหวัด,รหัส,หน่วยงาน,ประเภท,รหัส,CT,MRI,สลายนิ่ว,Gamma Knife,"
  h1 += "Ultrasound,Dialysis,รถพยาบาล\n"

  h2 = "<table border='1' width='100%'>"
  h2 += "<tr><th>ลำดับที่</th><th>ปี</th><th>จังหวัด</th><th>รหัส</th><th>หน่วยงาน</th><th>ประเภท</th>"
  h2 += "<th>รหัส</th><th>CT</th><th>MRI</th><th>สลายนิ่ว</th><th>Gamma Knife</th>"
  h2 += "<th>Ultrasound</th><th>Dialysis</th><th>รถพยาบาล</th></tr>\n"

  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def getForm3(year,pcode,acode,type)
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year}")
  sql = "SELECT * FROM form3 "
  if (acode.length == 4) # request from Amphoe
    if (acode =~ /01$/)
      sql += "WHERE (f3pcode='#{acode}' OR f3pcode='#{pcode}') "
    else
      sql += "WHERE f3pcode='#{acode}' "
    end
  else
    sql += "WHERE f3pcode='#{pcode}' "
  end
  sql += "ORDER BY f3hcode"
  log ("getForm3-sql: #{sql}")
  log ("getForm3-pcode: #{pcode} acode: #{acode}")
  res = con.exec(sql)
  con.close

  h1 = h2 = nil
  n = 0
  ord = otype = nil

  totalCol = Array.new

  res.each do |rec|
    n += 1
    ord = sprintf("%03d", n)
    f1 = rec[0]
    f2 = rec[1]
    f3 = rec[2]
    f4 = rec[3]
    f5 = rec[4].to_s
    otype = getOtype(f5)
    if (acode.length == 4)
      acodex = getAmpCode(f5)
      #log("acodex: #{acodex}")
      next if (acodex != acode)
    end
    f6 = rec[5].to_s.to_i
    f7 = rec[6].to_s.to_i
    f8 = rec[7].to_s.to_i
    f9 = rec[8].to_s.to_i
    f10 = rec[9].to_s.to_i
    f11 = rec[10].to_s.to_i
    f12 = rec[11].to_s.to_i

    (5..11).each do |x|
      if (totalCol[x].nil?)
        totalCol[x] = 0
      end
      totalCol[x] += rec[x].to_s.to_i
    end

    h1 = "#{h1}#{ord},#{f1},#{f2},#{f3},#{f4},#{otype},#{f5},#{f6},#{f7},#{f8},#{f9},#{f10},#{f11},#{f12}\n"

    h2 = "#{h2}<tr><th>#{ord}</th><th>#{f1}</th><th>#{f2}</th><th>#{f3}</th><td>#{f4}</td><th>#{otype}</th><th>#{f5}</th>"
    h2 += (f6 > 0) ? "<th class='hili'>#{f6}</th>" : "<th>#{f6}</th>"
    h2 += (f7 > 0) ? "<th class='hili'>#{f7}</th>" : "<th>#{f7}</th>"
    h2 += (f8 > 0) ? "<th class='hili'>#{f8}</th>" : "<th>#{f8}</th>"
    h2 += (f9 > 0) ? "<th class='hili'>#{f9}</th>" : "<th>#{f9}</th>"
    h2 += (f10 > 0) ? "<th class='hili'>#{f10}</th>" : "<th>#{f10}</th>"
    h2 += (f11 > 0) ? "<th class='hili'>#{f11}</th>" : "<th>#{f11}</th>"
    h2 += (f12 > 0) ? "<th class='hili'>#{f12}</th>" : "<th>#{f12}</th>"
    h2 += "</tr>\n"
  end

  h2 = "#{h2}<tr bgcolor='pink'><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th>"
  h2 += "<th align='right'>Total</th><th>&nbsp;</th><th>&nbsp;</th>"
  (5..11).each do |x|
    h2 += "<th><font color='red'>#{totalCol[x]}</th>"
  end
  h2 += "</tr>\n"

  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def getForm7(year,pcode,acode,type)
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year}")
  sql = "SELECT * FROM form7 "
  if (acode.length == 4) # request from Amphoe
    if (acode =~ /01$/)
      sql += "WHERE (f7pcode='#{acode}' OR f7pcode='#{pcode}') "
    else
      sql += "WHERE f7pcode='#{acode}' "
    end
  else
    sql += "WHERE f7pcode='#{pcode}' "
  end
  sql += "ORDER BY f7hcode"
  res = con.exec(sql)
  
  h1 = h2 = nil
  n = 0
  ord = otype = nil

  totalCol = Array.new

  found = res.num_tuples
  if (found > 0)
    res.each do |rec|
      n += 1
      ord = sprintf("%03d", n)
      f1 = rec[0]
      f2 = rec[1]
      f3 = rec[2]
      f4 = rec[3]
      f5 = rec[4].to_s
      otype = getOtype(f5)
      if (acode.to_s.length == 4)
        acodex = getAmpCode(f5)
        next if (acodex != acode)
      end
      f6 = rec[5].to_s.to_i
      f7 = rec[6].to_s.to_i
      f8 = rec[7].to_s.to_i
      f9 = rec[8].to_s.to_i
      f10 = rec[9].to_s.to_i
      f11 = rec[10].to_s.to_i
      f12 = rec[11].to_s.to_i

      (5..11).each do |x|
        if (totalCol[x].nil?)
          totalCol[x] = 0
        end
        totalCol[x] += rec[x].to_s.to_i
      end

      h1 = "#{h1}#{ord},#{f1},#{f2},#{f3},#{f4},#{otype},#{f5},#{f6},#{f7},#{f8},#{f9},#{f10},#{f11},#{f12}\n"

      h2 = "#{h2}<tr bgcolor='#CCCCCC'><th>#{ord}</th><th>#{f1}</th><th>#{f2}</th><th>#{f3}</th><td>#{f4}</td><th>#{otype}</th><th>#{f5}</th>"
      h2 += (f6 > 0) ? "<th class='hili'>#{f6}</th>" : "<th>#{f6}</th>"
      h2 += (f7 > 0) ? "<th class='hili'>#{f7}</th>" : "<th>#{f7}</th>"
      h2 += (f8 > 0) ? "<th class='hili'>#{f8}</th>" : "<th>#{f8}</th>"
      h2 += (f9 > 0) ? "<th class='hili'>#{f9}</th>" : "<th>#{f9}</th>"
      h2 += (f10 > 0) ? "<th class='hili'>#{f10}</th>" : "<th>#{f10}</th>"
      h2 += (f11 > 0) ? "<th class='hili'>#{f11}</th>" : "<th>#{f11}</th>"
      h2 += (f12 > 0) ? "<th class='hili'>#{f12}</th>" : "<th>#{f12}</th>"
      h2 += "</tr>\n"
    end

    h2 = "#{h2}<tr bgcolor='pink'><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th>"
    h2 += "<th align='right'>Total</th><th>&nbsp;</th><th>&nbsp;</th>"
    (5..11).each do |x|
      h2 += "<th><font color='red'>#{totalCol[x]}</th>"
    end
    h2 += "</tr>\n"

  else
    h1 = "&nbsp;"
    h2 = "<tr></tr>"
  end
  
  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def f48header(type)
  h1 = "ลำดับที่,ปี,จังหวัด,รหัส,หน่วยงาน,ประเภท,รหัส,2.1,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,2.10,2.11,2.12\n"

  h2 = "<table border='1' width='100%'>"
  h2 += "<tr><th>ลำดับที่</th><th>ปี</th><th>จังหวัด</th><th>รหัส</th><th>หน่วยงาน</th><th>ประเภท</th><th>รหัส</th>"

  h2 += "<th><a href='#' onmouseover=\"Tip(s201,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.1</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s202,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.2</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s203,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.3</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s204,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.4</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s205,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.5</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s206,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.6</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s207,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.7</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s208,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.8</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s209,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.9</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s210,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.10</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s211,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.11</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(s212,ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">2.12</a></th>"
  h2 += "</tr>\n"

  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def f48footer()
  h = "</table>\n"
  h += "<P><pre>หมายเหตุ<p>"
  h += "M = หน่วยงานกระทรวงสาธารณสุข\n"
  h += "G = หน่วยงานภาครัฐนอกกระทรวงสาธารณสุข\n"
  h += "P = หน่วยงานเอกชน\n\n"
  h += "2.1 จำนวนเตียงผู้ป่วย\n"
  h += "2.2 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) ศัลยกรรม\n"
  h += "2.3 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) อายุรกรรม\n"
  h += "2.4 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) กุมารเวชกรรม\n"
  h += "2.5 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) สูติ-นารีเวชกรรม\n"
  h += "2.6 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) รวม\n"
  h += "2.7 จำนวนผู้ป่วยนอกใหม่ที่มารับบริการครั้งแรกของปี\n"
  h += "2.8 จำนวนผู้ป่วยนอกทั้งหมดที่มารับบริการ\n"
  h += "2.9 จำนวนผู้รับบริการอื่น ๆที่มารับบริการครั้งแรก\n"
  h += "2.10 จำนวนผู้รับบริการอื่น ๆ ที่มารับบริการทั้งหมด\n"
  h += "2.11 จำนวนผู้ป่วยใน\n"
  h += "2.12 จำนวนวันอยู่ในโรงพยาบาล(Patient day)ของผู้ป่วยในทั้งหมด\n"
  h += "</pre>"
  h
end

def getForm4(year,pcode,acode,type)
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year}")
  sql = "SELECT * FROM form4 "
  if (acode.length == 4) # request from Amphoe
    if (acode =~ /01$/)
      sql += "WHERE (f4pcode='#{acode}' OR f4pcode='#{pcode}') "
    else
      sql += "WHERE f4pcode='#{acode}' "
    end
  else
    sql += "WHERE f4pcode='#{pcode}' "
  end  
  sql += "ORDER BY f4hcode"
  res = con.exec(sql)
  con.close

  h1 = h2 = nil
  n = 0
  ord = otype = nil

  totalCol = Array.new

  res.each do |rec|
    n += 1
    ord = sprintf("%03d", n)
    f1 = rec[0]
    f2 = rec[1]
    f3 = rec[2]
    f4 = rec[3]
    f5 = rec[4].to_s
    otype = getOtype(f5)
    if (acode.to_s.length == 4)
      acodex = getAmpCode(f5)
      next if (acodex != acode)
    end
    f6 = rec[8].to_s.to_i
    f7 = rec[9].to_s.to_i
    f8 = rec[10].to_s.to_i
    f9 = rec[11].to_s.to_i
    f10 = rec[12].to_s.to_i
    f11 = rec[13].to_s.to_i
    f12 = rec[14].to_s.to_i
    f13 = rec[15].to_s.to_i
    f14 = rec[16].to_s.to_i
    f15 = rec[17].to_s.to_i
    f16 = rec[18].to_s.to_i
    f17 = rec[19].to_s.to_i

    (8..19).each do |x|
      if (totalCol[x].nil?)
        totalCol[x] = 0
      end
      totalCol[x] += rec[x].to_s.to_i
    end

    h1 = "#{h1}#{ord},#{f1},#{f2},#{f3},#{f4},#{otype},#{f5},#{f6},#{f7},#{f8},#{f9},#{f10},#{f11},#{f12},"
    h1 += "#{f13},#{f14},#{f15},#{f16},#{f17}\n"

    h2 = "#{h2}<tr><th>#{ord}</th><th>#{f1}</th><th>#{f2}</th><th>#{f3}</th><td>#{f4}</td><th>#{otype}</th><th>#{f5}</th>"
    h2 += (f6 > 0) ? "<th class='hili'>#{f6}</th>" : "<th>#{f6}</th>"
    h2 += (f7 > 0) ? "<th class='hili'>#{f7}</th>" : "<th>#{f7}</th>"
    h2 += (f8 > 0) ? "<th class='hili'>#{f8}</th>" : "<th>#{f8}</th>"
    h2 += (f9 > 0) ? "<th class='hili'>#{f9}</th>" : "<th>#{f9}</th>"
    h2 += (f10 > 0) ? "<th class='hili'>#{f10}</th>" : "<th>#{f10}</th>"
    h2 += (f11 > 0) ? "<th class='hili'>#{f11}</th>" : "<th>#{f11}</th>"
    h2 += (f12 > 0) ? "<th class='hili'>#{f12}</th>" : "<th>#{f12}</th>"
    h2 += (f13 > 0) ? "<th class='hili'>#{f13}</th>" : "<th>#{f13}</th>"
    h2 += (f14 > 0) ? "<th class='hili'>#{f14}</th>" : "<th>#{f14}</th>"
    h2 += (f15 > 0) ? "<th class='hili'>#{f15}</th>" : "<th>#{f15}</th>"
    h2 += (f16 > 0) ? "<th class='hili'>#{f16}</th>" : "<th>#{f16}</th>"
    h2 += (f17 > 0) ? "<th class='hili'>#{f17}</th>" : "<th>#{f17}</th>"
    h2 += "</tr>\n"
  end

  h2 = "#{h2}<tr bgcolor='pink'><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th>"
  h2 += "<th align='right'>Total</th><th>&nbsp;</th><th>&nbsp;</th>"
  (8..19).each do |x|
    h2 += "<th><font color='red'>#{totalCol[x]}</font></th>"
  end
  h2 += "</tr>\n"

  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def getForm8(year,pcode,acode,type)
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year}")
  sql = "SELECT * FROM form8 "
  if (acode.length == 4) # request from Amphoe
    if (acode =~ /01$/)
      sql += "WHERE (f8pcode='#{acode}' OR f8pcode='#{pcode}') "
    else
      sql += "WHERE f8pcode='#{acode}' "
    end
  else
    sql += "WHERE f8pcode='#{pcode}' "
  end
  sql += "ORDER BY f8hcode"
  res = con.exec(sql)
  con.close

  h1 = h2 = nil
  n = 0
  ord = otype = nil

  totalCol = Array.new

  found = res.num_tuples
  if (found > 0)
    res.each do |rec|
      n += 1
      ord = sprintf("%03d", n)
      f1 = rec[0]
      f2 = rec[1]
      f3 = rec[2]
      f4 = rec[3]
      f5 = rec[4].to_s
      otype = getOtype(f5)
      if (acode.to_s.length == 4)
        acodex = getAmpCode(f5)
        next if (acodex != acode)
      end
      f6 = rec[8].to_s.to_i
      f7 = rec[9].to_s.to_i
      f8 = rec[10].to_s.to_i
      f9 = rec[11].to_s.to_i
      f10 = rec[12].to_s.to_i
      f11 = rec[13].to_s.to_i
      f12 = rec[14].to_s.to_i
      f13 = rec[15].to_s.to_i
      f14 = rec[16].to_s.to_i
      f15 = rec[17].to_s.to_i
      f16 = rec[18].to_s.to_i
      f17 = rec[19].to_s.to_i

      (8..19).each do |x|
        if (totalCol[x].nil?)
          totalCol[x] = 0
        end
        totalCol[x] += rec[x].to_s.to_i
      end

      h1 = "#{h1}#{ord},#{f1},#{f2},#{f3},#{f4},#{otype},#{f5},#{f6},#{f7},#{f8},#{f9},#{f10},#{f11},#{f12},"
      h1 += "#{f13},#{f14},#{f15},#{f16},#{f17}\n"

      h2 = "#{h2}<tr bgcolor='#CCCCCC'><th>#{ord}</th><th>#{f1}</th><th>#{f2}</th><th>#{f3}</th><td>#{f4}</td><th>#{otype}</th><th>#{f5}</th>"
      h2 += (f6 > 0) ? "<th class='hili'>#{f6}</th>" : "<th>#{f6}</th>"
      h2 += (f7 > 0) ? "<th class='hili'>#{f7}</th>" : "<th>#{f7}</th>"
      h2 += (f8 > 0) ? "<th class='hili'>#{f8}</th>" : "<th>#{f8}</th>"
      h2 += (f9 > 0) ? "<th class='hili'>#{f9}</th>" : "<th>#{f9}</th>"
      h2 += (f10 > 0) ? "<th class='hili'>#{f10}</th>" : "<th>#{f10}</th>"
      h2 += (f11 > 0) ? "<th class='hili'>#{f11}</th>" : "<th>#{f11}</th>"
      h2 += (f12 > 0) ? "<th class='hili'>#{f12}</th>" : "<th>#{f12}</th>"
      h2 += (f13 > 0) ? "<th class='hili'>#{f13}</th>" : "<th>#{f13}</th>"
      h2 += (f14 > 0) ? "<th class='hili'>#{f14}</th>" : "<th>#{f14}</th>"
      h2 += (f15 > 0) ? "<th class='hili'>#{f15}</th>" : "<th>#{f15}</th>"
      h2 += (f16 > 0) ? "<th class='hili'>#{f16}</th>" : "<th>#{f16}</th>"
      h2 += (f17 > 0) ? "<th class='hili'>#{f17}</th>" : "<th>#{f17}</th>"
      h2 += "</tr>\n"
    end

    h2 = "#{h2}<tr bgcolor='pink'><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th>"
    h2 += "<th align='right'>Total</th><th>&nbsp;</th><th>&nbsp;</th>"
    (8..19).each do |x|
      h2 += "<th><font color='red'>#{totalCol[x]}</font></th>"
    end
    h2 += "</tr>\n"
  else
    h1 = "&nbsp;"
    h2 = "<tr></tr>"
  end
  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def f26header(year,type,form)
  h1 = "ลำดับที่,ปี,จังหวัด,รหัส,หน่วยงาน,ประเภท,รหัส,"
  h1 += "S01-1M,S01-1F,S01-2M,S01-2F,"
  h1 += "S02-1M,S02-1F,S02-2M,S02-2F,"
  h1 += "S03-1M,S03-1F,S03-2M,S03-2F,"
  h1 += "S04-1M,S04-1F,S04-2M,S04-2F,"
  h1 += "S05-1M,S05-1F,S05-2M,S05-2F,"
  h1 += "S06-1M,S06-1F,S06-2M,S06-2F,"
  h1 += "S07-1M,S07-1F,S07-2M,S07-2F,"
  h1 += "S08-1M,S08-1F,S08-2M,S08-2F,"
  h1 += "S09-1M,S09-1F,S09-2M,S09-2F,"
  h1 += "S10-1M,S10-1F,S10-2M,S10-2F,"
  h1 += "S11-1M,S11-1F,S11-2M,S11-2F,"
  h1 += "S12-1M,S12-1F,S12-2M,S12-2F,"
  h1 += "S13-1M,S13-1F,S13-2M,S13-2F,"
  h1 += "S14-1M,S14-1F,S14-2M,S14-2F,"
  h1 += "S15-1M,S15-1F,S15-2M,S15-2F,"
  h1 += "S16-1M,S16-1F,S16-2M,S16-2F,"
  h1 += "S17-1M,S17-1F,S17-2M,S17-2F,"
  h1 += "S18-1M,S18-1F,S18-2M,S18-2F,"
  h1 += "S19-1M,S19-1F,S19-2M,S19-2F,"
  h1 += "S20-1M,S20-1F,S20-2M,S20-2F,"
  h1 += "S21-1M,S21-1F,S21-2M,S21-2F,"
  h1 += "S22-1M,S22-1F,S22-2M,S22-2F,"
  h1 += "S23-1M,S23-1F,S23-2M,S23-2F,"
  h1 += "S24-1M,S24-1F,S24-2M,S24-2F,"
  h1 += "S25-1M,S25-1F,S25-2M,S25-2F,"
  h1 += "S26-1M,S26-1F,S26-2M,S26-2F,"
  h1 += "S27-1M,S27-1F,S27-2M,S27-2F,"
  h1 += "S28-1M,S28-1F,S28-2M,S28-2F,"
  h1 += "S29-1M,S29-1F,S29-2M,S29-2F,"
  h1 += "S30-1M,S30-1F,S30-2M,S30-2F,"
  h1 += "S31-1M,S31-1F,S31-2M,S31-2F,"
  h1 += "S32-1M,S32-1F,S32-2M,S32-2F,"
  h1 += "S33-1M,S33-1F,S33-2M,S33-2F,"
  h1 += "S34-1M,S34-1F,S34-2M,S34-2F,"
  h1 += "S35-1M,S35-1F,S35-2M,S35-2F,"
  h1 += "S36-1M,S36-1F,S36-2M,S36-2F,"
  h1 += "S37-1M,S37-1F,S37-2M,S37-2F,"
  h1 += "S38-1M,S38-1F,S38-2M,S38-2F,"
  h1 += "S39-1M,S39-1F,S39-2M,S39-2F,"
  h1 += "S40-1M,S40-1F,S40-2M,S40-2F,"
  h1 += "S41-1M,S41-1F,S41-2M,S41-2F,"
  h1 += "S42-1M,S42-1F,S42-2M,S42-2F,"
  h1 += "S43-1M,S43-1F,S43-2M,S43-2F,"
  h1 += "S44-1M,S44-1F,S44-2M,S44-2F,"
  h1 += "S45-1M,S45-1F,S45-2M,S45-2F,"
  h1 += "S46-1M,S46-1F,S46-2M,S46-2F,"
  h1 += "S47-1M,S47-1F,S47-2M,S47-2F,"
  h1 += "S48-1M,S48-1F,S48-2M,S48-2F,"
  if (year.to_i < 47) # yr 46,45
    h1 += "S49-1M,S49-1F,S49-2M,S49-2F\n"
  else
    h1 += "S49-1M,S49-1F,S49-2M,S49-2F,"
    h1 += "S50-1M,S50-1F,S50-2M,S50-2F,"
    h1 += "S51-1M,S51-1F,S51-2M,S51-2F,"
    h1 += "S52-1M,S52-1F,S52-2M,S52-2F,"
    h1 += "S53-1M,S53-1F,S53-2M,S53-2F,"
    if (year.to_i < 50) # yr 49,48,47
      h1 += "S53-1M,S53-1F,S53-2M,S53-2F\n"
    else # yr 50+
      h1 += "S54-1M,S54-1F,S54-2M,S54-2F,"
      h1 += "S55-1M,S55-1F,S55-2M,S55-2F,"
      h1 += "S56-1M,S56-1F,S56-2M,S56-2F,"
      h1 += "S57-1M,S57-1F,S57-2M,S57-2F,"
      h1 += "S58-1M,S58-1F,S58-2M,S58-2F,"
      h1 += "S59-1M,S59-1F,S59-2M,S59-2F,"
      h1 += "S60-1M,S60-1F,S60-2M,S60-2F,"
      h1 += "S61-1M,S61-1F,S61-2M,S61-2F,"
      h1 += "S62-1M,S62-1F,S62-2M,S62-2F,"
      h1 += "S63-1M,S63-1F,S63-2M,S63-2F,"
      h1 += "S64-1M,S64-1F,S64-2M,S64-2F,"
      h1 += "S65-1M,S65-1F,S65-2M,S65-2F,"
      h1 += "S66-1M,S66-1F,S66-2M,S66-2F,"
      h1 += "S67-1M,S67-1F,S67-2M,S67-2F,"
      h1 += "S68-1M,S68-1F,S68-2M,S68-2F,"
      h1 += "S69-1M,S69-1F,S69-2M,S69-2F,"
      h1 += "S70-1M,S70-1F,S70-2M,S70-2F,"
      h1 += "S71-1M,S71-1F,S71-2M,S71-2F,"
      h1 += "S72-1M,S72-1F,S72-2M,S72-2F,"
      h1 += "S73-1M,S73-1F,S73-2M,S73-2F,"
      h1 += "S74-1M,S74-1F,S74-2M,S74-2F,"
      h1 += "S75-1M,S75-1F,S75-2M,S75-2F,"
      h1 += "S76-1M,S76-1F,S76-2M,S76-2F,"
      h1 += "S77-1M,S77-1F,S77-2M,S77-2F,"
      h1 += "S78-1M,S78-1F,S78-2M,S78-2F,"
      h1 += "S79-1M,S79-1F,S79-2M,S79-2F,"
      h1 += "รวม\n"
    end
  end

  h2 = "<table border='1' width='100%'>"
  h2 += "<tr><th>ลำดับที่</th><th>ปี</th><th>จังหวัด</th><th>รหัส</th><th>หน่วยงาน</th><th>ประเภท</th><th>รหัส</th>"

  s011m = "s011m#{form}"
  s011f  = "s011f#{form}"
  s012m = "s012m#{form}"
  s012f  = "s012f#{form}"

  s021m = "s021m#{form}"
  s021f  = "s021f#{form}"
  s022m = "s022m#{form}"
  s022f  = "s022f#{form}"

  s031m = "s031m#{form}"
  s031f  = "s031f#{form}"
  s032m = "s032m#{form}"
  s032f  = "s032f#{form}"

  s041m = "s041m#{form}"
  s041f  = "s041f#{form}"
  s042m = "s042m#{form}"
  s042f  = "s042f#{form}"

  s051m = "s051m#{form}"
  s051f  = "s051f#{form}"
  s052m = "s052m#{form}"
  s052f  = "s052f#{form}"

  s061m = "s061m#{form}"
  s061f  = "s061f#{form}"
  s062m = "s062m#{form}"
  s062f  = "s062f#{form}"

  s071m = "s071m#{form}"
  s071f  = "s071f#{form}"
  s072m = "s072m#{form}"
  s072f  = "s072f#{form}"

  s081m = "s081m#{form}"
  s081f  = "s081f#{form}"
  s082m = "s082m#{form}"
  s082f  = "s082f#{form}"

  s091m = "s091m#{form}"
  s091f  = "s091f#{form}"
  s092m = "s092m#{form}"
  s092f  = "s092f#{form}"

  s101m = "s101m#{form}"
  s101f  = "s101f#{form}"
  s102m = "s102m#{form}"
  s102f  = "s102f#{form}"

  s111m = "s111m#{form}"
  s111f  = "s111f#{form}"
  s112m = "s112m#{form}"
  s112f  = "s112f#{form}"

  s121m = "s121m#{form}"
  s121f  = "s121f#{form}"
  s122m = "s122m#{form}"
  s122f  = "s122f#{form}"

  s131m = "s131m#{form}"
  s131f  = "s131f#{form}"
  s132m = "s132m#{form}"
  s132f  = "s132f#{form}"

  s141m = "s141m#{form}"
  s141f  = "s141f#{form}"
  s142m = "s142m#{form}"
  s142f  = "s142f#{form}"

  s151m = "s151m#{form}"
  s151f  = "s151f#{form}"
  s152m = "s152m#{form}"
  s152f  = "s152f#{form}"

  s161m = "s161m#{form}"
  s161f  = "s161f#{form}"
  s162m = "s162m#{form}"
  s162f  = "s162f#{form}"

  s171m = "s171m#{form}"
  s171f  = "s171f#{form}"
  s172m = "s172m#{form}"
  s172f  = "s172f#{form}"

  s181m = "s181m#{form}"
  s181f  = "s181f#{form}"
  s182m = "s182m#{form}"
  s182f  = "s182f#{form}"

  s191m = "s191m#{form}"
  s191f  = "s191f#{form}"
  s192m = "s192m#{form}"
  s192f  = "s192f#{form}"

  s201m = "s201m#{form}"
  s201f  = "s201f#{form}"
  s202m = "s202m#{form}"
  s202f  = "s202f#{form}"

  s211m = "s211m#{form}"
  s211f  = "s211f#{form}"
  s212m = "s212m#{form}"
  s212f  = "s212f#{form}"

  s221m = "s221m#{form}"
  s221f  = "s221f#{form}"
  s222m = "s222m#{form}"
  s222f  = "s222f#{form}"

  s231m = "s231m#{form}"
  s231f  = "s231f#{form}"
  s232m = "s232m#{form}"
  s232f  = "s232f#{form}"

  s241m = "s241m#{form}"
  s241f  = "s241f#{form}"
  s242m = "s242m#{form}"
  s242f  = "s242f#{form}"

  s251m = "s251m#{form}"
  s251f  = "s251f#{form}"
  s252m = "s252m#{form}"
  s252f  = "s252f#{form}"

  s261m = "s261m#{form}"
  s261f  = "s261f#{form}"
  s262m = "s262m#{form}"
  s262f  = "s262f#{form}"

  s271m = "s271m#{form}"
  s271f  = "s271f#{form}"
  s272m = "s272m#{form}"
  s272f  = "s272f#{form}"

  s281m = "s281m#{form}"
  s281f  = "s281f#{form}"
  s282m = "s282m#{form}"
  s282f  = "s282f#{form}"

  s291m = "s291m#{form}"
  s291f  = "s291f#{form}"
  s292m = "s292m#{form}"
  s292f  = "s292f#{form}"

  s301m = "s301m#{form}"
  s301f  = "s301f#{form}"
  s302m = "s302m#{form}"
  s302f  = "s302f#{form}"

  s311m = "s311m#{form}"
  s311f  = "s311f#{form}"
  s312m = "s312m#{form}"
  s312f  = "s312f#{form}"

  s321m = "s321m#{form}"
  s321f  = "s321f#{form}"
  s322m = "s322m#{form}"
  s322f  = "s322f#{form}"

  s331m = "s331m#{form}"
  s331f  = "s331f#{form}"
  s332m = "s332m#{form}"
  s332f  = "s332f#{form}"

  s341m = "s341m#{form}"
  s341f  = "s341f#{form}"
  s342m = "s342m#{form}"
  s342f  = "s342f#{form}"

  s351m = "s351m#{form}"
  s351f  = "s351f#{form}"
  s352m = "s352m#{form}"
  s352f  = "s352f#{form}"

  s361m = "s361m#{form}"
  s361f  = "s361f#{form}"
  s362m = "s362m#{form}"
  s362f  = "s362f#{form}"

  s371m = "s371m#{form}"
  s371f  = "s371f#{form}"
  s372m = "s372m#{form}"
  s372f  = "s372f#{form}"

  s381m = "s381m#{form}"
  s381f  = "s381f#{form}"
  s382m = "s382m#{form}"
  s382f  = "s382f#{form}"

  s391m = "s391m#{form}"
  s391f  = "s391f#{form}"
  s392m = "s392m#{form}"
  s392f  = "s392f#{form}"

  s401m = "s401m#{form}"
  s401f  = "s401f#{form}"
  s402m = "s402m#{form}"
  s402f  = "s402f#{form}"

  s411m = "s411m#{form}"
  s411f  = "s411f#{form}"
  s412m = "s412m#{form}"
  s412f  = "s412f#{form}"

  s421m = "s421m#{form}"
  s421f  = "s421f#{form}"
  s422m = "s422m#{form}"
  s422f  = "s422f#{form}"

  s431m = "s431m#{form}"
  s431f  = "s431f#{form}"
  s432m = "s432m#{form}"
  s432f  = "s432f#{form}"

  s441m = "s441m#{form}"
  s441f  = "s441f#{form}"
  s442m = "s442m#{form}"
  s442f  = "s442f#{form}"

  s451m = "s451m#{form}"
  s451f  = "s451f#{form}"
  s452m = "s452m#{form}"
  s452f  = "s452f#{form}"

  s461m = "s461m#{form}"
  s461f  = "s461f#{form}"
  s462m = "s462m#{form}"
  s462f  = "s462f#{form}"

  s471m = "s471m#{form}"
  s471f  = "s471f#{form}"
  s472m = "s472m#{form}"
  s472f  = "s472f#{form}"

  s481m = "s481m#{form}"
  s481f  = "s481f#{form}"
  s482m = "s482m#{form}"
  s482f  = "s482f#{form}"

  s491m = "s491m#{form}"
  s491f  = "s491f#{form}"
  s492m = "s492m#{form}"
  s492f  = "s492f#{form}"

  s501m = "s501m#{form}"
  s501f  = "s501f#{form}"
  s502m = "s502m#{form}"
  s502f  = "s502f#{form}"

  s511m = "s511m#{form}"
  s511f  = "s511f#{form}"
  s512m = "s512m#{form}"
  s512f  = "s512f#{form}"

  s521m = "s521m#{form}"
  s521f  = "s521f#{form}"
  s522m = "s522m#{form}"
  s522f  = "s522f#{form}"

  s531m = "s531m#{form}"
  s531f  = "s531f#{form}"
  s532m = "s532m#{form}"
  s532f  = "s532f#{form}"

  s541m = "s541m#{form}"
  s541f  = "s541f#{form}"
  s542m = "s542m#{form}"
  s542f  = "s542f#{form}"

  s551m = "s551m#{form}"
  s551f  = "s551f#{form}"
  s552m = "s552m#{form}"
  s552f  = "s552f#{form}"

  s561m = "s561m#{form}"
  s561f  = "s561f#{form}"
  s562m = "s562m#{form}"
  s562f  = "s562f#{form}"

  s571m = "s571m#{form}"
  s571f  = "s571f#{form}"
  s572m = "s572m#{form}"
  s572f  = "s572f#{form}"

  s581m = "s581m#{form}"
  s581f  = "s581f#{form}"
  s582m = "s582m#{form}"
  s582f  = "s582f#{form}"

  s591m = "s591m#{form}"
  s591f  = "s591f#{form}"
  s592m = "s592m#{form}"
  s592f  = "s592f#{form}"

  s601m = "s601m#{form}"
  s601f  = "s601f#{form}"
  s602m = "s602m#{form}"
  s602f  = "s602f#{form}"

  s611m = "s611m#{form}"
  s611f  = "s611f#{form}"
  s612m = "s612m#{form}"
  s612f  = "s612f#{form}"

  s621m = "s621m#{form}"
  s621f  = "s621f#{form}"
  s622m = "s622m#{form}"
  s622f  = "s622f#{form}"

  s631m = "s631m#{form}"
  s631f  = "s631f#{form}"
  s632m = "s632m#{form}"
  s632f  = "s632f#{form}"

  s641m = "s641m#{form}"
  s641f  = "s641f#{form}"
  s642m = "s642m#{form}"
  s642f  = "s642f#{form}"

  s651m = "s651m#{form}"
  s651f  = "s651f#{form}"
  s652m = "s652m#{form}"
  s652f  = "s652f#{form}"

  s661m = "s661m#{form}"
  s661f  = "s661f#{form}"
  s662m = "s662m#{form}"
  s662f  = "s662f#{form}"

  s671m = "s671m#{form}"
  s671f  = "s671f#{form}"
  s672m = "s672m#{form}"
  s672f  = "s672f#{form}"

  s681m = "s681m#{form}"
  s681f  = "s681f#{form}"
  s682m = "s682m#{form}"
  s682f  = "s682f#{form}"

  s691m = "s691m#{form}"
  s691f  = "s691f#{form}"
  s692m = "s692m#{form}"
  s692f  = "s692f#{form}"

  s701m = "s701m#{form}"
  s701f  = "s701f#{form}"
  s702m = "s702m#{form}"
  s702f  = "s702f#{form}"

  s711m = "s711m#{form}"
  s711f  = "s711f#{form}"
  s712m = "s712m#{form}"
  s712f  = "s712f#{form}"

  s721m = "s721m#{form}"
  s721f  = "s721f#{form}"
  s722m = "s722m#{form}"
  s722f  = "s722f#{form}"

  s731m = "s731m#{form}"
  s731f  = "s731f#{form}"
  s732m = "s732m#{form}"
  s732f  = "s732f#{form}"

  s741m = "s741m#{form}"
  s741f  = "s741f#{form}"
  s742m = "s742m#{form}"
  s742f  = "s742f#{form}"

  s751m = "s751m#{form}"
  s751f  = "s751f#{form}"
  s752m = "s752m#{form}"
  s752f  = "s752f#{form}"

  s761m = "s761m#{form}"
  s761f  = "s761f#{form}"
  s762m = "s762m#{form}"
  s762f  = "s762f#{form}"

  s771m = "s771m#{form}"
  s771f  = "s771f#{form}"
  s772m = "s772m#{form}"
  s772f  = "s772f#{form}"

  s781m = "s781m#{form}"
  s781f  = "s781f#{form}"
  s782m = "s782m#{form}"
  s782f  = "s782f#{form}"

  s791m = "s791m#{form}"
  s791f  = "s791f#{form}"
  s792m = "s792m#{form}"
  s792f  = "s792f#{form}"

  if (year.to_i == 51)

  h2 += "<th><a href='#' onmouseover=\"Tip(#{s011m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S01-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s011f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S01-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s012m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S01-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s012f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S01-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s021m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S02-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s021f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S02-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s022m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S02-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s022f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S02-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s031m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S03-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s031f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S03-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s032m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S03-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s032f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S03-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s041m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S04-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s041f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S04-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s042m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S04-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s042f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S04-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s051m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S05-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s051f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S05-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s052m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S05-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s052f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S05-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s061m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S06-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s061f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S06-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s062m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S06-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s062f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S06-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s071m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S07-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s071f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S07-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s072m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S07-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s072f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S07-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s081m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S08-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s081f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S08-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s082m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S08-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s082f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S08-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s091m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S09-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s091f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S09-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s092m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S09-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s092f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S09-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s101m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S10-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s101f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S10-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s102m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S10-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s102f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S10-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s111m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S11-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s111f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S11-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s112m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S11-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s112f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S11-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s121m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S12-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s121f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S12-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s122m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S12-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s122f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S12-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s131m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S13-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s131f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S13-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s132m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S13-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s132f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S13-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s141m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S14-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s141f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S14-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s142m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S14-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s142f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S14-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s151m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S15-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s151f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S15-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s152m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S15-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s152f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S15-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s161m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S16-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s161f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S16-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s162m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S16-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s162f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S16-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s171m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S17-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s171f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S17-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s172m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S17-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s172f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S17-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s181m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S18-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s181f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S18-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s182m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S18-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s182f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S18-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s191m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S19-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s191f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S19-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s192m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S19-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s192f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S19-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s201m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S20-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s201f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S20-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s202m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S20-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s202f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S20-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s211m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S21-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s211f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S21-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s212m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S21-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s212f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S21-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s221m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S22-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s221f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S22-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s222m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S22-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s222f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S22-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s231m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S23-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s231f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S23-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s232m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S23-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s232f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S23-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s241m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S24-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s241f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S24-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s242m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S24-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s242f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S24-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s251m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S25-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s251f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S25-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s252m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S25-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s252f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S25-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s261m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S26-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s261f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S26-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s262m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S26-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s262f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S26-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s271m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S27-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s271f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S27-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s272m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S27-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s272f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S27-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s281m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S28-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s281f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S28-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s282m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S28-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s282f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S28-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s291m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S29-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s291f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S29-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s292m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S29-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s292f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S29-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s301m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S30-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s301f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S30-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s302m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S30-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s302f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S30-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s311m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S31-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s311f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S31-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s312m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S31-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s312f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S31-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s321m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S32-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s321f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S32-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s322m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S32-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s322f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S32-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s331m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S33-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s331f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S33-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s332m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S33-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s332f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S33-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s341m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S34-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s341f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S34-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s342m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S34-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s342f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S34-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s351m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S35-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s351f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S35-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s352m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S35-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s352f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S35-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s361m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S36-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s361f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S36-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s362m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S36-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s362f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S36-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s371m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S37-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s371f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S37-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s372m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S37-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s372f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S37-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s381m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S38-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s381f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S38-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s382m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S38-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s382f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S38-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s391m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S39-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s391f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S39-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s392m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S39-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s392f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S39-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s401m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S40-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s401f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S40-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s402m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S40-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s402f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S40-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s411m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S41-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s411f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S41-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s412m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S41-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s412f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S41-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s421m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S42-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s421f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S42-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s422m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S42-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s422f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S42-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s431m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S43-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s431f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S43-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s432m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S43-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s432f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S43-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s441m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S44-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s441f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S44-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s442m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S44-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s442f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S44-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s451m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S45-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s451f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S45-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s452m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S45-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s452f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S45-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s461m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S46-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s461f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S46-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s462m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S46-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s462f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S46-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s471m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S47-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s471f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S47-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s472m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S47-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s472f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S47-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s481m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S48-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s481f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S48-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s482m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S48-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s482f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S48-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s491m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S49-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s491f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S49-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s492m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S49-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s492f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S49-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s501m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S50-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s501f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S50-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s502m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S50-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s502f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S50-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s511m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S51-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s511f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S51-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s512m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S51-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s512f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S51-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s521m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S52-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s521f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S52-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s522m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S52-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s522f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S52-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s531m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S53-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s531f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S53-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s532m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S53-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s532f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S53-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s541m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S54-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s541f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S54-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s542m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S54-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s542f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S54-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s551m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S55-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s551f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S55-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s552m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S55-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s552f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S55-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s561m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S56-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s561f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S56-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s562m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S56-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s562f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S56-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s571m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S57-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s571f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S57-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s572m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S57-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s572f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S57-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s581m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S58-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s581f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S58-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s582m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S58-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s582f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S58-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s591m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S59-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s591f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S59-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s592m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S59-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s592f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S59-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s601m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S60-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s601f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S60-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s602m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S60-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s602f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S60-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s611m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S61-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s611f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S61-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s612m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S61-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s612f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S61-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s621m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S62-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s621f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S62-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s622m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S62-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s622f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S62-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s631m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S63-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s631f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S63-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s632m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S63-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s632f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S63-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s641m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S64-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s641f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S64-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s642m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S64-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s642f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S64-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s651m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S65-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s651f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S65-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s652m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S65-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s652f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S65-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s661m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S66-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s661f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S66-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s662m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S66-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s662f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S66-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s671m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S67-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s671f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S67-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s672m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S67-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s672f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S67-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s681m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S68-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s681f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S68-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s682m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S68-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s682f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S68-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s691m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S69-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s691f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S69-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s692m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S69-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s692f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S69-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s701m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S70-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s701f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S70-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s702m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S70-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s702f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S70-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s711m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S71-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s711f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S71-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s712m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S71-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s712f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S71-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s721m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S72-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s721f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S72-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s722m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S72-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s722f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S72-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s731m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S73-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s731f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S73-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s732m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S73-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s732f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S73-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s741m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S74-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s741f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S74-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s742m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S74-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s742f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S74-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s751m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S75-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s751f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S75-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s752m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S75-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s752f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S75-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s761m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S76-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s761f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S76-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s762m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S76-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s762f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S76-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s771m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S77-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s771f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S77-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s772m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S77-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s772f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S77-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s781m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S78-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s781f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S78-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s782m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S78-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s782f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S78-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s791m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S79-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s791f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S79-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s792m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S79-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s792f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S79-2F</a></th>"
  h2 += "<th>รวม</th>"

  else

  h2 += "<th>S01-1M</th><th>S01-1F</th><th>S01-2M</th><th>S01-2F</th>"
  h2 += "<th>S02-1M</th><th>S02-1F</th><th>S02-2M</th><th>S02-2F</th>"
  h2 += "<th>S03-1M</th><th>S03-1F</th><th>S03-2M</th><th>S03-2F</th>"
  h2 += "<th>S04-1M</th><th>S04-1F</th><th>S04-2M</th><th>S04-2F</th>"
  h2 += "<th>S05-1M</th><th>S05-1F</th><th>S05-2M</th><th>S05-2F</th>"
  h2 += "<th>S06-1M</th><th>S06-1F</th><th>S06-2M</th><th>S06-2F</th>"
  h2 += "<th>S07-1M</th><th>S07-1F</th><th>S07-2M</th><th>S07-2F</th>"
  h2 += "<th>S08-1M</th><th>S08-1F</th><th>S08-2M</th><th>S08-2F</th>"
  h2 += "<th>S09-1M</th><th>S09-1F</th><th>S09-2M</th><th>S09-2F</th>"
  h2 += "<th>S10-1M</th><th>S10-1F</th><th>S10-2M</th><th>S10-2F</th>"
  h2 += "<th>S11-1M</th><th>S11-1F</th><th>S11-2M</th><th>S11-2F</th>"
  h2 += "<th>S12-1M</th><th>S12-1F</th><th>S12-2M</th><th>S12-2F</th>"
  h2 += "<th>S13-1M</th><th>S13-1F</th><th>S13-2M</th><th>S13-2F</th>"
  h2 += "<th>S14-1M</th><th>S14-1F</th><th>S14-2M</th><th>S14-2F</th>"
  h2 += "<th>S15-1M</th><th>S15-1F</th><th>S15-2M</th><th>S15-2F</th>"
  h2 += "<th>S16-1M</th><th>S16-1F</th><th>S16-2M</th><th>S16-2F</th>"
  h2 += "<th>S17-1M</th><th>S17-1F</th><th>S17-2M</th><th>S17-2F</th>"
  h2 += "<th>S18-1M</th><th>S18-1F</th><th>S18-2M</th><th>S18-2F</th>"
  h2 += "<th>S19-1M</th><th>S19-1F</th><th>S19-2M</th><th>S19-2F</th>"
  h2 += "<th>S20-1M</th><th>S20-1F</th><th>S20-2M</th><th>S20-2F</th>"
  h2 += "<th>S21-1M</th><th>S21-1F</th><th>S21-2M</th><th>S21-2F</th>"
  h2 += "<th>S22-1M</th><th>S22-1F</th><th>S22-2M</th><th>S22-2F</th>"
  h2 += "<th>S23-1M</th><th>S23-1F</th><th>S23-2M</th><th>S23-2F</th>"
  h2 += "<th>S24-1M</th><th>S24-1F</th><th>S24-2M</th><th>S24-2F</th>"
  h2 += "<th>S25-1M</th><th>S25-1F</th><th>S25-2M</th><th>S25-2F</th>"
  h2 += "<th>S26-1M</th><th>S26-1F</th><th>S26-2M</th><th>S26-2F</th>"
  h2 += "<th>S27-1M</th><th>S27-1F</th><th>S27-2M</th><th>S27-2F</th>"
  h2 += "<th>S28-1M</th><th>S28-1F</th><th>S28-2M</th><th>S28-2F</th>"
  h2 += "<th>S29-1M</th><th>S29-1F</th><th>S29-2M</th><th>S29-2F</th>"
  h2 += "<th>S30-1M</th><th>S30-1F</th><th>S30-2M</th><th>S30-2F</th>"
  h2 += "<th>S31-1M</th><th>S31-1F</th><th>S31-2M</th><th>S31-2F</th>"
  h2 += "<th>S32-1M</th><th>S32-1F</th><th>S32-2M</th><th>S32-2F</th>"
  h2 += "<th>S33-1M</th><th>S33-1F</th><th>S33-2M</th><th>S33-2F</th>"
  h2 += "<th>S34-1M</th><th>S34-1F</th><th>S34-2M</th><th>S34-2F</th>"
  h2 += "<th>S35-1M</th><th>S35-1F</th><th>S35-2M</th><th>S35-2F</th>"
  h2 += "<th>S36-1M</th><th>S36-1F</th><th>S36-2M</th><th>S36-2F</th>"
  h2 += "<th>S37-1M</th><th>S37-1F</th><th>S37-2M</th><th>S37-2F</th>"
  h2 += "<th>S38-1M</th><th>S38-1F</th><th>S38-2M</th><th>S38-2F</th>"
  h2 += "<th>S39-1M</th><th>S39-1F</th><th>S39-2M</th><th>S39-2F</th>"
  h2 += "<th>S40-1M</th><th>S40-1F</th><th>S40-2M</th><th>S40-2F</th>"
  h2 += "<th>S41-1M</th><th>S41-1F</th><th>S41-2M</th><th>S41-2F</th>"
  h2 += "<th>S42-1M</th><th>S42-1F</th><th>S42-2M</th><th>S42-2F</th>"
  h2 += "<th>S43-1M</th><th>S43-1F</th><th>S43-2M</th><th>S43-2F</th>"
  h2 += "<th>S44-1M</th><th>S44-1F</th><th>S44-2M</th><th>S44-2F</th>"
  h2 += "<th>S45-1M</th><th>S45-1F</th><th>S45-2M</th><th>S45-2F</th>"
  h2 += "<th>S46-1M</th><th>S46-1F</th><th>S46-2M</th><th>S46-2F</th>"
  h2 += "<th>S47-1M</th><th>S47-1F</th><th>S47-2M</th><th>S47-2F</th>"
  h2 += "<th>S48-1M</th><th>S48-1F</th><th>S48-2M</th><th>S48-2F</th>"
  h2 += "<th>S49-1M</th><th>S49-1F</th><th>S49-2M</th><th>S49-2F</th>"
  if (year.to_i > 46) # yr 47+
    h2 += "<th>S50-1M</th><th>S50-1F</th><th>S50-2M</th><th>S50-2F</th>"
    h2 += "<th>S51-1M</th><th>S51-1F</th><th>S51-2M</th><th>S51-2F</th>"
    h2 += "<th>S52-1M</th><th>S52-1F</th><th>S52-2M</th><th>S52-2F</th>"
    h2 += "<th>S53-1M</th><th>S53-1F</th><th>S53-2M</th><th>S53-2F</th>"
    if (year.to_i > 49) # yr 50+
      h2 += "<th>S54-1M</th><th>S54-1F</th><th>S54-2M</th><th>S54-2F</th>"
      h2 += "<th>S55-1M</th><th>S55-1F</th><th>S55-2M</th><th>S55-2F</th>"
      h2 += "<th>S56-1M</th><th>S56-1F</th><th>S56-2M</th><th>S56-2F</th>"
      h2 += "<th>S57-1M</th><th>S57-1F</th><th>S57-2M</th><th>S57-2F</th>"
      h2 += "<th>S58-1M</th><th>S58-1F</th><th>S58-2M</th><th>S58-2F</th>"
      h2 += "<th>S59-1M</th><th>S59-1F</th><th>S59-2M</th><th>S59-2F</th>"
      h2 += "<th>S60-1M</th><th>S60-1F</th><th>S60-2M</th><th>S60-2F</th>"
      h2 += "<th>S61-1M</th><th>S61-1F</th><th>S61-2M</th><th>S61-2F</th>"
      h2 += "<th>S62-1M</th><th>S62-1F</th><th>S62-2M</th><th>S62-2F</th>"
      h2 += "<th>S63-1M</th><th>S63-1F</th><th>S63-2M</th><th>S63-2F</th>"
      h2 += "<th>S64-1M</th><th>S64-1F</th><th>S64-2M</th><th>S64-2F</th>"
      h2 += "<th>S65-1M</th><th>S65-1F</th><th>S65-2M</th><th>S65-2F</th>"
      h2 += "<th>S66-1M</th><th>S66-1F</th><th>S66-2M</th><th>S66-2F</th>"
      h2 += "<th>S67-1M</th><th>S67-1F</th><th>S67-2M</th><th>S67-2F</th>"
      h2 += "<th>S68-1M</th><th>S68-1F</th><th>S68-2M</th><th>S68-2F</th>"
      h2 += "<th>S69-1M</th><th>S69-1F</th><th>S69-2M</th><th>S69-2F</th>"
      h2 += "<th>S70-1M</th><th>S70-1F</th><th>S70-2M</th><th>S70-2F</th>"
      h2 += "<th>S71-1M</th><th>S71-1F</th><th>S71-2M</th><th>S71-2F</th>"
      h2 += "<th>S72-1M</th><th>S72-1F</th><th>S72-2M</th><th>S72-2F</th>"
      h2 += "<th>S73-1M</th><th>S73-1F</th><th>S73-2M</th><th>S73-2F</th>"
      h2 += "<th>S74-1M</th><th>S74-1F</th><th>S74-2M</th><th>S74-2F</th>"
      h2 += "<th>S75-1M</th><th>S75-1F</th><th>S75-2M</th><th>S75-2F</th>"
      h2 += "<th>S76-1M</th><th>S76-1F</th><th>S76-2M</th><th>S76-2F</th>"
      h2 += "<th>S77-1M</th><th>S77-1F</th><th>S77-2M</th><th>S77-2F</th>"
      h2 += "<th>S78-1M</th><th>S78-1F</th><th>S78-2M</th><th>S78-2F</th>"
      h2 += "<th>S79-1M</th><th>S79-1F</th><th>S79-2M</th><th>S79-2F</th>"
      h2 += "<th>รวม</th>"
      h2 += "</tr>\n"
    end
  end
  end
  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def f37footer()
  h = "</table>\n"
  h += "<p><pre>หมายเหตุ<p>\n"
  h += "M = หน่วยงานกระทรวงสาธารณสุข\n"
  h += "G = หน่วยงานภาครัฐนอกกระทรวงสาธารณสุข\n"
  h += "P = หน่วยงานเอกชน\n\n"
  h
end

def f26footer(year)
  h = "</table>\n"
  h += "<p><pre>หมายเหตุ<p>\n"
  h += "M = หน่วยงานกระทรวงสาธารณสุข\n"
  h += "G = หน่วยงานภาครัฐนอกกระทรวงสาธารณสุข\n"
  h += "P = หน่วยงานเอกชน\n\n"
  h += "Sxx-1M = ขรก./พนักงานของรัฐ ชาย\n"
  h += "Sxx-1F = ขรก./พนักงานของรัฐ หญิง\n"
  h += "Sxx-2M = ลูกจ้าง ชาย\n"
  h += "Sxx-2F = ลูกจ้าง หญิง\n\n"
  h += "<a href='ftp//203.157.240.9/pub/resource53/spec-52.txt'>"
  h += "<input type='button' value='Download รหัสสาขาเฉพาะทางสำหรับปี 25#{year}' "
  h += "onclick=\"document.location.href='ftp://203.157.240.9/pub/resource53/spec-#{year}.txt'\" /></a>\n"
  h += "</pre>"
  h
end

def getForm2(year,pcode,acode,type)
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year}")
  sql = "SELECT * FROM form2 "
  if (acode.length == 4) # request from Amphoe
    if (acode =~ /01$/)
      sql += "WHERE (f2pcode='#{acode}' OR f2pcode='#{pcode}') "
    else
      sql += "WHERE f2pcode='#{acode}' "
    end
  else
    sql += "WHERE f2pcode='#{pcode}' "
  end
  sql += "ORDER BY f2hcode"
  res = con.exec(sql)
  con.close

  h1 = h2  = nil
  n = 0
  ord = otype = nil

  totalCol = Array.new

  res.each do |rec|
    n += 1
    ord = sprintf("%03d", n)
    f1 = rec[0]
    f2 = rec[1]
    f3 = rec[2]
    f4 = rec[3]
    f5 = rec[4]
    otype = getOtype(f5.to_s)
    if (acode.to_s.length == 4)
      acodex = getAmpCode(f5)
      next if (acodex != acode)
    end
    f6 = rec[5].to_s.to_i
    f7 = rec[6].to_s.to_i
    f8 = rec[7].to_s.to_i
    f9 = rec[8].to_s.to_i
    f10 = rec[9].to_s.to_i
    f11 = rec[10].to_s.to_i
    f12 = rec[11].to_s.to_i
    f13 = rec[12].to_s.to_i
    f14 = rec[13].to_s.to_i
    f15 = rec[14].to_s.to_i
    f16 = rec[15].to_s.to_i
    f17 = rec[16].to_s.to_i
    f18 = rec[17].to_s.to_i
    f19 = rec[18].to_s.to_i
    f20 = rec[19].to_s.to_i
    f21 = rec[20].to_s.to_i
    f22 = rec[21].to_s.to_i
    f23 = rec[22].to_s.to_i
    f24 = rec[23].to_s.to_i
    f25 = rec[24].to_s.to_i
    f26 = rec[25].to_s.to_i
    f27 = rec[26].to_s.to_i
    f28 = rec[27].to_s.to_i
    f29 = rec[28].to_s.to_i
    f30 = rec[29].to_s.to_i
    f31 = rec[30].to_s.to_i
    f32 = rec[31].to_s.to_i
    f33 = rec[32].to_s.to_i
    f34 = rec[33].to_s.to_i
    f35 = rec[34].to_s.to_i
    f36 = rec[35].to_s.to_i
    f37 = rec[36].to_s.to_i
    f38 = rec[37].to_s.to_i
    f39 = rec[38].to_s.to_i
    f40 = rec[39].to_s.to_i
    f41 = rec[40].to_s.to_i
    f42 = rec[41].to_s.to_i
    f43 = rec[42].to_s.to_i
    f44 = rec[43].to_s.to_i
    f45 = rec[44].to_s.to_i
    f46 = rec[45].to_s.to_i
    f47 = rec[46].to_s.to_i
    f48 = rec[47].to_s.to_i
    f49 = rec[48].to_s.to_i
    f50 = rec[49].to_s.to_i
    f51 = rec[50].to_s.to_i
    f52 = rec[51].to_s.to_i
    f53 = rec[52].to_s.to_i
    f54 = rec[53].to_s.to_i
    f55 = rec[54].to_s.to_i
    f56 = rec[55].to_s.to_i
    f57 = rec[56].to_s.to_i
    f58 = rec[57].to_s.to_i
    f59 = rec[58].to_s.to_i
    f60 = rec[59].to_s.to_i
    f61 = rec[60].to_s.to_i
    f62 = rec[61].to_s.to_i
    f63 = rec[62].to_s.to_i
    f64 = rec[63].to_s.to_i
    f65 = rec[64].to_s.to_i
    f66 = rec[65].to_s.to_i
    f67 = rec[66].to_s.to_i
    f68 = rec[67].to_s.to_i
    f69 = rec[68].to_s.to_i
    f70 = rec[69].to_s.to_i
    f71 = rec[70].to_s.to_i
    f72 = rec[71].to_s.to_i
    f73 = rec[72].to_s.to_i
    f74 = rec[73].to_s.to_i
    f75 = rec[74].to_s.to_i
    f76 = rec[75].to_s.to_i
    f77 = rec[76].to_s.to_i
    f78 = rec[77].to_s.to_i
    f79 = rec[78].to_s.to_i
    f80 = rec[79].to_s.to_i
    f81 = rec[80].to_s.to_i
    f82 = rec[81].to_s.to_i
    f83 = rec[82].to_s.to_i
    f84 = rec[83].to_s.to_i
    f85 = rec[84].to_s.to_i
    f86 = rec[85].to_s.to_i
    f87 = rec[86].to_s.to_i
    f88 = rec[87].to_s.to_i
    f89 = rec[88].to_s.to_i
    f90 = rec[89].to_s.to_i
    f91 = rec[90].to_s.to_i
    f92 = rec[91].to_s.to_i
    f93 = rec[92].to_s.to_i
    f94 = rec[93].to_s.to_i
    f95 = rec[94].to_s.to_i
    f96 = rec[95].to_s.to_i
    f97 = rec[96].to_s.to_i
    f98 = rec[97].to_s.to_i
    f99 = rec[98].to_s.to_i
    f100 = rec[99].to_s.to_i
    f101 = rec[100].to_s.to_i
    f102 = rec[101].to_s.to_i
    f103 = rec[102].to_s.to_i
    f104 = rec[103].to_s.to_i
    f105 = rec[104].to_s.to_i
    f106 = rec[105].to_s.to_i
    f107 = rec[106].to_s.to_i
    f108 = rec[107].to_s.to_i
    f109 = rec[108].to_s.to_i
    f110 = rec[109].to_s.to_i
    f111 = rec[110].to_s.to_i
    f112 = rec[111].to_s.to_i
    f113 = rec[112].to_s.to_i
    f114 = rec[113].to_s.to_i
    f115 = rec[114].to_s.to_i
    f116 = rec[115].to_s.to_i
    f117 = rec[116].to_s.to_i
    f118 = rec[117].to_s.to_i
    f119 = rec[118].to_s.to_i
    f120 = rec[119].to_s.to_i
    f121 = rec[120].to_s.to_i
    f122 = rec[121].to_s.to_i
    f123 = rec[122].to_s.to_i
    f124 = rec[123].to_s.to_i
    f125 = rec[124].to_s.to_i
    f126 = rec[125].to_s.to_i
    f127 = rec[126].to_s.to_i
    f128 = rec[127].to_s.to_i
    f129 = rec[128].to_s.to_i
    f130 = rec[129].to_s.to_i
    f131 = rec[130].to_s.to_i
    f132 = rec[131].to_s.to_i
    f133 = rec[132].to_s.to_i
    f134 = rec[133].to_s.to_i
    f135 = rec[134].to_s.to_i
    f136 = rec[135].to_s.to_i
    f137 = rec[136].to_s.to_i
    f138 = rec[137].to_s.to_i
    f139 = rec[138].to_s.to_i
    f140 = rec[139].to_s.to_i
    f141 = rec[140].to_s.to_i
    f142 = rec[141].to_s.to_i
    f143 = rec[142].to_s.to_i
    f144 = rec[143].to_s.to_i
    f145 = rec[144].to_s.to_i
    f146 = rec[145].to_s.to_i
    f147 = rec[146].to_s.to_i
    f148 = rec[147].to_s.to_i
    f149 = rec[148].to_s.to_i
    f150 = rec[149].to_s.to_i
    f151 = rec[150].to_s.to_i
    f152 = rec[151].to_s.to_i
    f153 = rec[152].to_s.to_i
    f154 = rec[153].to_s.to_i
    f155 = rec[154].to_s.to_i
    f156 = rec[155].to_s.to_i
    f157 = rec[156].to_s.to_i
    f158 = rec[157].to_s.to_i
    f159 = rec[158].to_s.to_i
    f160 = rec[159].to_s.to_i
    f161 = rec[160].to_s.to_i
    f162 = rec[161].to_s.to_i
    f163 = rec[162].to_s.to_i
    f164 = rec[163].to_s.to_i
    f165 = rec[164].to_s.to_i
    f166 = rec[165].to_s.to_i
    f167 = rec[166].to_s.to_i
    f168 = rec[167].to_s.to_i
    f169 = rec[168].to_s.to_i
    f170 = rec[169].to_s.to_i
    f171 = rec[170].to_s.to_i
    f172 = rec[171].to_s.to_i
    f173 = rec[172].to_s.to_i
    f174 = rec[173].to_s.to_i
    f175 = rec[174].to_s.to_i
    f176 = rec[175].to_s.to_i
    f177 = rec[176].to_s.to_i
    f178 = rec[177].to_s.to_i
    f179 = rec[178].to_s.to_i
    f180 = rec[179].to_s.to_i
    f181 = rec[180].to_s.to_i
    f182 = rec[181].to_s.to_i
    f183 = rec[182].to_s.to_i
    f184 = rec[183].to_s.to_i
    f185 = rec[184].to_s.to_i
    f186 = rec[185].to_s.to_i
    f187 = rec[186].to_s.to_i
    f188 = rec[187].to_s.to_i
    f189 = rec[188].to_s.to_i
    f190 = rec[189].to_s.to_i
    f191 = rec[190].to_s.to_i
    f192 = rec[191].to_s.to_i
    f193 = rec[192].to_s.to_i
    f194 = rec[193].to_s.to_i
    f195 = rec[194].to_s.to_i
    f196 = rec[195].to_s.to_i
    f197 = rec[196].to_s.to_i
    f198 = rec[197].to_s.to_i
    f199 = rec[198].to_s.to_i
    f200 = rec[199].to_s.to_i
    f201 = rec[200].to_s.to_i
    f202 = rec[201].to_s.to_i
    f203 = rec[202].to_s.to_i
    f204 = rec[203].to_s.to_i
    f205 = rec[204].to_s.to_i
    f206 = rec[205].to_s.to_i
    f207 = rec[206].to_s.to_i
    f208 = rec[207].to_s.to_i
    f209 = rec[208].to_s.to_i
    f210 = rec[209].to_s.to_i
    f211 = rec[210].to_s.to_i
    f212 = rec[211].to_s.to_i
    f213 = rec[212].to_s.to_i
    f214 = rec[213].to_s.to_i
    f215 = rec[214].to_s.to_i
    f216 = rec[215].to_s.to_i
    f217 = rec[216].to_s.to_i
    f218 = rec[217].to_s.to_i
    f219 = rec[218].to_s.to_i
    f220 = rec[219].to_s.to_i
    f221 = rec[220].to_s.to_i
    f222 = rec[221].to_s.to_i
    f223 = rec[222].to_s.to_i
    f224 = rec[223].to_s.to_i
    f225 = rec[224].to_s.to_i
    f226 = rec[225].to_s.to_i
    f227 = rec[226].to_s.to_i
    f228 = rec[227].to_s.to_i
    f229 = rec[228].to_s.to_i
    f230 = rec[229].to_s.to_i
    f231 = rec[230].to_s.to_i
    f232 = rec[231].to_s.to_i
    f233 = rec[232].to_s.to_i
    f234 = rec[233].to_s.to_i
    f235 = rec[234].to_s.to_i
    f236 = rec[235].to_s.to_i
    f237 = rec[236].to_s.to_i
    f238 = rec[237].to_s.to_i
    f239 = rec[238].to_s.to_i
    f240 = rec[239].to_s.to_i
    f241 = rec[240].to_s.to_i
    f242 = rec[241].to_s.to_i
    f243 = rec[242].to_s.to_i
    f244 = rec[243].to_s.to_i
    f245 = rec[244].to_s.to_i
    f246 = rec[245].to_s.to_i
    f247 = rec[246].to_s.to_i
    f248 = rec[247].to_s.to_i
    f249 = rec[248].to_s.to_i
    f250 = rec[249].to_s.to_i
    f251 = rec[250].to_s.to_i
    f252 = rec[251].to_s.to_i
    f253 = rec[252].to_s.to_i
    f254 = rec[253].to_s.to_i
    f255 = rec[254].to_s.to_i
    f256 = rec[255].to_s.to_i
    f257 = rec[256].to_s.to_i
    f258 = rec[257].to_s.to_i
    f259 = rec[258].to_s.to_i
    f260 = rec[259].to_s.to_i
    f261 = rec[260].to_s.to_i
    f262 = rec[261].to_s.to_i
    f263 = rec[262].to_s.to_i
    f264 = rec[263].to_s.to_i
    f265 = rec[264].to_s.to_i
    f266 = rec[265].to_s.to_i
    f267 = rec[266].to_s.to_i
    f268 = rec[267].to_s.to_i
    f269 = rec[268].to_s.to_i
    f270 = rec[269].to_s.to_i
    f271 = rec[270].to_s.to_i
    f272 = rec[271].to_s.to_i
    f273 = rec[272].to_s.to_i
    f274 = rec[273].to_s.to_i
    f275 = rec[274].to_s.to_i
    f276 = rec[275].to_s.to_i
    f277 = rec[276].to_s.to_i
    f278 = rec[277].to_s.to_i
    f279 = rec[278].to_s.to_i
    f280 = rec[279].to_s.to_i
    f281 = rec[280].to_s.to_i
    f282 = rec[281].to_s.to_i
    f283 = rec[282].to_s.to_i
    f284 = rec[283].to_s.to_i
    f285 = rec[284].to_s.to_i
    f286 = rec[285].to_s.to_i
    f287 = rec[286].to_s.to_i
    f288 = rec[287].to_s.to_i
    f289 = rec[288].to_s.to_i
    f290 = rec[289].to_s.to_i
    f291 = rec[290].to_s.to_i
    f292 = rec[291].to_s.to_i
    f293 = rec[292].to_s.to_i
    f294 = rec[293].to_s.to_i
    f295 = rec[294].to_s.to_i
    f296 = rec[295].to_s.to_i
    f297 = rec[296].to_s.to_i
    f298 = rec[297].to_s.to_i
    f299 = rec[298].to_s.to_i
    f300 = rec[299].to_s.to_i
    f301 = rec[300].to_s.to_i
    f302 = rec[301].to_s.to_i
    f303 = rec[302].to_s.to_i
    f304 = rec[303].to_s.to_i
    f305 = rec[304].to_s.to_i
    f306 = rec[305].to_s.to_i
    f307 = rec[306].to_s.to_i
    f308 = rec[307].to_s.to_i
    f309 = rec[308].to_s.to_i
    f310 = rec[309].to_s.to_i
    f311 = rec[310].to_s.to_i
    f312 = rec[311].to_s.to_i
    f313 = rec[312].to_s.to_i
    f314 = rec[313].to_s.to_i
    f315 = rec[314].to_s.to_i
    f316 = rec[315].to_s.to_i
    f317 = rec[316].to_s.to_i
    f318 = rec[317].to_s.to_i
    f319 = rec[318].to_s.to_i
    f320 = rec[319].to_s.to_i
    f321 = rec[320].to_s.to_i
    
    f1to79 = 0
    (5..320).each do |x|
      if (totalCol[x].nil?)
        totalCol[x] = 0
      end
      totalCol[x] += rec[x].to_s.to_i
      f1to79 += rec[x].to_s.to_i
    end
      
    h1 = "#{h1}#{ord},#{f1},#{f2},#{f3},#{f4},#{otype},#{f5},#{f6},#{f7},#{f8},#{f9},#{f10},#{f11},#{f12},#{f13},#{f14},#{f15},#{f16},#{f17},#{f18},#{f19},#{f20},#{f21},#{f22},#{f23},#{f24},#{f25},#{f26},#{f27},#{f28},#{f29},#{f30},#{f31},#{f32},#{f33},#{f34},#{f35},#{f36},#{f37},#{f38},#{f39},#{f40},#{f41},#{f42},#{f43},#{f44},#{f45},#{f46},#{f47},#{f48},#{f49},#{f50},#{f51},#{f52},#{f53},#{f54},#{f55},#{f56},#{f57},#{f58},#{f59},#{f60},#{f61},#{f62},#{f63},#{f64},#{f65},#{f66},#{f67},#{f68},#{f69},#{f70},#{f71},#{f72},#{f73},#{f74},#{f75},#{f76},#{f77},#{f78},#{f79},#{f80},#{f81},#{f82},#{f83},#{f84},#{f85},#{f86},#{f87},#{f88},#{f89},#{f90},#{f91},#{f92},#{f93},#{f94},#{f95},#{f96},#{f97},#{f98},#{f99},#{f100},#{f101},#{f102},#{f103},#{f104},#{f105},#{f106},#{f107},#{f108},#{f109},#{f110},#{f111},#{f112},#{f113},#{f114},#{f115},#{f116},#{f117},#{f118},#{f119},#{f120},#{f121},#{f122},#{f123},#{f124},#{f125},#{f126},#{f127},#{f128},#{f129},#{f130},#{f131},#{f132},#{f133},#{f134},#{f135},#{f136},#{f137},#{f138},#{f139},#{f140},#{f141},#{f142},#{f143},#{f144},#{f145},#{f146},#{f147},#{f148},#{f149},#{f150},#{f151},#{f152},#{f153},#{f154},#{f155},#{f156},#{f157},#{f158},#{f159},#{f160},#{f161},#{f162},#{f163},#{f164},#{f165},#{f166},#{f167},#{f168},#{f169},#{f170},#{f171},#{f172},#{f173},#{f174},#{f175},#{f176},#{f177},#{f178},#{f179},#{f180},#{f181},#{f182},#{f183},#{f184},#{f185},#{f186},#{f187},#{f188},#{f189},#{f190},#{f191},#{f192},#{f193},#{f194},#{f195},#{f196},#{f197},#{f198},#{f199},#{f200},#{f201},#{f202},#{f203},#{f204},#{f205},#{f206},#{f207},#{f208},#{f209},#{f210},#{f211},#{f212},#{f213},#{f214},#{f215},#{f216},#{f217},#{f218},#{f219},#{f220},#{f221},#{f222},#{f223},#{f224},#{f225},#{f226},#{f227},#{f228},#{f229},#{f230},#{f231},#{f232},#{f233},#{f234},#{f235},#{f236},#{f237},#{f238},#{f239},#{f240},#{f241},#{f242},#{f243},#{f244},#{f245},#{f246},#{f247},#{f248},#{f249},#{f250},#{f251},#{f252},#{f253},#{f254},#{f255},#{f256},#{f257},#{f258},#{f259},#{f260},#{f261},#{f262},#{f263},#{f264},#{f265},#{f266},#{f267},#{f268},#{f269},#{f270},#{f271},#{f272},#{f273},#{f274},#{f275},#{f276},#{f277},#{f278},#{f279},#{f280},#{f281},#{f282},#{f283},#{f284},#{f285},#{f286},#{f287},#{f288},#{f289},#{f290},#{f291},#{f292},#{f293},#{f294},#{f295},#{f296},#{f297},#{f298},#{f299},#{f300},#{f301},#{f302},#{f303},#{f304},#{f305},#{f306},#{f307},#{f308},#{f309},#{f310},#{f311},#{f312},#{f313},#{f314},#{f315},#{f316},#{f317},#{f318},#{f319},#{f320},#{f321},#{f1to79}\n"

    h2 = "#{h2}<tr><th>#{ord}</th><th>#{f1}</th><th>#{f2}</th><th>#{f3}</th><td>#{f4}</td><th>#{otype}</th><th>#{f5}</th>"
    h2 += (f6 > 0) ? "<th class='hili'>#{f6}</th>" : "<th>#{f6}</th>"
    h2 += (f7 > 0) ? "<th class='hili'>#{f7}</th>" : "<th>#{f7}</th>"
    h2 += (f8 > 0) ? "<th class='hili'>#{f8}</th>" : "<th>#{f8}</th>"
    h2 += (f9 > 0) ? "<th class='hili'>#{f9}</th>" : "<th>#{f9}</th>"
    h2 += (f10 > 0) ? "<th class='hili'>#{f10}</th>" : "<th>#{f10}</th>"
    h2 += (f11 > 0) ? "<th class='hili'>#{f11}</th>" : "<th>#{f11}</th>"
    h2 += (f12 > 0) ? "<th class='hili'>#{f12}</th>" : "<th>#{f12}</th>"
    h2 += (f13 > 0) ? "<th class='hili'>#{f13}</th>" : "<th>#{f13}</th>"
    h2 += (f14 > 0) ? "<th class='hili'>#{f14}</th>" : "<th>#{f14}</th>"
    h2 += (f15 > 0) ? "<th class='hili'>#{f15}</th>" : "<th>#{f15}</th>"
    h2 += (f16 > 0) ? "<th class='hili'>#{f16}</th>" : "<th>#{f16}</th>"
    h2 += (f17 > 0) ? "<th class='hili'>#{f17}</th>" : "<th>#{f17}</th>"
    h2 += (f18 > 0) ? "<th class='hili'>#{f18}</th>" : "<th>#{f18}</th>"
    h2 += (f19 > 0) ? "<th class='hili'>#{f19}</th>" : "<th>#{f19}</th>"
    h2 += (f20 > 0) ? "<th class='hili'>#{f20}</th>" : "<th>#{f20}</th>"
    h2 += (f21 > 0) ? "<th class='hili'>#{f21}</th>" : "<th>#{f21}</th>"
    h2 += (f22 > 0) ? "<th class='hili'>#{f22}</th>" : "<th>#{f22}</th>"
    h2 += (f23 > 0) ? "<th class='hili'>#{f23}</th>" : "<th>#{f23}</th>"
    h2 += (f24 > 0) ? "<th class='hili'>#{f24}</th>" : "<th>#{f24}</th>"
    h2 += (f25 > 0) ? "<th class='hili'>#{f25}</th>" : "<th>#{f25}</th>"
    h2 += (f26 > 0) ? "<th class='hili'>#{f26}</th>" : "<th>#{f26}</th>"
    h2 += (f27 > 0) ? "<th class='hili'>#{f27}</th>" : "<th>#{f27}</th>"
    h2 += (f28 > 0) ? "<th class='hili'>#{f28}</th>" : "<th>#{f28}</th>"
    h2 += (f29 > 0) ? "<th class='hili'>#{f29}</th>" : "<th>#{f29}</th>"
    h2 += (f30 > 0) ? "<th class='hili'>#{f30}</th>" : "<th>#{f30}</th>"
    h2 += (f31 > 0) ? "<th class='hili'>#{f31}</th>" : "<th>#{f31}</th>"
    h2 += (f32 > 0) ? "<th class='hili'>#{f32}</th>" : "<th>#{f32}</th>"
    h2 += (f33 > 0) ? "<th class='hili'>#{f33}</th>" : "<th>#{f33}</th>"
    h2 += (f34 > 0) ? "<th class='hili'>#{f34}</th>" : "<th>#{f34}</th>"
    h2 += (f35 > 0) ? "<th class='hili'>#{f35}</th>" : "<th>#{f35}</th>"
    h2 += (f36 > 0) ? "<th class='hili'>#{f36}</th>" : "<th>#{f36}</th>"
    h2 += (f37 > 0) ? "<th class='hili'>#{f37}</th>" : "<th>#{f37}</th>"
    h2 += (f38 > 0) ? "<th class='hili'>#{f38}</th>" : "<th>#{f38}</th>"
    h2 += (f39 > 0) ? "<th class='hili'>#{f39}</th>" : "<th>#{f39}</th>"
    h2 += (f40 > 0) ? "<th class='hili'>#{f40}</th>" : "<th>#{f40}</th>"
    h2 += (f41 > 0) ? "<th class='hili'>#{f41}</th>" : "<th>#{f41}</th>"
    h2 += (f42 > 0) ? "<th class='hili'>#{f42}</th>" : "<th>#{f42}</th>"
    h2 += (f43 > 0) ? "<th class='hili'>#{f43}</th>" : "<th>#{f43}</th>"
    h2 += (f44 > 0) ? "<th class='hili'>#{f44}</th>" : "<th>#{f44}</th>"
    h2 += (f45 > 0) ? "<th class='hili'>#{f45}</th>" : "<th>#{f45}</th>"
    h2 += (f46 > 0) ? "<th class='hili'>#{f46}</th>" : "<th>#{f46}</th>"
    h2 += (f47 > 0) ? "<th class='hili'>#{f47}</th>" : "<th>#{f47}</th>"
    h2 += (f48 > 0) ? "<th class='hili'>#{f48}</th>" : "<th>#{f48}</th>"
    h2 += (f49 > 0) ? "<th class='hili'>#{f49}</th>" : "<th>#{f49}</th>"
    h2 += (f50 > 0) ? "<th class='hili'>#{f50}</th>" : "<th>#{f50}</th>"
    h2 += (f51 > 0) ? "<th class='hili'>#{f51}</th>" : "<th>#{f51}</th>"
    h2 += (f52 > 0) ? "<th class='hili'>#{f52}</th>" : "<th>#{f52}</th>"
    h2 += (f53 > 0) ? "<th class='hili'>#{f53}</th>" : "<th>#{f53}</th>"
    h2 += (f54 > 0) ? "<th class='hili'>#{f54}</th>" : "<th>#{f54}</th>"
    h2 += (f55 > 0) ? "<th class='hili'>#{f55}</th>" : "<th>#{f55}</th>"
    h2 += (f56 > 0) ? "<th class='hili'>#{f56}</th>" : "<th>#{f56}</th>"
    h2 += (f57 > 0) ? "<th class='hili'>#{f57}</th>" : "<th>#{f57}</th>"
    h2 += (f58 > 0) ? "<th class='hili'>#{f58}</th>" : "<th>#{f58}</th>"
    h2 += (f59 > 0) ? "<th class='hili'>#{f59}</th>" : "<th>#{f59}</th>"
    h2 += (f60 > 0) ? "<th class='hili'>#{f60}</th>" : "<th>#{f60}</th>"
    h2 += (f61 > 0) ? "<th class='hili'>#{f61}</th>" : "<th>#{f61}</th>"
    h2 += (f62 > 0) ? "<th class='hili'>#{f62}</th>" : "<th>#{f62}</th>"
    h2 += (f63 > 0) ? "<th class='hili'>#{f63}</th>" : "<th>#{f63}</th>"
    h2 += (f64 > 0) ? "<th class='hili'>#{f64}</th>" : "<th>#{f64}</th>"
    h2 += (f65 > 0) ? "<th class='hili'>#{f65}</th>" : "<th>#{f65}</th>"
    h2 += (f66 > 0) ? "<th class='hili'>#{f66}</th>" : "<th>#{f66}</th>"
    h2 += (f67 > 0) ? "<th class='hili'>#{f67}</th>" : "<th>#{f67}</th>"
    h2 += (f68 > 0) ? "<th class='hili'>#{f68}</th>" : "<th>#{f68}</th>"
    h2 += (f69 > 0) ? "<th class='hili'>#{f69}</th>" : "<th>#{f69}</th>"
    h2 += (f70 > 0) ? "<th class='hili'>#{f70}</th>" : "<th>#{f70}</th>"
    h2 += (f71 > 0) ? "<th class='hili'>#{f71}</th>" : "<th>#{f71}</th>"
    h2 += (f72 > 0) ? "<th class='hili'>#{f72}</th>" : "<th>#{f72}</th>"
    h2 += (f73 > 0) ? "<th class='hili'>#{f73}</th>" : "<th>#{f73}</th>"
    h2 += (f74 > 0) ? "<th class='hili'>#{f74}</th>" : "<th>#{f74}</th>"
    h2 += (f75 > 0) ? "<th class='hili'>#{f75}</th>" : "<th>#{f75}</th>"
    h2 += (f76 > 0) ? "<th class='hili'>#{f76}</th>" : "<th>#{f76}</th>"
    h2 += (f77 > 0) ? "<th class='hili'>#{f77}</th>" : "<th>#{f77}</th>"
    h2 += (f78 > 0) ? "<th class='hili'>#{f78}</th>" : "<th>#{f78}</th>"
    h2 += (f79 > 0) ? "<th class='hili'>#{f79}</th>" : "<th>#{f79}</th>"
    h2 += (f80 > 0) ? "<th class='hili'>#{f80}</th>" : "<th>#{f80}</th>"
    h2 += (f81 > 0) ? "<th class='hili'>#{f81}</th>" : "<th>#{f81}</th>"
    h2 += (f82 > 0) ? "<th class='hili'>#{f82}</th>" : "<th>#{f82}</th>"
    h2 += (f83 > 0) ? "<th class='hili'>#{f83}</th>" : "<th>#{f83}</th>"
    h2 += (f84 > 0) ? "<th class='hili'>#{f84}</th>" : "<th>#{f84}</th>"
    h2 += (f85 > 0) ? "<th class='hili'>#{f85}</th>" : "<th>#{f85}</th>"
    h2 += (f86 > 0) ? "<th class='hili'>#{f86}</th>" : "<th>#{f86}</th>"
    h2 += (f87 > 0) ? "<th class='hili'>#{f87}</th>" : "<th>#{f87}</th>"
    h2 += (f88 > 0) ? "<th class='hili'>#{f88}</th>" : "<th>#{f88}</th>"
    h2 += (f89 > 0) ? "<th class='hili'>#{f89}</th>" : "<th>#{f89}</th>"
    h2 += (f90 > 0) ? "<th class='hili'>#{f90}</th>" : "<th>#{f90}</th>"
    h2 += (f91 > 0) ? "<th class='hili'>#{f91}</th>" : "<th>#{f91}</th>"
    h2 += (f92 > 0) ? "<th class='hili'>#{f92}</th>" : "<th>#{f92}</th>"
    h2 += (f93 > 0) ? "<th class='hili'>#{f93}</th>" : "<th>#{f93}</th>"
    h2 += (f94 > 0) ? "<th class='hili'>#{f94}</th>" : "<th>#{f94}</th>"
    h2 += (f95 > 0) ? "<th class='hili'>#{f95}</th>" : "<th>#{f95}</th>"
    h2 += (f96 > 0) ? "<th class='hili'>#{f96}</th>" : "<th>#{f96}</th>"
    h2 += (f97 > 0) ? "<th class='hili'>#{f97}</th>" : "<th>#{f97}</th>"
    h2 += (f98 > 0) ? "<th class='hili'>#{f98}</th>" : "<th>#{f98}</th>"
    h2 += (f99 > 0) ? "<th class='hili'>#{f99}</th>" : "<th>#{f99}</th>"
    h2 += (f100 > 0) ? "<th class='hili'>#{f100}</th>" : "<th>#{f100}</th>"
    h2 += (f101 > 0) ? "<th class='hili'>#{f101}</th>" : "<th>#{f101}</th>"
    h2 += (f102 > 0) ? "<th class='hili'>#{f102}</th>" : "<th>#{f102}</th>"
    h2 += (f103 > 0) ? "<th class='hili'>#{f103}</th>" : "<th>#{f103}</th>"
    h2 += (f104 > 0) ? "<th class='hili'>#{f104}</th>" : "<th>#{f104}</th>"
    h2 += (f105 > 0) ? "<th class='hili'>#{f105}</th>" : "<th>#{f105}</th>"
    h2 += (f106 > 0) ? "<th class='hili'>#{f106}</th>" : "<th>#{f106}</th>"
    h2 += (f107 > 0) ? "<th class='hili'>#{f107}</th>" : "<th>#{f107}</th>"
    h2 += (f108 > 0) ? "<th class='hili'>#{f108}</th>" : "<th>#{f108}</th>"
    h2 += (f109 > 0) ? "<th class='hili'>#{f109}</th>" : "<th>#{f109}</th>"
    h2 += (f110 > 0) ? "<th class='hili'>#{f110}</th>" : "<th>#{f110}</th>"
    h2 += (f111 > 0) ? "<th class='hili'>#{f111}</th>" : "<th>#{f111}</th>"
    h2 += (f112 > 0) ? "<th class='hili'>#{f112}</th>" : "<th>#{f112}</th>"
    h2 += (f113 > 0) ? "<th class='hili'>#{f113}</th>" : "<th>#{f113}</th>"
    h2 += (f114 > 0) ? "<th class='hili'>#{f114}</th>" : "<th>#{f114}</th>"
    h2 += (f115 > 0) ? "<th class='hili'>#{f115}</th>" : "<th>#{f115}</th>"
    h2 += (f116 > 0) ? "<th class='hili'>#{f116}</th>" : "<th>#{f116}</th>"
    h2 += (f117 > 0) ? "<th class='hili'>#{f117}</th>" : "<th>#{f117}</th>"
    h2 += (f118 > 0) ? "<th class='hili'>#{f118}</th>" : "<th>#{f118}</th>"
    h2 += (f119 > 0) ? "<th class='hili'>#{f119}</th>" : "<th>#{f119}</th>"
    h2 += (f120 > 0) ? "<th class='hili'>#{f120}</th>" : "<th>#{f120}</th>"
    h2 += (f121 > 0) ? "<th class='hili'>#{f121}</th>" : "<th>#{f121}</th>"
    h2 += (f122 > 0) ? "<th class='hili'>#{f122}</th>" : "<th>#{f122}</th>"
    h2 += (f123 > 0) ? "<th class='hili'>#{f123}</th>" : "<th>#{f123}</th>"
    h2 += (f124 > 0) ? "<th class='hili'>#{f124}</th>" : "<th>#{f124}</th>"
    h2 += (f125 > 0) ? "<th class='hili'>#{f125}</th>" : "<th>#{f125}</th>"
    h2 += (f126 > 0) ? "<th class='hili'>#{f126}</th>" : "<th>#{f126}</th>"
    h2 += (f127 > 0) ? "<th class='hili'>#{f127}</th>" : "<th>#{f127}</th>"
    h2 += (f128 > 0) ? "<th class='hili'>#{f128}</th>" : "<th>#{f128}</th>"
    h2 += (f129 > 0) ? "<th class='hili'>#{f129}</th>" : "<th>#{f129}</th>"
    h2 += (f130 > 0) ? "<th class='hili'>#{f130}</th>" : "<th>#{f130}</th>"
    h2 += (f131 > 0) ? "<th class='hili'>#{f131}</th>" : "<th>#{f131}</th>"
    h2 += (f132 > 0) ? "<th class='hili'>#{f132}</th>" : "<th>#{f132}</th>"
    h2 += (f133 > 0) ? "<th class='hili'>#{f133}</th>" : "<th>#{f133}</th>"
    h2 += (f134 > 0) ? "<th class='hili'>#{f134}</th>" : "<th>#{f134}</th>"
    h2 += (f135 > 0) ? "<th class='hili'>#{f135}</th>" : "<th>#{f135}</th>"
    h2 += (f136 > 0) ? "<th class='hili'>#{f136}</th>" : "<th>#{f136}</th>"
    h2 += (f137 > 0) ? "<th class='hili'>#{f137}</th>" : "<th>#{f137}</th>"
    h2 += (f138 > 0) ? "<th class='hili'>#{f138}</th>" : "<th>#{f138}</th>"
    h2 += (f139 > 0) ? "<th class='hili'>#{f139}</th>" : "<th>#{f139}</th>"
    h2 += (f140 > 0) ? "<th class='hili'>#{f140}</th>" : "<th>#{f140}</th>"
    h2 += (f141 > 0) ? "<th class='hili'>#{f141}</th>" : "<th>#{f141}</th>"
    h2 += (f142 > 0) ? "<th class='hili'>#{f142}</th>" : "<th>#{f142}</th>"
    h2 += (f143 > 0) ? "<th class='hili'>#{f143}</th>" : "<th>#{f143}</th>"
    h2 += (f144 > 0) ? "<th class='hili'>#{f144}</th>" : "<th>#{f144}</th>"
    h2 += (f145 > 0) ? "<th class='hili'>#{f145}</th>" : "<th>#{f145}</th>"
    h2 += (f146 > 0) ? "<th class='hili'>#{f146}</th>" : "<th>#{f146}</th>"
    h2 += (f147 > 0) ? "<th class='hili'>#{f147}</th>" : "<th>#{f147}</th>"
    h2 += (f148 > 0) ? "<th class='hili'>#{f148}</th>" : "<th>#{f148}</th>"
    h2 += (f149 > 0) ? "<th class='hili'>#{f149}</th>" : "<th>#{f149}</th>"
    h2 += (f150 > 0) ? "<th class='hili'>#{f150}</th>" : "<th>#{f150}</th>"
    h2 += (f151 > 0) ? "<th class='hili'>#{f151}</th>" : "<th>#{f151}</th>"
    h2 += (f152 > 0) ? "<th class='hili'>#{f152}</th>" : "<th>#{f152}</th>"
    h2 += (f153 > 0) ? "<th class='hili'>#{f153}</th>" : "<th>#{f153}</th>"
    h2 += (f154 > 0) ? "<th class='hili'>#{f154}</th>" : "<th>#{f154}</th>"
    h2 += (f155 > 0) ? "<th class='hili'>#{f155}</th>" : "<th>#{f155}</th>"
    h2 += (f156 > 0) ? "<th class='hili'>#{f156}</th>" : "<th>#{f156}</th>"
    h2 += (f157 > 0) ? "<th class='hili'>#{f157}</th>" : "<th>#{f157}</th>"
    h2 += (f158 > 0) ? "<th class='hili'>#{f158}</th>" : "<th>#{f158}</th>"
    h2 += (f159 > 0) ? "<th class='hili'>#{f159}</th>" : "<th>#{f159}</th>"
    h2 += (f160 > 0) ? "<th class='hili'>#{f160}</th>" : "<th>#{f160}</th>"
    h2 += (f161 > 0) ? "<th class='hili'>#{f161}</th>" : "<th>#{f161}</th>"
    h2 += (f162 > 0) ? "<th class='hili'>#{f162}</th>" : "<th>#{f162}</th>"
    h2 += (f163 > 0) ? "<th class='hili'>#{f163}</th>" : "<th>#{f163}</th>"
    h2 += (f164 > 0) ? "<th class='hili'>#{f164}</th>" : "<th>#{f164}</th>"
    h2 += (f165 > 0) ? "<th class='hili'>#{f165}</th>" : "<th>#{f165}</th>"
    h2 += (f166 > 0) ? "<th class='hili'>#{f166}</th>" : "<th>#{f166}</th>"
    h2 += (f167 > 0) ? "<th class='hili'>#{f167}</th>" : "<th>#{f167}</th>"
    h2 += (f168 > 0) ? "<th class='hili'>#{f168}</th>" : "<th>#{f168}</th>"
    h2 += (f169 > 0) ? "<th class='hili'>#{f169}</th>" : "<th>#{f169}</th>"
    h2 += (f170 > 0) ? "<th class='hili'>#{f170}</th>" : "<th>#{f170}</th>"
    h2 += (f171 > 0) ? "<th class='hili'>#{f171}</th>" : "<th>#{f171}</th>"
    h2 += (f172 > 0) ? "<th class='hili'>#{f172}</th>" : "<th>#{f172}</th>"
    h2 += (f173 > 0) ? "<th class='hili'>#{f173}</th>" : "<th>#{f173}</th>"
    h2 += (f174 > 0) ? "<th class='hili'>#{f174}</th>" : "<th>#{f174}</th>"
    h2 += (f175 > 0) ? "<th class='hili'>#{f175}</th>" : "<th>#{f175}</th>"
    h2 += (f176 > 0) ? "<th class='hili'>#{f176}</th>" : "<th>#{f176}</th>"
    h2 += (f177 > 0) ? "<th class='hili'>#{f177}</th>" : "<th>#{f177}</th>"
    h2 += (f178 > 0) ? "<th class='hili'>#{f178}</th>" : "<th>#{f178}</th>"
    h2 += (f179 > 0) ? "<th class='hili'>#{f179}</th>" : "<th>#{f179}</th>"
    h2 += (f180 > 0) ? "<th class='hili'>#{f180}</th>" : "<th>#{f180}</th>"
    h2 += (f181 > 0) ? "<th class='hili'>#{f181}</th>" : "<th>#{f181}</th>"
    h2 += (f182 > 0) ? "<th class='hili'>#{f182}</th>" : "<th>#{f182}</th>"
    h2 += (f183 > 0) ? "<th class='hili'>#{f183}</th>" : "<th>#{f183}</th>"
    h2 += (f184 > 0) ? "<th class='hili'>#{f184}</th>" : "<th>#{f184}</th>"
    h2 += (f185 > 0) ? "<th class='hili'>#{f185}</th>" : "<th>#{f185}</th>"
    h2 += (f186 > 0) ? "<th class='hili'>#{f186}</th>" : "<th>#{f186}</th>"
    h2 += (f187 > 0) ? "<th class='hili'>#{f187}</th>" : "<th>#{f187}</th>"
    h2 += (f188 > 0) ? "<th class='hili'>#{f188}</th>" : "<th>#{f188}</th>"
    h2 += (f189 > 0) ? "<th class='hili'>#{f189}</th>" : "<th>#{f189}</th>"
    h2 += (f190 > 0) ? "<th class='hili'>#{f190}</th>" : "<th>#{f190}</th>"
    h2 += (f191 > 0) ? "<th class='hili'>#{f191}</th>" : "<th>#{f191}</th>"
    h2 += (f192 > 0) ? "<th class='hili'>#{f192}</th>" : "<th>#{f192}</th>"
    h2 += (f193 > 0) ? "<th class='hili'>#{f193}</th>" : "<th>#{f193}</th>"
    h2 += (f194 > 0) ? "<th class='hili'>#{f194}</th>" : "<th>#{f194}</th>"
    h2 += (f195 > 0) ? "<th class='hili'>#{f195}</th>" : "<th>#{f195}</th>"
    h2 += (f196 > 0) ? "<th class='hili'>#{f196}</th>" : "<th>#{f196}</th>"
    h2 += (f197 > 0) ? "<th class='hili'>#{f197}</th>" : "<th>#{f197}</th>"
    h2 += (f198 > 0) ? "<th class='hili'>#{f198}</th>" : "<th>#{f198}</th>"
    h2 += (f199 > 0) ? "<th class='hili'>#{f199}</th>" : "<th>#{f199}</th>"
    h2 += (f200 > 0) ? "<th class='hili'>#{f200}</th>" : "<th>#{f200}</th>"
    h2 += (f201 > 0) ? "<th class='hili'>#{f201}</th>" : "<th>#{f201}</th>"
    if (year.to_i > 46)
      h2 += (f202 > 0) ? "<th class='hili'>#{f202}</th>" : "<th>#{f202}</th>"
      h2 += (f203 > 0) ? "<th class='hili'>#{f203}</th>" : "<th>#{f203}</th>"
      h2 += (f204 > 0) ? "<th class='hili'>#{f204}</th>" : "<th>#{f204}</th>"
      h2 += (f205 > 0) ? "<th class='hili'>#{f205}</th>" : "<th>#{f205}</th>"
      h2 += (f206 > 0) ? "<th class='hili'>#{f206}</th>" : "<th>#{f206}</th>"
      h2 += (f207 > 0) ? "<th class='hili'>#{f207}</th>" : "<th>#{f207}</th>"
      h2 += (f208 > 0) ? "<th class='hili'>#{f208}</th>" : "<th>#{f208}</th>"
      h2 += (f209 > 0) ? "<th class='hili'>#{f209}</th>" : "<th>#{f209}</th>"
      h2 += (f210 > 0) ? "<th class='hili'>#{f210}</th>" : "<th>#{f210}</th>"
      h2 += (f211 > 0) ? "<th class='hili'>#{f211}</th>" : "<th>#{f211}</th>"
      h2 += (f212 > 0) ? "<th class='hili'>#{f212}</th>" : "<th>#{f212}</th>"
      h2 += (f213 > 0) ? "<th class='hili'>#{f213}</th>" : "<th>#{f213}</th>"
      h2 += (f214 > 0) ? "<th class='hili'>#{f214}</th>" : "<th>#{f214}</th>"
      h2 += (f215 > 0) ? "<th class='hili'>#{f215}</th>" : "<th>#{f215}</th>"
      h2 += (f216 > 0) ? "<th class='hili'>#{f216}</th>" : "<th>#{f216}</th>"
      h2 += (f217 > 0) ? "<th class='hili'>#{f217}</th>" : "<th>#{f217}</th>"
      if (year.to_i > 49)
        h2 += (f218 > 0) ? "<th class='hili'>#{f218}</th>" : "<th>#{f218}</th>"
        h2 += (f219 > 0) ? "<th class='hili'>#{f219}</th>" : "<th>#{f219}</th>"
        h2 += (f220 > 0) ? "<th class='hili'>#{f220}</th>" : "<th>#{f220}</th>"
        h2 += (f221 > 0) ? "<th class='hili'>#{f221}</th>" : "<th>#{f221}</th>"
        h2 += (f222 > 0) ? "<th class='hili'>#{f222}</th>" : "<th>#{f222}</th>"
        h2 += (f223 > 0) ? "<th class='hili'>#{f223}</th>" : "<th>#{f223}</th>"
        h2 += (f224 > 0) ? "<th class='hili'>#{f224}</th>" : "<th>#{f224}</th>"
        h2 += (f225 > 0) ? "<th class='hili'>#{f225}</th>" : "<th>#{f225}</th>"  
        h2 += (f226 > 0) ? "<th class='hili'>#{f226}</th>" : "<th>#{f226}</th>"
        h2 += (f227 > 0) ? "<th class='hili'>#{f227}</th>" : "<th>#{f227}</th>"
        h2 += (f228 > 0) ? "<th class='hili'>#{f228}</th>" : "<th>#{f228}</th>"
        h2 += (f229 > 0) ? "<th class='hili'>#{f229}</th>" : "<th>#{f229}</th>"
        h2 += (f230 > 0) ? "<th class='hili'>#{f230}</th>" : "<th>#{f230}</th>"
        h2 += (f231 > 0) ? "<th class='hili'>#{f231}</th>" : "<th>#{f231}</th>"
        h2 += (f232 > 0) ? "<th class='hili'>#{f232}</th>" : "<th>#{f232}</th>"
        h2 += (f233 > 0) ? "<th class='hili'>#{f233}</th>" : "<th>#{f233}</th>"
        h2 += (f234 > 0) ? "<th class='hili'>#{f234}</th>" : "<th>#{f234}</th>"
        h2 += (f235 > 0) ? "<th class='hili'>#{f235}</th>" : "<th>#{f235}</th>"
        h2 += (f236 > 0) ? "<th class='hili'>#{f236}</th>" : "<th>#{f236}</th>"
        h2 += (f237 > 0) ? "<th class='hili'>#{f237}</th>" : "<th>#{f237}</th>"
        h2 += (f238 > 0) ? "<th class='hili'>#{f238}</th>" : "<th>#{f238}</th>"
        h2 += (f239 > 0) ? "<th class='hili'>#{f239}</th>" : "<th>#{f239}</th>"
        h2 += (f240 > 0) ? "<th class='hili'>#{f240}</th>" : "<th>#{f240}</th>"
        h2 += (f241 > 0) ? "<th class='hili'>#{f241}</th>" : "<th>#{f241}</th>"
        h2 += (f242 > 0) ? "<th class='hili'>#{f242}</th>" : "<th>#{f242}</th>"
        h2 += (f243 > 0) ? "<th class='hili'>#{f243}</th>" : "<th>#{f243}</th>"
        h2 += (f244 > 0) ? "<th class='hili'>#{f244}</th>" : "<th>#{f244}</th>"
        h2 += (f245 > 0) ? "<th class='hili'>#{f245}</th>" : "<th>#{f245}</th>"
        h2 += (f246 > 0) ? "<th class='hili'>#{f246}</th>" : "<th>#{f246}</th>"
        h2 += (f247 > 0) ? "<th class='hili'>#{f247}</th>" : "<th>#{f247}</th>"
        h2 += (f248 > 0) ? "<th class='hili'>#{f248}</th>" : "<th>#{f248}</th>"
        h2 += (f249 > 0) ? "<th class='hili'>#{f249}</th>" : "<th>#{f249}</th>"
        h2 += (f250 > 0) ? "<th class='hili'>#{f250}</th>" : "<th>#{f250}</th>"
        h2 += (f251 > 0) ? "<th class='hili'>#{f251}</th>" : "<th>#{f251}</th>"
        h2 += (f252 > 0) ? "<th class='hili'>#{f252}</th>" : "<th>#{f252}</th>"
        h2 += (f253 > 0) ? "<th class='hili'>#{f253}</th>" : "<th>#{f253}</th>"
        h2 += (f254 > 0) ? "<th class='hili'>#{f254}</th>" : "<th>#{f254}</th>"
        h2 += (f255 > 0) ? "<th class='hili'>#{f255}</th>" : "<th>#{f255}</th>"
        h2 += (f256 > 0) ? "<th class='hili'>#{f256}</th>" : "<th>#{f256}</th>"
        h2 += (f257 > 0) ? "<th class='hili'>#{f257}</th>" : "<th>#{f257}</th>"
        h2 += (f258 > 0) ? "<th class='hili'>#{f258}</th>" : "<th>#{f258}</th>"
        h2 += (f259 > 0) ? "<th class='hili'>#{f259}</th>" : "<th>#{f259}</th>"
        h2 += (f260 > 0) ? "<th class='hili'>#{f260}</th>" : "<th>#{f260}</th>"
        h2 += (f261 > 0) ? "<th class='hili'>#{f261}</th>" : "<th>#{f261}</th>"
        h2 += (f262 > 0) ? "<th class='hili'>#{f262}</th>" : "<th>#{f262}</th>"
        h2 += (f263 > 0) ? "<th class='hili'>#{f263}</th>" : "<th>#{f263}</th>"
        h2 += (f264 > 0) ? "<th class='hili'>#{f264}</th>" : "<th>#{f264}</th>"
        h2 += (f265 > 0) ? "<th class='hili'>#{f265}</th>" : "<th>#{f265}</th>"
        h2 += (f266 > 0) ? "<th class='hili'>#{f266}</th>" : "<th>#{f266}</th>"
        h2 += (f267 > 0) ? "<th class='hili'>#{f267}</th>" : "<th>#{f267}</th>"
        h2 += (f268 > 0) ? "<th class='hili'>#{f268}</th>" : "<th>#{f268}</th>"
        h2 += (f269 > 0) ? "<th class='hili'>#{f269}</th>" : "<th>#{f269}</th>"
        h2 += (f270 > 0) ? "<th class='hili'>#{f270}</th>" : "<th>#{f270}</th>"
        h2 += (f271 > 0) ? "<th class='hili'>#{f271}</th>" : "<th>#{f271}</th>"
        h2 += (f272 > 0) ? "<th class='hili'>#{f272}</th>" : "<th>#{f272}</th>"
        h2 += (f273 > 0) ? "<th class='hili'>#{f273}</th>" : "<th>#{f273}</th>"
        h2 += (f274 > 0) ? "<th class='hili'>#{f274}</th>" : "<th>#{f274}</th>"
        h2 += (f275 > 0) ? "<th class='hili'>#{f275}</th>" : "<th>#{f275}</th>"
        h2 += (f276 > 0) ? "<th class='hili'>#{f276}</th>" : "<th>#{f276}</th>"
        h2 += (f277 > 0) ? "<th class='hili'>#{f277}</th>" : "<th>#{f277}</th>"
        h2 += (f278 > 0) ? "<th class='hili'>#{f278}</th>" : "<th>#{f278}</th>"
        h2 += (f279 > 0) ? "<th class='hili'>#{f279}</th>" : "<th>#{f279}</th>"
        h2 += (f280 > 0) ? "<th class='hili'>#{f280}</th>" : "<th>#{f280}</th>"
        h2 += (f281 > 0) ? "<th class='hili'>#{f281}</th>" : "<th>#{f281}</th>"
        h2 += (f282 > 0) ? "<th class='hili'>#{f282}</th>" : "<th>#{f282}</th>"
        h2 += (f283 > 0) ? "<th class='hili'>#{f283}</th>" : "<th>#{f283}</th>"
        h2 += (f284 > 0) ? "<th class='hili'>#{f284}</th>" : "<th>#{f284}</th>"
        h2 += (f285 > 0) ? "<th class='hili'>#{f285}</th>" : "<th>#{f285}</th>"
        h2 += (f286 > 0) ? "<th class='hili'>#{f286}</th>" : "<th>#{f286}</th>"
        h2 += (f287 > 0) ? "<th class='hili'>#{f287}</th>" : "<th>#{f287}</th>"
        h2 += (f288 > 0) ? "<th class='hili'>#{f288}</th>" : "<th>#{f288}</th>"
        h2 += (f289 > 0) ? "<th class='hili'>#{f289}</th>" : "<th>#{f289}</th>"
        h2 += (f290 > 0) ? "<th class='hili'>#{f290}</th>" : "<th>#{f290}</th>"
        h2 += (f291 > 0) ? "<th class='hili'>#{f291}</th>" : "<th>#{f291}</th>"
        h2 += (f292 > 0) ? "<th class='hili'>#{f292}</th>" : "<th>#{f292}</th>"
        h2 += (f293 > 0) ? "<th class='hili'>#{f293}</th>" : "<th>#{f293}</th>"
        h2 += (f294 > 0) ? "<th class='hili'>#{f294}</th>" : "<th>#{f294}</th>"
        h2 += (f295 > 0) ? "<th class='hili'>#{f295}</th>" : "<th>#{f295}</th>"
        h2 += (f296 > 0) ? "<th class='hili'>#{f296}</th>" : "<th>#{f296}</th>"
        h2 += (f297 > 0) ? "<th class='hili'>#{f297}</th>" : "<th>#{f297}</th>"
        h2 += (f298 > 0) ? "<th class='hili'>#{f298}</th>" : "<th>#{f298}</th>"
        h2 += (f299 > 0) ? "<th class='hili'>#{f299}</th>" : "<th>#{f299}</th>"
        h2 += (f300 > 0) ? "<th class='hili'>#{f300}</th>" : "<th>#{f300}</th>"
        h2 += (f301 > 0) ? "<th class='hili'>#{f301}</th>" : "<th>#{f301}</th>"
        h2 += (f302 > 0) ? "<th class='hili'>#{f302}</th>" : "<th>#{f302}</th>"
        h2 += (f303 > 0) ? "<th class='hili'>#{f303}</th>" : "<th>#{f303}</th>"
        h2 += (f304 > 0) ? "<th class='hili'>#{f304}</th>" : "<th>#{f304}</th>"
        h2 += (f305 > 0) ? "<th class='hili'>#{f305}</th>" : "<th>#{f305}</th>"
        h2 += (f306 > 0) ? "<th class='hili'>#{f306}</th>" : "<th>#{f306}</th>"
        h2 += (f307 > 0) ? "<th class='hili'>#{f307}</th>" : "<th>#{f307}</th>"
        h2 += (f308 > 0) ? "<th class='hili'>#{f308}</th>" : "<th>#{f308}</th>"
        h2 += (f309 > 0) ? "<th class='hili'>#{f309}</th>" : "<th>#{f309}</th>"
        h2 += (f310 > 0) ? "<th class='hili'>#{f310}</th>" : "<th>#{f310}</th>"
        h2 += (f311 > 0) ? "<th class='hili'>#{f311}</th>" : "<th>#{f311}</th>"
        h2 += (f312 > 0) ? "<th class='hili'>#{f312}</th>" : "<th>#{f312}</th>"
        h2 += (f313 > 0) ? "<th class='hili'>#{f313}</th>" : "<th>#{f313}</th>"
        h2 += (f314 > 0) ? "<th class='hili'>#{f314}</th>" : "<th>#{f314}</th>"
        h2 += (f315 > 0) ? "<th class='hili'>#{f315}</th>" : "<th>#{f315}</th>"
        h2 += (f316 > 0) ? "<th class='hili'>#{f316}</th>" : "<th>#{f316}</th>"
        h2 += (f317 > 0) ? "<th class='hili'>#{f317}</th>" : "<th>#{f317}</th>"
        h2 += (f318 > 0) ? "<th class='hili'>#{f318}</th>" : "<th>#{f318}</th>"
        h2 += (f319 > 0) ? "<th class='hili'>#{f319}</th>" : "<th>#{f319}</th>"
        h2 += (f320 > 0) ? "<th class='hili'>#{f320}</th>" : "<th>#{f320}</th>"
        h2 += (f321 > 0) ? "<th class='hili'>#{f321}</th>" : "<th>#{f321}</th>"
        h2 += (f1to79 > 0) ? "<th class='hili'>#{f1to79}</th>" : "<th>#{f1to79}</th>"
      end
    end
    h2 += "</tr>\n"
  end

  h2 = "#{h2}<tr bgcolor='yellow'><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th>"
  h2 += "<th align='right'>Total</th><th>&nbsp;</th><th>&nbsp;</th>"
  gTotal = 0
  (5..320).each do |x|
    gTotal += totalCol[x].to_s.to_i
    h2 += "<th><font color='red'>#{totalCol[x]}</font></th>"
  end
  h2 += "<th><font color='red'>#{gTotal}</font></th>"
  h2 += "</tr>\n"

  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def f15header(year,type,form)  
  h1 = "ลำดับที่,ปี,จังหวัด,รหัส,หน่วยงาน,ประเภท,รหัส,"
  h1 += "S01-1M,S01-1F,S01-2M,S01-2F,"
  h1 += "S02-1M,S02-1F,S02-2M,S02-2F,"
  h1 += "S03-1M,S03-1F,S03-2M,S03-2F,"
  h1 += "S04-1M,S04-1F,S04-2M,S04-2F,"
  h1 += "S05-1M,S05-1F,S05-2M,S05-2F,"
  h1 += "S06-1M,S06-1F,S06-2M,S06-2F,"
  h1 += "S07-1M,S07-1F,S07-2M,S07-2F,"
  h1 += "S08-1M,S08-1F,S08-2M,S08-2F,"
  h1 += "S09-1M,S09-1F,S09-2M,S09-2F,"
  h1 += "S10-1M,S10-1F,S10-2M,S10-2F,"
  h1 += "S11-1M,S11-1F,S11-2M,S11-2F,"
  h1 += "S12-1M,S12-1F,S12-2M,S12-2F,"
  h1 += "S13-1M,S13-1F,S13-2M,S13-2F,"
  h1 += "S14-1M,S14-1F,S14-2M,S14-2F,"
  h1 += "S15-1M,S15-1F,S15-2M,S15-2F,"
  h1 += "S16-1M,S16-1F,S16-2M,S16-2F,"
  h1 += "S17-1M,S17-1F,S17-2M,S17-2F,"
  h1 += "S18-1M,S18-1F,S18-2M,S18-2F,"
  h1 += "S19-1M,S19-1F,S19-2M,S19-2F,"
  h1 += "S20-1M,S20-1F,S20-2M,S20-2F,"
  h1 += "S21-1M,S21-1F,S21-2M,S21-2F,"
  h1 += "S22-1M,S22-1F,S22-2M,S22-2F,"
  h1 += "S23-1M,S23-1F,S23-2M,S23-2F,"
  h1 += "S24-1M,S24-1F,S24-2M,S24-2F,"
  h1 += "S25-1M,S25-1F,S25-2M,S25-2F,"
  h1 += "S26-1M,S26-1F,S26-2M,S26-2F,"
  h1 += "S27-1M,S27-1F,S27-2M,S27-2F,"
  h1 += "S28-1M,S28-1F,S28-2M,S28-2F,"
  h1 += "S29-1M,S29-1F,S29-2M,S29-2F,"
  h1 += "S30-1M,S30-1F,S30-2M,S30-2F,"
  h1 += "S31-1M,S31-1F,S31-2M,S31-2F,"
  h1 += "S32-1M,S32-1F,S32-2M,S32-2F,"
  h1 += "S33-1M,S33-1F,S33-2M,S33-2F,"
  h1 += "S34-1M,S34-1F,S34-2M,S34-2F,"
  h1 += "S35-1M,S35-1F,S35-2M,S35-2F,"
  h1 += "S36-1M,S36-1F,S36-2M,S36-2F,"
  h1 += "S37-1M,S37-1F,S37-2M,S37-2F,"
  h1 += "S38-1M,S38-1F,S38-2M,S38-2F,"
  h1 += "S39-1M,S39-1F,S39-2M,S39-2F,"
  h1 += "S40-1M,S40-1F,S40-2M,S40-2F"

  if (year < '52')
    h1 += "S41-1M,S41-1F,S41-2M,S41-2F"
    h1 += "S42-1M,S42-1F,S42-2M,S42-2F"
  end

  h1 += "\n"
  h2 = "<table border='1' width='100%'>"
  h2 += "<tr><th>ลำดับที่</th><th>ปี</th><th>จังหวัด</th><th>รหัส</th><th>หน่วยงาน</th><th>ประเภท</th><th>รหัส</th>"

  s011m = (form == '1') ? "s011m1" : "s011m5"
  s011f = (form == '1') ? "s011f1" : "s011f5"
  s012m = (form == '1') ? "s012m1" : "s012m5"
  s012f = (form == '1') ? "s012f1" : "s012f5"
  s021m = (form == '1') ? "s021m1" : "s021m5"
  s021f = (form == '1') ? "s021f1" : "s021f5"
  s022m = (form == '1') ? "s022m1" : "s022m5"
  s022f = (form == '1') ? "s022f1" : "s022f5"
  s031m = (form == '1') ? "s031m1" : "s031m5"
  s031f = (form == '1') ? "s031f1" : "s031f5"
  s032m = (form == '1') ? "s032m1" : "s032m5"
  s032f = (form == '1') ? "s032f1" : "s032f5"
  s041m = (form == '1') ? "s041m1" : "s041m5"
  s041f = (form == '1') ? "s041f1" : "s041f5"
  s042m = (form == '1') ? "s042m1" : "s042m5"
  s042f = (form == '1') ? "s042f1" : "s042f5"
  s051m = (form == '1') ? "s051m1" : "s051m5"
  s051f = (form == '1') ? "s051f1" : "s051f5"
  s052m = (form == '1') ? "s052m1" : "s052m5"
  s052f = (form == '1') ? "s052f1" : "s052f5"
  s061m = (form == '1') ? "s061m1" : "s061m5"
  s061f = (form == '1') ? "s061f1" : "s061f5"
  s062m = (form == '1') ? "s062m1" : "s062m5"
  s062f = (form == '1') ? "s062f1" : "s062f5"
  s071m = (form == '1') ? "s071m1" : "s071m5"
  s071f = (form == '1') ? "s071f1" : "s071f5"
  s072m = (form == '1') ? "s072m1" : "s072m5"
  s072f = (form == '1') ? "s072f1" : "s072f5"
  s081m = (form == '1') ? "s081m1" : "s081m5"
  s081f = (form == '1') ? "s081f1" : "s081f5"
  s082m = (form == '1') ? "s082m1" : "s082m5"
  s082f = (form == '1') ? "s082f1" : "s082f5"
  s091m = (form == '1') ? "s091m1" : "s091m5"
  s091f = (form == '1') ? "s091f1" : "s091f5"
  s092m = (form == '1') ? "s092m1" : "s092m5"
  s092f = (form == '1') ? "s092f1" : "s092f5"
  s101m = (form == '1') ? "s101m1" : "s101m5"
  s101f = (form == '1') ? "s101f1" : "s101f5"
  s102m = (form == '1') ? "s102m1" : "s102m5"
  s102f = (form == '1') ? "s102f1" : "s102f5"

  s111m = (form == '1') ? "s111m1" : "s111m5"
  s111f = (form == '1') ? "s111f1" : "s111f5"
  s112m = (form == '1') ? "s112m1" : "s112m5"
  s112f = (form == '1') ? "s112f1" : "s112f5"
  s121m = (form == '1') ? "s121m1" : "s121m5"
  s121f = (form == '1') ? "s121f1" : "s121f5"
  s122m = (form == '1') ? "s122m1" : "s122m5"
  s122f = (form == '1') ? "s122f1" : "s122f5"
  s131m = (form == '1') ? "s131m1" : "s131m5"
  s131f = (form == '1') ? "s131f1" : "s131f5"
  s132m = (form == '1') ? "s132m1" : "s132m5"
  s132f = (form == '1') ? "s132f1" : "s132f5"
  s141m = (form == '1') ? "s141m1" : "s141m5"
  s141f = (form == '1') ? "s141f1" : "s141f5"
  s142m = (form == '1') ? "s142m1" : "s142m5"
  s142f = (form == '1') ? "s142f1" : "s142f5"
  s151m = (form == '1') ? "s151m1" : "s151m5"
  s151f = (form == '1') ? "s151f1" : "s151f5"
  s152m = (form == '1') ? "s152m1" : "s152m5"
  s152f = (form == '1') ? "s152f1" : "s152f5"
  s161m = (form == '1') ? "s161m1" : "s161m5"
  s161f = (form == '1') ? "s161f1" : "s161f5"
  s162m = (form == '1') ? "s162m1" : "s162m5"
  s162f = (form == '1') ? "s162f1" : "s162f5"
  s171m = (form == '1') ? "s171m1" : "s171m5"
  s171f = (form == '1') ? "s171f1" : "s171f5"
  s172m = (form == '1') ? "s172m1" : "s172m5"
  s172f = (form == '1') ? "s172f1" : "s172f5"
  s181m = (form == '1') ? "s181m1" : "s181m5"
  s181f = (form == '1') ? "s181f1" : "s181f5"
  s182m = (form == '1') ? "s182m1" : "s182m5"
  s182f = (form == '1') ? "s182f1" : "s182f5"
  s191m = (form == '1') ? "s191m1" : "s191m5"
  s191f = (form == '1') ? "s191f1" : "s191f5"
  s192m = (form == '1') ? "s192m1" : "s192m5"
  s192f = (form == '1') ? "s192f1" : "s192f5"
  s201m = (form == '1') ? "s201m1" : "s201m5"
  s201f = (form == '1') ? "s201f1" : "s201f5"
  s202m = (form == '1') ? "s202m1" : "s202m5"
  s202f = (form == '1') ? "s202f1" : "s202f5"

  s211m = (form == '1') ? "s211m1" : "s211m5"
  s211f = (form == '1') ? "s211f1" : "s211f5"
  s212m = (form == '1') ? "s212m1" : "s212m5"
  s212f = (form == '1') ? "s212f1" : "s212f5"
  s221m = (form == '1') ? "s221m1" : "s221m5"
  s221f = (form == '1') ? "s221f1" : "s221f5"
  s222m = (form == '1') ? "s222m1" : "s222m5"
  s222f = (form == '1') ? "s222f1" : "s222f5"
  s231m = (form == '1') ? "s231m1" : "s231m5"
  s231f = (form == '1') ? "s231f1" : "s231f5"
  s232m = (form == '1') ? "s232m1" : "s232m5"
  s232f = (form == '1') ? "s232f1" : "s232f5"
  s241m = (form == '1') ? "s241m1" : "s241m5"
  s241f = (form == '1') ? "s241f1" : "s241f5"
  s242m = (form == '1') ? "s242m1" : "s242m5"
  s242f = (form == '1') ? "s242f1" : "s242f5"
  s251m = (form == '1') ? "s251m1" : "s251m5"
  s251f = (form == '1') ? "s251f1" : "s251f5"
  s252m = (form == '1') ? "s252m1" : "s252m5"
  s252f = (form == '1') ? "s252f1" : "s252f5"
  s261m = (form == '1') ? "s261m1" : "s261m5"
  s261f = (form == '1') ? "s261f1" : "s261f5"
  s262m = (form == '1') ? "s262m1" : "s262m5"
  s262f = (form == '1') ? "s262f1" : "s262f5"
  s271m = (form == '1') ? "s271m1" : "s271m5"
  s271f = (form == '1') ? "s271f1" : "s271f5"
  s272m = (form == '1') ? "s272m1" : "s272m5"
  s272f = (form == '1') ? "s272f1" : "s272f5"
  s281m = (form == '1') ? "s281m1" : "s281m5"
  s281f = (form == '1') ? "s281f1" : "s281f5"
  s282m = (form == '1') ? "s282m1" : "s282m5"
  s282f = (form == '1') ? "s282f1" : "s282f5"
  s291m = (form == '1') ? "s291m1" : "s291m5"
  s291f = (form == '1') ? "s291f1" : "s291f5"
  s292m = (form == '1') ? "s292m1" : "s292m5"
  s292f = (form == '1') ? "s292f1" : "s292f5"
  s301m = (form == '1') ? "s301m1" : "s301m5"
  s301f = (form == '1') ? "s301f1" : "s301f5"
  s302m = (form == '1') ? "s302m1" : "s302m5"
  s302f = (form == '1') ? "s302f1" : "s302f5"

  s311m = (form == '1') ? "s311m1" : "s311m5"
  s311f = (form == '1') ? "s311f1" : "s311f5"
  s312m = (form == '1') ? "s312m1" : "s312m5"
  s312f = (form == '1') ? "s312f1" : "s312f5"
  s321m = (form == '1') ? "s321m1" : "s321m5"
  s321f = (form == '1') ? "s321f1" : "s321f5"
  s322m = (form == '1') ? "s322m1" : "s322m5"
  s322f = (form == '1') ? "s322f1" : "s322f5"
  s331m = (form == '1') ? "s331m1" : "s331m5"
  s331f = (form == '1') ? "s331f1" : "s331f5"
  s332m = (form == '1') ? "s332m1" : "s332m5"
  s332f = (form == '1') ? "s332f1" : "s332f5"
  s341m = (form == '1') ? "s341m1" : "s341m5"
  s341f = (form == '1') ? "s341f1" : "s341f5"
  s342m = (form == '1') ? "s342m1" : "s342m5"
  s342f = (form == '1') ? "s342f1" : "s342f5"
  s351m = (form == '1') ? "s351m1" : "s351m5"
  s351f = (form == '1') ? "s351f1" : "s351f5"
  s352m = (form == '1') ? "s352m1" : "s352m5"
  s352f = (form == '1') ? "s352f1" : "s352f5"
  s361m = (form == '1') ? "s361m1" : "s361m5"
  s361f = (form == '1') ? "s361f1" : "s361f5"
  s362m = (form == '1') ? "s362m1" : "s362m5"
  s362f = (form == '1') ? "s362f1" : "s362f5"
  s371m = (form == '1') ? "s371m1" : "s371m5"
  s371f = (form == '1') ? "s371f1" : "s371f5"
  s372m = (form == '1') ? "s372m1" : "s372m5"
  s372f = (form == '1') ? "s372f1" : "s372f5"
  s381m = (form == '1') ? "s381m1" : "s381m5"
  s381f = (form == '1') ? "s381f1" : "s381f5"
  s382m = (form == '1') ? "s382m1" : "s382m5"
  s382f = (form == '1') ? "s382f1" : "s382f5"
  s391m = (form == '1') ? "s391m1" : "s391m5"
  s391f = (form == '1') ? "s391f1" : "s391f5"
  s392m = (form == '1') ? "s392m1" : "s392m5"
  s392f = (form == '1') ? "s392f1" : "s392f5"
  s401m = (form == '1') ? "s401m1" : "s401m5"
  s401f = (form == '1') ? "s401f1" : "s401f5"
  s402m = (form == '1') ? "s402m1" : "s402m5"
  s402f = (form == '1') ? "s402f1" : "s402f5"

  if (year < '52')
    s411m = (form == '1') ? "s411m1" : "s411m5"
    s411f = (form == '1') ? "s411f1" : "s411f5"
    s412m = (form == '1') ? "s412m1" : "s412m5"
    s412f = (form == '1') ? "s412f1" : "s412f5"
    s421m = (form == '1') ? "s421m1" : "s421m5"
    s421f = (form == '1') ? "s421f1" : "s421f5"
    s422m = (form == '1') ? "s422m1" : "s422m5"
    s422f = (form == '1') ? "s422f1" : "s422f5"
  end

  h2 += "<th><a href='#' onmouseover=\"Tip(#{s011m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S01-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s011f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S01-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s012m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S01-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s012f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S01-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s021m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S02-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s021f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S02-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s022m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S02-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s022f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S02-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s031m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S03-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s031f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S03-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s032m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S03-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s032f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S03-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s041m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S04-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s041f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S04-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s042m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S04-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s042f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S04-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s051m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S05-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s051f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S05-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s052m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S05-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s052f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S05-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s061m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S06-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s061f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S06-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s062m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S06-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s062f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S06-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s071m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S07-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s071f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S07-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s072m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S07-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s072f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S07-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s081m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S08-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s081f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S08-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s082m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S08-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s082f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S08-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s091m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S09-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s091f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S09-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s092m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S09-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s092f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S09-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s101m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S10-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s101f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S10-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s102m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S10-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s102f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S10-2F</a></th>"

  h2 += "<th><a href='#' onmouseover=\"Tip(#{s111m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S11-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s111f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S11-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s112m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S11-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s112f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S11-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s121m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S12-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s121f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S12-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s122m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S12-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s122f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S12-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s131m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S13-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s131f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S13-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s132m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S13-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s132f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S13-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s141m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S14-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s141f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S14-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s142m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S14-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s142f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S14-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s151m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S15-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s151f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S15-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s152m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S15-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s152f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S15-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s161m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S16-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s161f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S16-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s162m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S16-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s162f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S16-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s171m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S17-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s171f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S17-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s172m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S17-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s172f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S17-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s181m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S18-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s181f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S18-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s182m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S18-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s182f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S18-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s191m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S19-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s191f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S19-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s192m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S19-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s192f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S19-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s201m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S20-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s201f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S20-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s202m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S20-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s202f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S20-2F</a></th>"

  h2 += "<th><a href='#' onmouseover=\"Tip(#{s211m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S21-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s211f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S21-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s212m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S21-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s212f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S21-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s221m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S22-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s221f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S22-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s222m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S22-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s222f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S22-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s231m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S23-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s231f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S23-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s232m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S23-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s232f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S23-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s241m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S24-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s241f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S24-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s242m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S24-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s242f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S24-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s251m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S25-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s251f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S25-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s252m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S25-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s252f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S25-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s261m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S26-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s261f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S26-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s262m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S26-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s262f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S26-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s271m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S27-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s271f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S27-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s272m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S27-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s272f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S27-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s281m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S28-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s281f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S28-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s282m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S28-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s282f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S28-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s291m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S29-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s291f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S29-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s292m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S29-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s292f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S29-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s301m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S30-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s301f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S30-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s302m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S30-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s302f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S30-2F</a></th>"
  
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s311m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S31-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s311f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S31-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s312m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S31-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s312f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S31-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s321m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S32-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s321f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S32-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s322m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S32-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s322f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S32-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s331m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S33-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s331f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S33-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s332m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S33-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s332f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S33-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s341m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S34-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s341f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S34-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s342m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S34-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s342f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S34-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s351m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S35-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s351f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S35-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s352m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S35-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s352f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S35-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s361m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S36-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s361f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S36-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s362m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S36-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s362f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S36-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s371m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S37-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s371f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S37-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s372m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S37-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s372f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S37-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s381m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S38-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s381f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S38-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s382m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S38-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s382f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S38-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s391m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S39-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s391f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S39-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s392m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S39-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s392f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S39-2F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s401m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S40-1M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s401f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S40-1F</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s402m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S40-2M</a></th>"
  h2 += "<th><a href='#' onmouseover=\"Tip(#{s402f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S40-2F</a></th>"

  if (year < '52')
    h2 += "<th><a href='#' onmouseover=\"Tip(#{s411m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S41-1M</a></th>"
    h2 += "<th><a href='#' onmouseover=\"Tip(#{s411f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S41-1F</a></th>"
    h2 += "<th><a href='#' onmouseover=\"Tip(#{s412m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S41-2M</a></th>"
    h2 += "<th><a href='#' onmouseover=\"Tip(#{s412f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S41-2F</a></th>"
    h2 += "<th><a href='#' onmouseover=\"Tip(#{s421m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S42-1M</a></th>"
    h2 += "<th><a href='#' onmouseover=\"Tip(#{s421f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S42-1F</a></th>"
    h2 += "<th><a href='#' onmouseover=\"Tip(#{s422m},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S42-2M</a></th>"
    h2 += "<th><a href='#' onmouseover=\"Tip(#{s422f},ABOVE,true,FADEIN,400,FADEOUT,300,FONTWEIGHT,'bold')\" onmouseout=\"UnTip()\">S42-2F</a></th>"
  end

  h2 += "<th>Total</th>"

  h2 += "</tr>\n"

  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def f15footer(year)
  h = "</table>\n"
  h += "<p><pre>หมายเหตุ<p>\n"
  h += "M = หน่วยงานกระทรวงสาธารณสุข\n"
  h += "G = หน่วยงานภาครัฐนอกกระทรวงสาธารณสุข\n"
  h += "P = หน่วยงานเอกชน\n\n"
  h += "Sxx-1M = ขรก./พนักงานของรัฐ ชาย\n"
  h += "Sxx-1F = ขรก./พนักงานของรัฐ หญิง\n"
  h += "Sxx-2M = ลูกจ้าง ชาย\n"
  h += "Sxx-2F = ลูกจ้าง หญิง\n\n"
  if (year < '52')
    h += "<a href='ftp://203.157.240.9/pub/resource51/prof-51.txt'>"
  else
    h += "<a href='ftp://203.157.240.9/pub/resource53/prof-52.txt'>"
  end
  h += "<input type='button' value='Download รหัสวิชาชีพ' "
  h += "onclick=\"document.location.href='ftp://203.157.240.9/pub/resource53/prof-52.txt'\" /></a>\n"
  h += "</pre>"
  h
end

def getForm1(year,pcode,acode,type)
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year}")
  sql = "SELECT * FROM form1 "
  if (acode.length == 4) # request from Amphoe
    if (acode =~ /01$/)
      sql += "WHERE (f1pcode='#{acode}' OR f1pcode='#{pcode}') "
    else
      sql += "WHERE f1pcode='#{acode}' "
    end
  else
    sql += "WHERE f1pcode='#{pcode}' "
  end
  sql += "ORDER BY f1hcode"
  res = con.exec(sql)
  con.close

  h1 = h2 = nil
  n = 0
  ord = otype = nil

  totalCol = Array.new

  res.each do |rec|
    n += 1
    ord = sprintf("%03d", n)
    f1 = rec[0]
    f2 = rec[1]
    f3 = rec[2]
    f4 = rec[3]
    f5 = rec[4].to_s # f1hcode
    otype = getOtype(f5)
    if (acode.to_s.length == 4)
      acodex = getAmpCode(f5)
      next if (acodex != acode)
    end 

    f6 = rec[5].to_s.to_i
    f7 = rec[6].to_s.to_i
    f8 = rec[7].to_s.to_i
    f9 = rec[8].to_s.to_i
    f10 = rec[9].to_s.to_i
    f11 = rec[10].to_s.to_i
    f12 = rec[11].to_s.to_i
    f13 = rec[12].to_s.to_i
    f14 = rec[13].to_s.to_i
    f15 = rec[14].to_s.to_i
    f16 = rec[15].to_s.to_i
    f17 = rec[16].to_s.to_i
    f18 = rec[17].to_s.to_i
    f19 = rec[18].to_s.to_i
    f20 = rec[19].to_s.to_i
    f21 = rec[20].to_s.to_i
    f22 = rec[21].to_s.to_i
    f23 = rec[22].to_s.to_i
    f24 = rec[23].to_s.to_i
    f25 = rec[24].to_s.to_i
    f26 = rec[25].to_s.to_i
    f27 = rec[26].to_s.to_i
    f28 = rec[27].to_s.to_i
    f29 = rec[28].to_s.to_i
    f30 = rec[29].to_s.to_i
    f31 = rec[30].to_s.to_i
    f32 = rec[31].to_s.to_i
    f33 = rec[32].to_s.to_i
    f34 = rec[33].to_s.to_i
    f35 = rec[34].to_s.to_i
    f36 = rec[35].to_s.to_i
    f37 = rec[36].to_s.to_i
    f38 = rec[37].to_s.to_i
    f39 = rec[38].to_s.to_i
    f40 = rec[39].to_s.to_i
    f41 = rec[40].to_s.to_i
    f42 = rec[41].to_s.to_i
    f43 = rec[42].to_s.to_i
    f44 = rec[43].to_s.to_i
    f45 = rec[44].to_s.to_i
    f46 = rec[45].to_s.to_i
    f47 = rec[46].to_s.to_i
    f48 = rec[47].to_s.to_i
    f49 = rec[48].to_s.to_i
    f50 = rec[49].to_s.to_i
    f51 = rec[50].to_s.to_i
    f52 = rec[51].to_s.to_i
    f53 = rec[52].to_s.to_i
    f54 = rec[53].to_s.to_i
    f55 = rec[54].to_s.to_i
    f56 = rec[55].to_s.to_i
    f57 = rec[56].to_s.to_i
    f58 = rec[57].to_s.to_i
    f59 = rec[58].to_s.to_i
    f60 = rec[59].to_s.to_i
    f61 = rec[60].to_s.to_i
    f62 = rec[61].to_s.to_i
    f63 = rec[62].to_s.to_i
    f64 = rec[63].to_s.to_i
    f65 = rec[64].to_s.to_i
    f66 = rec[65].to_s.to_i
    f67 = rec[66].to_s.to_i
    f68 = rec[67].to_s.to_i
    f69 = rec[68].to_s.to_i
    f70 = rec[69].to_s.to_i
    f71 = rec[70].to_s.to_i
    f72 = rec[71].to_s.to_i
    f73 = rec[72].to_s.to_i
    f74 = rec[73].to_s.to_i
    f75 = rec[74].to_s.to_i
    f76 = rec[75].to_s.to_i
    f77 = rec[76].to_s.to_i
    f78 = rec[77].to_s.to_i
    f79 = rec[78].to_s.to_i
    f80 = rec[79].to_s.to_i
    f81 = rec[80].to_s.to_i
    f82 = rec[81].to_s.to_i
    f83 = rec[82].to_s.to_i
    f84 = rec[83].to_s.to_i
    f85 = rec[84].to_s.to_i
    f86 = rec[85].to_s.to_i
    f87 = rec[86].to_s.to_i
    f88 = rec[87].to_s.to_i
    f89 = rec[88].to_s.to_i
    f90 = rec[89].to_s.to_i
    f91 = rec[90].to_s.to_i
    f92 = rec[91].to_s.to_i
    f93 = rec[92].to_s.to_i
    f94 = rec[93].to_s.to_i
    f95 = rec[94].to_s.to_i
    f96 = rec[95].to_s.to_i
    f97 = rec[96].to_s.to_i
    f98 = rec[97].to_s.to_i
    f99 = rec[98].to_s.to_i
    f100 = rec[99].to_s.to_i
    f101 = rec[100].to_s.to_i
    f102 = rec[101].to_s.to_i
    f103 = rec[102].to_s.to_i
    f104 = rec[103].to_s.to_i
    f105 = rec[104].to_s.to_i
    f106 = rec[105].to_s.to_i
    f107 = rec[106].to_s.to_i
    f108 = rec[107].to_s.to_i
    f109 = rec[108].to_s.to_i
    f110 = rec[109].to_s.to_i
    f111 = rec[110].to_s.to_i
    f112 = rec[111].to_s.to_i
    f113 = rec[112].to_s.to_i
    f114 = rec[113].to_s.to_i
    f115 = rec[114].to_s.to_i
    f116 = rec[115].to_s.to_i
    f117 = rec[116].to_s.to_i
    f118 = rec[117].to_s.to_i
    f119 = rec[118].to_s.to_i
    f120 = rec[119].to_s.to_i
    f121 = rec[120].to_s.to_i
    f122 = rec[121].to_s.to_i
    f123 = rec[122].to_s.to_i
    f124 = rec[123].to_s.to_i
    f125 = rec[124].to_s.to_i
    f126 = rec[125].to_s.to_i
    f127 = rec[126].to_s.to_i
    f128 = rec[127].to_s.to_i
    f129 = rec[128].to_s.to_i
    f130 = rec[129].to_s.to_i
    f131 = rec[130].to_s.to_i
    f132 = rec[131].to_s.to_i
    f133 = rec[132].to_s.to_i
    f134 = rec[133].to_s.to_i
    f135 = rec[134].to_s.to_i
    f136 = rec[135].to_s.to_i
    f137 = rec[136].to_s.to_i
    f138 = rec[137].to_s.to_i
    f139 = rec[138].to_s.to_i
    f140 = rec[139].to_s.to_i
    f141 = rec[140].to_s.to_i
    f142 = rec[141].to_s.to_i
    f143 = rec[142].to_s.to_i
    f144 = rec[143].to_s.to_i
    f145 = rec[144].to_s.to_i
    f146 = rec[145].to_s.to_i
    f147 = rec[146].to_s.to_i
    f148 = rec[147].to_s.to_i
    f149 = rec[148].to_s.to_i
    f150 = rec[149].to_s.to_i
    f151 = rec[150].to_s.to_i
    f152 = rec[151].to_s.to_i
    f153 = rec[152].to_s.to_i
    f154 = rec[153].to_s.to_i
    f155 = rec[154].to_s.to_i
    f156 = rec[155].to_s.to_i
    f157 = rec[156].to_s.to_i
    f158 = rec[157].to_s.to_i
    f159 = rec[158].to_s.to_i
    f160 = rec[159].to_s.to_i
    f161 = rec[160].to_s.to_i
    f162 = rec[161].to_s.to_i
    f163 = rec[162].to_s.to_i
    f164 = rec[163].to_s.to_i
    f165 = rec[164].to_s.to_i

    if (year < '52')
      f166 = rec[165].to_s.to_i
      f167 = rec[166].to_s.to_i
      f168 = rec[167].to_s.to_i
      f169 = rec[168].to_s.to_i
      f170 = rec[169].to_s.to_i
      f171 = rec[170].to_s.to_i
      f172 = rec[171].to_s.to_i
      f173 = rec[172].to_s.to_i
    end

    f1to4x = 0
    max = 0
    if (year < '52')
      max = 172
    else
      max = 164
    end
    (5..max).each do |x|
      f1to4x += rec[x].to_s.to_i
      if (totalCol[x].nil?)
        totalCol[x] = 0
      end
      totalCol[x] += rec[x].to_s.to_i
    end

    h1 = "#{h1}#{ord},#{f1},#{f2},#{f3},#{f4},#{otype},#{f5},#{f6},#{f7},#{f8},#{f9},#{f10},#{f11},#{f12},#{f13},#{f14},#{f15},#{f16},#{f17},#{f18},#{f19},#{f20},#{f21},#{f22},#{f23},#{f24},#{f25},#{f26},#{f27},#{f28},#{f29},#{f30},#{f31},#{f32},#{f33},#{f34},#{f35},#{f36},#{f37},#{f38},#{f39},#{f40},#{f41},#{f42},#{f43},#{f44},#{f45},#{f46},#{f47},#{f48},#{f49},#{f50},#{f51},#{f52},#{f53},#{f54},#{f55},#{f56},#{f57},#{f58},#{f59},#{f60},#{f61},#{f62},#{f63},#{f64},#{f65},#{f66},#{f67},#{f68},#{f69},#{f70},#{f71},#{f72},#{f73},#{f74},#{f75},#{f76},#{f77},#{f78},#{f79},#{f80},#{f81},#{f82},#{f83},#{f84},#{f85},#{f86},#{f87},#{f88},#{f89},#{f90},#{f91},#{f92},#{f93},#{f94},#{f95},#{f96},#{f97},#{f98},#{f99},#{f100},#{f101},#{f102},#{f103},#{f104},#{f105},#{f106},#{f107},#{f108},#{f109},#{f110},#{f111},#{f112},#{f113},#{f114},#{f115},#{f116},#{f117},#{f118},#{f119},#{f120},#{f121},#{f122},#{f123},#{f124},#{f125},#{f126},#{f127},#{f128},#{f129},#{f130},#{f131},#{f132},#{f133},#{f134},#{f135},#{f136},#{f137},#{f138},#{f139},#{f140},#{f141},#{f142},#{f143},#{f144},#{f145},#{f146},#{f147},#{f148},#{f149},#{f150},#{f151},#{f152},#{f153},#{f154},#{f155},#{f156},#{f157},#{f158},#{f159},#{f160},#{f161},#{f162},#{f163},#{f164},#{f165}"
    if (year < '52')
      h1 += ",#{f166},#{f167},#{f168},#{f169},#{f170},#{f171},#{f172},#{f173}"
    end

    h1 += ",#{f1to4x}\n"

    h2 = "#{h2}<tr><th>#{ord}</th><th>#{f1}</th><th>#{f2}</th><th>#{f3}</th><td>#{f4}</td><th>#{otype}</th><th>#{f5}</th>"
    h2 += (f6 > 0) ? "<th class='hili'>#{f6}</th>" : "<th>#{f6}</th>"
    h2 += (f7 > 0) ? "<th class='hili'>#{f7}</th>" : "<th>#{f7}</th>"
    h2 += (f8 > 0) ? "<th class='hili'>#{f8}</th>" : "<th>#{f8}</th>"
    h2 += (f9 > 0) ? "<th class='hili'>#{f9}</th>" : "<th>#{f9}</th>"
    h2 += (f10 > 0) ? "<th class='hili'>#{f10}</th>" : "<th>#{f10}</th>"
    h2 += (f11 > 0) ? "<th class='hili'>#{f11}</th>" : "<th>#{f11}</th>"
    h2 += (f12 > 0) ? "<th class='hili'>#{f12}</th>" : "<th>#{f12}</th>"
    h2 += (f13 > 0) ? "<th class='hili'>#{f13}</th>" : "<th>#{f13}</th>"
    h2 += (f14 > 0) ? "<th class='hili'>#{f14}</th>" : "<th>#{f14}</th>"
    h2 += (f15 > 0) ? "<th class='hili'>#{f15}</th>" : "<th>#{f15}</th>"
    h2 += (f16 > 0) ? "<th class='hili'>#{f16}</th>" : "<th>#{f16}</th>"
    h2 += (f17 > 0) ? "<th class='hili'>#{f17}</th>" : "<th>#{f17}</th>"
    h2 += (f18 > 0) ? "<th class='hili'>#{f18}</th>" : "<th>#{f18}</th>"
    h2 += (f19 > 0) ? "<th class='hili'>#{f19}</th>" : "<th>#{f19}</th>"
    h2 += (f20 > 0) ? "<th class='hili'>#{f20}</th>" : "<th>#{f20}</th>"
    h2 += (f21 > 0) ? "<th class='hili'>#{f21}</th>" : "<th>#{f21}</th>"
    h2 += (f22 > 0) ? "<th class='hili'>#{f22}</th>" : "<th>#{f22}</th>"
    h2 += (f23 > 0) ? "<th class='hili'>#{f23}</th>" : "<th>#{f23}</th>"
    h2 += (f24 > 0) ? "<th class='hili'>#{f24}</th>" : "<th>#{f24}</th>"
    h2 += (f25 > 0) ? "<th class='hili'>#{f25}</th>" : "<th>#{f25}</th>"
    h2 += (f26 > 0) ? "<th class='hili'>#{f26}</th>" : "<th>#{f26}</th>"
    h2 += (f27 > 0) ? "<th class='hili'>#{f27}</th>" : "<th>#{f27}</th>"
    h2 += (f28 > 0) ? "<th class='hili'>#{f28}</th>" : "<th>#{f28}</th>"
    h2 += (f29 > 0) ? "<th class='hili'>#{f29}</th>" : "<th>#{f29}</th>"
    h2 += (f30 > 0) ? "<th class='hili'>#{f30}</th>" : "<th>#{f30}</th>"
    h2 += (f31 > 0) ? "<th class='hili'>#{f31}</th>" : "<th>#{f31}</th>"
    h2 += (f32 > 0) ? "<th class='hili'>#{f32}</th>" : "<th>#{f32}</th>"
    h2 += (f33 > 0) ? "<th class='hili'>#{f33}</th>" : "<th>#{f33}</th>"
    h2 += (f34 > 0) ? "<th class='hili'>#{f34}</th>" : "<th>#{f34}</th>"
    h2 += (f35 > 0) ? "<th class='hili'>#{f35}</th>" : "<th>#{f35}</th>"
    h2 += (f36 > 0) ? "<th class='hili'>#{f36}</th>" : "<th>#{f36}</th>"
    h2 += (f37 > 0) ? "<th class='hili'>#{f37}</th>" : "<th>#{f37}</th>"
    h2 += (f38 > 0) ? "<th class='hili'>#{f38}</th>" : "<th>#{f38}</th>"
    h2 += (f39 > 0) ? "<th class='hili'>#{f39}</th>" : "<th>#{f39}</th>"
    h2 += (f40 > 0) ? "<th class='hili'>#{f40}</th>" : "<th>#{f40}</th>"
    h2 += (f41 > 0) ? "<th class='hili'>#{f41}</th>" : "<th>#{f41}</th>"
    h2 += (f42 > 0) ? "<th class='hili'>#{f42}</th>" : "<th>#{f42}</th>"
    h2 += (f43 > 0) ? "<th class='hili'>#{f43}</th>" : "<th>#{f43}</th>"
    h2 += (f44 > 0) ? "<th class='hili'>#{f44}</th>" : "<th>#{f44}</th>"
    h2 += (f45 > 0) ? "<th class='hili'>#{f45}</th>" : "<th>#{f45}</th>"
    h2 += (f46 > 0) ? "<th class='hili'>#{f46}</th>" : "<th>#{f46}</th>"
    h2 += (f47 > 0) ? "<th class='hili'>#{f47}</th>" : "<th>#{f47}</th>"
    h2 += (f48 > 0) ? "<th class='hili'>#{f48}</th>" : "<th>#{f48}</th>"
    h2 += (f49 > 0) ? "<th class='hili'>#{f49}</th>" : "<th>#{f49}</th>"
    h2 += (f50 > 0) ? "<th class='hili'>#{f50}</th>" : "<th>#{f50}</th>"
    h2 += (f51 > 0) ? "<th class='hili'>#{f51}</th>" : "<th>#{f51}</th>"
    h2 += (f52 > 0) ? "<th class='hili'>#{f52}</th>" : "<th>#{f52}</th>"
    h2 += (f53 > 0) ? "<th class='hili'>#{f53}</th>" : "<th>#{f53}</th>"
    h2 += (f54 > 0) ? "<th class='hili'>#{f54}</th>" : "<th>#{f54}</th>"
    h2 += (f55 > 0) ? "<th class='hili'>#{f55}</th>" : "<th>#{f55}</th>"
    h2 += (f56 > 0) ? "<th class='hili'>#{f56}</th>" : "<th>#{f56}</th>"
    h2 += (f57 > 0) ? "<th class='hili'>#{f57}</th>" : "<th>#{f57}</th>"
    h2 += (f58 > 0) ? "<th class='hili'>#{f58}</th>" : "<th>#{f58}</th>"
    h2 += (f59 > 0) ? "<th class='hili'>#{f59}</th>" : "<th>#{f59}</th>"
    h2 += (f60 > 0) ? "<th class='hili'>#{f60}</th>" : "<th>#{f60}</th>"
    h2 += (f61 > 0) ? "<th class='hili'>#{f61}</th>" : "<th>#{f61}</th>"
    h2 += (f62 > 0) ? "<th class='hili'>#{f62}</th>" : "<th>#{f62}</th>"
    h2 += (f63 > 0) ? "<th class='hili'>#{f63}</th>" : "<th>#{f63}</th>"
    h2 += (f64 > 0) ? "<th class='hili'>#{f64}</th>" : "<th>#{f64}</th>"
    h2 += (f65 > 0) ? "<th class='hili'>#{f65}</th>" : "<th>#{f65}</th>"
    h2 += (f66 > 0) ? "<th class='hili'>#{f66}</th>" : "<th>#{f66}</th>"
    h2 += (f67 > 0) ? "<th class='hili'>#{f67}</th>" : "<th>#{f67}</th>"
    h2 += (f68 > 0) ? "<th class='hili'>#{f68}</th>" : "<th>#{f68}</th>"
    h2 += (f69 > 0) ? "<th class='hili'>#{f69}</th>" : "<th>#{f69}</th>"
    h2 += (f70 > 0) ? "<th class='hili'>#{f70}</th>" : "<th>#{f70}</th>"
    h2 += (f71 > 0) ? "<th class='hili'>#{f71}</th>" : "<th>#{f71}</th>"
    h2 += (f72 > 0) ? "<th class='hili'>#{f72}</th>" : "<th>#{f72}</th>"
    h2 += (f73 > 0) ? "<th class='hili'>#{f73}</th>" : "<th>#{f73}</th>"
    h2 += (f74 > 0) ? "<th class='hili'>#{f74}</th>" : "<th>#{f74}</th>"
    h2 += (f75 > 0) ? "<th class='hili'>#{f75}</th>" : "<th>#{f75}</th>"
    h2 += (f76 > 0) ? "<th class='hili'>#{f76}</th>" : "<th>#{f76}</th>"
    h2 += (f77 > 0) ? "<th class='hili'>#{f77}</th>" : "<th>#{f77}</th>"
    h2 += (f78 > 0) ? "<th class='hili'>#{f78}</th>" : "<th>#{f78}</th>"
    h2 += (f79 > 0) ? "<th class='hili'>#{f79}</th>" : "<th>#{f79}</th>"
    h2 += (f80 > 0) ? "<th class='hili'>#{f80}</th>" : "<th>#{f80}</th>"
    h2 += (f81 > 0) ? "<th class='hili'>#{f81}</th>" : "<th>#{f81}</th>"
    h2 += (f82 > 0) ? "<th class='hili'>#{f82}</th>" : "<th>#{f82}</th>"
    h2 += (f83 > 0) ? "<th class='hili'>#{f83}</th>" : "<th>#{f83}</th>"
    h2 += (f84 > 0) ? "<th class='hili'>#{f84}</th>" : "<th>#{f84}</th>"
    h2 += (f85 > 0) ? "<th class='hili'>#{f85}</th>" : "<th>#{f85}</th>"
    h2 += (f86 > 0) ? "<th class='hili'>#{f86}</th>" : "<th>#{f86}</th>"
    h2 += (f87 > 0) ? "<th class='hili'>#{f87}</th>" : "<th>#{f87}</th>"
    h2 += (f88 > 0) ? "<th class='hili'>#{f88}</th>" : "<th>#{f88}</th>"
    h2 += (f89 > 0) ? "<th class='hili'>#{f89}</th>" : "<th>#{f89}</th>"
    h2 += (f90 > 0) ? "<th class='hili'>#{f90}</th>" : "<th>#{f90}</th>"
    h2 += (f91 > 0) ? "<th class='hili'>#{f91}</th>" : "<th>#{f91}</th>"
    h2 += (f92 > 0) ? "<th class='hili'>#{f92}</th>" : "<th>#{f92}</th>"
    h2 += (f93 > 0) ? "<th class='hili'>#{f93}</th>" : "<th>#{f93}</th>"
    h2 += (f94 > 0) ? "<th class='hili'>#{f94}</th>" : "<th>#{f94}</th>"
    h2 += (f95 > 0) ? "<th class='hili'>#{f95}</th>" : "<th>#{f95}</th>"
    h2 += (f96 > 0) ? "<th class='hili'>#{f96}</th>" : "<th>#{f96}</th>"
    h2 += (f97 > 0) ? "<th class='hili'>#{f97}</th>" : "<th>#{f97}</th>"
    h2 += (f98 > 0) ? "<th class='hili'>#{f98}</th>" : "<th>#{f98}</th>"
    h2 += (f99 > 0) ? "<th class='hili'>#{f99}</th>" : "<th>#{f99}</th>"
    h2 += (f100 > 0) ? "<th class='hili'>#{f100}</th>" : "<th>#{f100}</th>"
    h2 += (f101 > 0) ? "<th class='hili'>#{f101}</th>" : "<th>#{f101}</th>"
    h2 += (f102 > 0) ? "<th class='hili'>#{f102}</th>" : "<th>#{f102}</th>"
    h2 += (f103 > 0) ? "<th class='hili'>#{f103}</th>" : "<th>#{f103}</th>"
    h2 += (f104 > 0) ? "<th class='hili'>#{f104}</th>" : "<th>#{f104}</th>"
    h2 += (f105 > 0) ? "<th class='hili'>#{f105}</th>" : "<th>#{f105}</th>"
    h2 += (f106 > 0) ? "<th class='hili'>#{f106}</th>" : "<th>#{f106}</th>"
    h2 += (f107 > 0) ? "<th class='hili'>#{f107}</th>" : "<th>#{f107}</th>"
    h2 += (f108 > 0) ? "<th class='hili'>#{f108}</th>" : "<th>#{f108}</th>"
    h2 += (f109 > 0) ? "<th class='hili'>#{f109}</th>" : "<th>#{f109}</th>"
    h2 += (f110 > 0) ? "<th class='hili'>#{f110}</th>" : "<th>#{f110}</th>"
    h2 += (f111 > 0) ? "<th class='hili'>#{f111}</th>" : "<th>#{f111}</th>"
    h2 += (f112 > 0) ? "<th class='hili'>#{f112}</th>" : "<th>#{f112}</th>"
    h2 += (f113 > 0) ? "<th class='hili'>#{f113}</th>" : "<th>#{f113}</th>"
    h2 += (f114 > 0) ? "<th class='hili'>#{f114}</th>" : "<th>#{f114}</th>"
    h2 += (f115 > 0) ? "<th class='hili'>#{f115}</th>" : "<th>#{f115}</th>"
    h2 += (f116 > 0) ? "<th class='hili'>#{f116}</th>" : "<th>#{f116}</th>"
    h2 += (f117 > 0) ? "<th class='hili'>#{f117}</th>" : "<th>#{f117}</th>"
    h2 += (f118 > 0) ? "<th class='hili'>#{f118}</th>" : "<th>#{f118}</th>"
    h2 += (f119 > 0) ? "<th class='hili'>#{f119}</th>" : "<th>#{f119}</th>"
    h2 += (f120 > 0) ? "<th class='hili'>#{f120}</th>" : "<th>#{f120}</th>"
    h2 += (f121 > 0) ? "<th class='hili'>#{f121}</th>" : "<th>#{f121}</th>"
    h2 += (f122 > 0) ? "<th class='hili'>#{f122}</th>" : "<th>#{f122}</th>"
    h2 += (f123 > 0) ? "<th class='hili'>#{f123}</th>" : "<th>#{f123}</th>"
    h2 += (f124 > 0) ? "<th class='hili'>#{f124}</th>" : "<th>#{f124}</th>"
    h2 += (f125 > 0) ? "<th class='hili'>#{f125}</th>" : "<th>#{f125}</th>"
    h2 += (f126 > 0) ? "<th class='hili'>#{f126}</th>" : "<th>#{f126}</th>"
    h2 += (f127 > 0) ? "<th class='hili'>#{f127}</th>" : "<th>#{f127}</th>"
    h2 += (f128 > 0) ? "<th class='hili'>#{f128}</th>" : "<th>#{f128}</th>"
    h2 += (f129 > 0) ? "<th class='hili'>#{f129}</th>" : "<th>#{f129}</th>"
    h2 += (f130 > 0) ? "<th class='hili'>#{f130}</th>" : "<th>#{f130}</th>"
    h2 += (f131 > 0) ? "<th class='hili'>#{f131}</th>" : "<th>#{f131}</th>"
    h2 += (f132 > 0) ? "<th class='hili'>#{f132}</th>" : "<th>#{f132}</th>"
    h2 += (f133 > 0) ? "<th class='hili'>#{f133}</th>" : "<th>#{f133}</th>"
    h2 += (f134 > 0) ? "<th class='hili'>#{f134}</th>" : "<th>#{f134}</th>"
    h2 += (f135 > 0) ? "<th class='hili'>#{f135}</th>" : "<th>#{f135}</th>"
    h2 += (f136 > 0) ? "<th class='hili'>#{f136}</th>" : "<th>#{f136}</th>"
    h2 += (f137 > 0) ? "<th class='hili'>#{f137}</th>" : "<th>#{f137}</th>"
    h2 += (f138 > 0) ? "<th class='hili'>#{f138}</th>" : "<th>#{f138}</th>"
    h2 += (f139 > 0) ? "<th class='hili'>#{f139}</th>" : "<th>#{f139}</th>"
    h2 += (f140 > 0) ? "<th class='hili'>#{f140}</th>" : "<th>#{f140}</th>"
    h2 += (f141 > 0) ? "<th class='hili'>#{f141}</th>" : "<th>#{f141}</th>"
    h2 += (f142 > 0) ? "<th class='hili'>#{f142}</th>" : "<th>#{f142}</th>"
    h2 += (f143 > 0) ? "<th class='hili'>#{f143}</th>" : "<th>#{f143}</th>"
    h2 += (f144 > 0) ? "<th class='hili'>#{f144}</th>" : "<th>#{f144}</th>"
    h2 += (f145 > 0) ? "<th class='hili'>#{f145}</th>" : "<th>#{f145}</th>"
    h2 += (f146 > 0) ? "<th class='hili'>#{f146}</th>" : "<th>#{f146}</th>"
    h2 += (f147 > 0) ? "<th class='hili'>#{f147}</th>" : "<th>#{f147}</th>"
    h2 += (f148 > 0) ? "<th class='hili'>#{f148}</th>" : "<th>#{f148}</th>"
    h2 += (f149 > 0) ? "<th class='hili'>#{f149}</th>" : "<th>#{f149}</th>"
    h2 += (f150 > 0) ? "<th class='hili'>#{f150}</th>" : "<th>#{f150}</th>"
    h2 += (f151 > 0) ? "<th class='hili'>#{f151}</th>" : "<th>#{f151}</th>"
    h2 += (f152 > 0) ? "<th class='hili'>#{f152}</th>" : "<th>#{f152}</th>"
    h2 += (f153 > 0) ? "<th class='hili'>#{f153}</th>" : "<th>#{f153}</th>"
    h2 += (f154 > 0) ? "<th class='hili'>#{f154}</th>" : "<th>#{f154}</th>"
    h2 += (f155 > 0) ? "<th class='hili'>#{f155}</th>" : "<th>#{f155}</th>"
    h2 += (f156 > 0) ? "<th class='hili'>#{f156}</th>" : "<th>#{f156}</th>"
    h2 += (f157 > 0) ? "<th class='hili'>#{f157}</th>" : "<th>#{f157}</th>"
    h2 += (f158 > 0) ? "<th class='hili'>#{f158}</th>" : "<th>#{f158}</th>"
    h2 += (f159 > 0) ? "<th class='hili'>#{f159}</th>" : "<th>#{f159}</th>"
    h2 += (f160 > 0) ? "<th class='hili'>#{f160}</th>" : "<th>#{f160}</th>"
    h2 += (f161 > 0) ? "<th class='hili'>#{f161}</th>" : "<th>#{f161}</th>"
    h2 += (f162 > 0) ? "<th class='hili'>#{f162}</th>" : "<th>#{f162}</th>"
    h2 += (f163 > 0) ? "<th class='hili'>#{f163}</th>" : "<th>#{f163}</th>"
    h2 += (f164 > 0) ? "<th class='hili'>#{f164}</th>" : "<th>#{f164}</th>"
    h2 += (f165 > 0) ? "<th class='hili'>#{f165}</th>" : "<th>#{f165}</th>"

    if (year < '52')
      h2 += (f166 > 0) ? "<th class='hili'>#{f166}</th>" : "<th>#{f166}</th>"
      h2 += (f167 > 0) ? "<th class='hili'>#{f167}</th>" : "<th>#{f167}</th>"
      h2 += (f168 > 0) ? "<th class='hili'>#{f168}</th>" : "<th>#{f168}</th>"
      h2 += (f169 > 0) ? "<th class='hili'>#{f169}</th>" : "<th>#{f169}</th>"
      h2 += (f170 > 0) ? "<th class='hili'>#{f170}</th>" : "<th>#{f170}</th>"
      h2 += (f171 > 0) ? "<th class='hili'>#{f171}</th>" : "<th>#{f171}</th>"
      h2 += (f172 > 0) ? "<th class='hili'>#{f172}</th>" : "<th>#{f172}</th>"
      h2 += (f173 > 0) ? "<th class='hili'>#{f173}</th>" : "<th>#{f173}</th>"
    end

    h2 += (f1to4x > 0) ? "<th class='hili'>#{f1to4x}</th>" : "<th>#{f1to4x}</th>"
    h2 += "</tr>\n"
  end

  h2 = "#{h2}<tr bgcolor='yellow'>"
  h2 += "<th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th align='right'>Total</th>"
  h2 += "<th>&nbsp;</th><th>&nbsp;</th>"

  gTotal = 0
  max = 0
  if (year < '52')
    max = 172
  else
    max = 164
  end
  (5..max).each do |x|
    gTotal += totalCol[x].to_s.to_i
    h2 += "<th><font color='red'>#{totalCol[x]}</font></th>"
  end    

  h2 += "<th><font color='red'>#{gTotal}</font></th>"
  h2 += "</tr>\n"

  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def getForm5(year,pcode,acode,type)
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year}")
  sql = "SELECT * FROM form5 "
  if (acode.length == 4) # request from Amphoe
    if (acode =~ /01$/)
      sql += "WHERE (f5pcode='#{acode}' OR f5pcode='#{pcode}') "
    else
      sql += "WHERE f5pcode='#{acode}' "
    end
  else
    sql += "WHERE f5pcode='#{pcode}' "
  end
  sql += "ORDER BY f5hcode"
  res = con.exec(sql)
  con.close

  h1 = h2 = nil
  n = 0
  ord = otype = nil
  totalCol = Array.new

  found = res.num_tuples
  if (found > 0)
    res.each do |rec|
      n += 1
      ord = sprintf("%03d", n)
      f1 = rec[0]
      f2 = rec[1]
      f3 = rec[2]
      f4 = rec[3]
      f5 = rec[4].to_s
      otype = getOtype(f5)
      if (acode.to_s.length == 4)
        acodex = getAmpCode(f5)
        next if (acodex != acode)
      end
      f6 = rec[5].to_s.to_i
      f7 = rec[6].to_s.to_i
      f8 = rec[7].to_s.to_i
      f9 = rec[8].to_s.to_i
      f10 = rec[9].to_s.to_i
      f11 = rec[10].to_s.to_i
      f12 = rec[11].to_s.to_i
      f13 = rec[12].to_s.to_i
      f14 = rec[13].to_s.to_i
      f15 = rec[14].to_s.to_i
      f16 = rec[15].to_s.to_i
      f17 = rec[16].to_s.to_i
      f18 = rec[17].to_s.to_i
      f19 = rec[18].to_s.to_i
      f20 = rec[19].to_s.to_i
      f21 = rec[20].to_s.to_i
      f22 = rec[21].to_s.to_i
      f23 = rec[22].to_s.to_i
      f24 = rec[23].to_s.to_i
      f25 = rec[24].to_s.to_i
      f26 = rec[25].to_s.to_i
      f27 = rec[26].to_s.to_i
      f28 = rec[27].to_s.to_i
      f29 = rec[28].to_s.to_i
      f30 = rec[29].to_s.to_i
      f31 = rec[30].to_s.to_i
      f32 = rec[31].to_s.to_i
      f33 = rec[32].to_s.to_i
      f34 = rec[33].to_s.to_i
      f35 = rec[34].to_s.to_i
      f36 = rec[35].to_s.to_i
      f37 = rec[36].to_s.to_i
      f38 = rec[37].to_s.to_i
      f39 = rec[38].to_s.to_i
      f40 = rec[39].to_s.to_i
      f41 = rec[40].to_s.to_i
      f42 = rec[41].to_s.to_i
      f43 = rec[42].to_s.to_i
      f44 = rec[43].to_s.to_i
      f45 = rec[44].to_s.to_i
      f46 = rec[45].to_s.to_i
      f47 = rec[46].to_s.to_i
      f48 = rec[47].to_s.to_i
      f49 = rec[48].to_s.to_i
      f50 = rec[49].to_s.to_i
      f51 = rec[50].to_s.to_i
      f52 = rec[51].to_s.to_i
      f53 = rec[52].to_s.to_i
      f54 = rec[53].to_s.to_i
      f55 = rec[54].to_s.to_i
      f56 = rec[55].to_s.to_i
      f57 = rec[56].to_s.to_i
      f58 = rec[57].to_s.to_i
      f59 = rec[58].to_s.to_i
      f60 = rec[59].to_s.to_i
      f61 = rec[60].to_s.to_i
      f62 = rec[61].to_s.to_i
      f63 = rec[62].to_s.to_i
      f64 = rec[63].to_s.to_i
      f65 = rec[64].to_s.to_i
      f66 = rec[65].to_s.to_i
      f67 = rec[66].to_s.to_i
      f68 = rec[67].to_s.to_i
      f69 = rec[68].to_s.to_i
      f70 = rec[69].to_s.to_i
      f71 = rec[70].to_s.to_i
      f72 = rec[71].to_s.to_i
      f73 = rec[72].to_s.to_i
      f74 = rec[73].to_s.to_i
      f75 = rec[74].to_s.to_i
      f76 = rec[75].to_s.to_i
      f77 = rec[76].to_s.to_i
      f78 = rec[77].to_s.to_i
      f79 = rec[78].to_s.to_i
      f80 = rec[79].to_s.to_i
      f81 = rec[80].to_s.to_i
      f82 = rec[81].to_s.to_i
      f83 = rec[82].to_s.to_i
      f84 = rec[83].to_s.to_i
      f85 = rec[84].to_s.to_i
      f86 = rec[85].to_s.to_i
      f87 = rec[86].to_s.to_i
      f88 = rec[87].to_s.to_i
      f89 = rec[88].to_s.to_i
      f90 = rec[89].to_s.to_i
      f91 = rec[90].to_s.to_i
      f92 = rec[91].to_s.to_i
      f93 = rec[92].to_s.to_i
      f94 = rec[93].to_s.to_i
      f95 = rec[94].to_s.to_i
      f96 = rec[95].to_s.to_i
      f97 = rec[96].to_s.to_i
      f98 = rec[97].to_s.to_i
      f99 = rec[98].to_s.to_i
      f100 = rec[99].to_s.to_i
      f101 = rec[100].to_s.to_i
      f102 = rec[101].to_s.to_i
      f103 = rec[102].to_s.to_i
      f104 = rec[103].to_s.to_i
      f105 = rec[104].to_s.to_i
      f106 = rec[105].to_s.to_i
      f107 = rec[106].to_s.to_i
      f108 = rec[107].to_s.to_i
      f109 = rec[108].to_s.to_i
      f110 = rec[109].to_s.to_i
      f111 = rec[110].to_s.to_i
      f112 = rec[111].to_s.to_i
      f113 = rec[112].to_s.to_i
      f114 = rec[113].to_s.to_i
      f115 = rec[114].to_s.to_i
      f116 = rec[115].to_s.to_i
      f117 = rec[116].to_s.to_i
      f118 = rec[117].to_s.to_i
      f119 = rec[118].to_s.to_i
      f120 = rec[119].to_s.to_i
      f121 = rec[120].to_s.to_i
      f122 = rec[121].to_s.to_i
      f123 = rec[122].to_s.to_i
      f124 = rec[123].to_s.to_i
      f125 = rec[124].to_s.to_i
      f126 = rec[125].to_s.to_i
      f127 = rec[126].to_s.to_i
      f128 = rec[127].to_s.to_i
      f129 = rec[128].to_s.to_i
      f130 = rec[129].to_s.to_i
      f131 = rec[130].to_s.to_i
      f132 = rec[131].to_s.to_i
      f133 = rec[132].to_s.to_i
      f134 = rec[133].to_s.to_i
      f135 = rec[134].to_s.to_i
      f136 = rec[135].to_s.to_i
      f137 = rec[136].to_s.to_i
      f138 = rec[137].to_s.to_i
      f139 = rec[138].to_s.to_i
      f140 = rec[139].to_s.to_i
      f141 = rec[140].to_s.to_i
      f142 = rec[141].to_s.to_i
      f143 = rec[142].to_s.to_i
      f144 = rec[143].to_s.to_i
      f145 = rec[144].to_s.to_i
      f146 = rec[145].to_s.to_i
      f147 = rec[146].to_s.to_i
      f148 = rec[147].to_s.to_i
      f149 = rec[148].to_s.to_i
      f150 = rec[149].to_s.to_i
      f151 = rec[150].to_s.to_i
      f152 = rec[151].to_s.to_i
      f153 = rec[152].to_s.to_i
      f154 = rec[153].to_s.to_i
      f155 = rec[154].to_s.to_i
      f156 = rec[155].to_s.to_i
      f157 = rec[156].to_s.to_i
      f158 = rec[157].to_s.to_i
      f159 = rec[158].to_s.to_i
      f160 = rec[159].to_s.to_i
      f161 = rec[160].to_s.to_i
      f162 = rec[161].to_s.to_i
      f163 = rec[162].to_s.to_i
      f164 = rec[163].to_s.to_i
      f165 = rec[164].to_s.to_i

      if (year < '52')
        f166 = rec[166].to_s.to_i
        f167 = rec[167].to_s.to_i
        f168 = rec[168].to_s.to_i
        f169 = rec[169].to_s.to_i
        f170 = rec[170].to_s.to_i
        f171 = rec[171].to_s.to_i
        f172 = rec[172].to_s.to_i
        f173 = rec[173].to_s.to_i
      end

      f1to4x = 0
      max = 0
      if (year < '52')
        max = 172
      else
        max = 164
      end
      (5..max).each do |x|
        if (totalCol[x].nil?)
          totalCol[x] = 0
        end
        totalCol[x] += rec[x].to_s.to_i
        f1to4x += rec[x].to_s.to_i
      end

      h1 = "#{h1}#{ord},#{f1},#{f2},#{f3},#{f4},#{otype},#{f5},#{f6},#{f7},#{f8},#{f9},#{f10},#{f11},#{f12},#{f13},#{f14},#{f15},#{f16},#{f17},#{f18},#{f19},#{f20},#{f21},#{f22},#{f23},#{f24},#{f25},#{f26},#{f27},#{f28},#{f29},#{f30},#{f31},#{f32},#{f33},#{f34},#{f35},#{f36},#{f37},#{f38},#{f39},#{f40},#{f41},#{f42},#{f43},#{f44},#{f45},#{f46},#{f47},#{f48},#{f49},#{f50},#{f51},#{f52},#{f53},#{f54},#{f55},#{f56},#{f57},#{f58},#{f59},#{f60},#{f61},#{f62},#{f63},#{f64},#{f65},#{f66},#{f67},#{f68},#{f69},#{f70},#{f71},#{f72},#{f73},#{f74},#{f75},#{f76},#{f77},#{f78},#{f79},#{f80},#{f81},#{f82},#{f83},#{f84},#{f85},#{f86},#{f87},#{f88},#{f89},#{f90},#{f91},#{f92},#{f93},#{f94},#{f95},#{f96},#{f97},#{f98},#{f99},#{f100},#{f101},#{f102},#{f103},#{f104},#{f105},#{f106},#{f107},#{f108},#{f109},#{f110},#{f111},#{f112},#{f113},#{f114},#{f115},#{f116},#{f117},#{f118},#{f119},#{f120},#{f121},#{f122},#{f123},#{f124},#{f125},#{f126},#{f127},#{f128},#{f129},#{f130},#{f131},#{f132},#{f133},#{f134},#{f135},#{f136},#{f137},#{f138},#{f139},#{f140},#{f141},#{f142},#{f143},#{f144},#{f145},#{f146},#{f147},#{f148},#{f149},#{f150},#{f151},#{f152},#{f153},#{f154},#{f155},#{f156},#{f157},#{f158},#{f159},#{f160},#{f161},#{f162},#{f163},#{f164},#{f165},#{f1to4x}\n"

      h2 = "#{h2}<tr bgcolor='#CCCCCC'><th>#{ord}</th><th>#{f1}</th><th>#{f2}</th><th>#{f3}</th><td>#{f4}</td><th>#{otype}</th><th>#{f5}</th>"
      h2 += (f6 > 0) ? "<th class='hili'>#{f6}</th>" : "<th>#{f6}</th>"
      h2 += (f7 > 0) ? "<th class='hili'>#{f7}</th>" : "<th>#{f7}</th>"
      h2 += (f8 > 0) ? "<th class='hili'>#{f8}</th>" : "<th>#{f8}</th>"
      h2 += (f9 > 0) ? "<th class='hili'>#{f9}</th>" : "<th>#{f9}</th>"
      h2 += (f10 > 0) ? "<th class='hili'>#{f10}</th>" : "<th>#{f10}</th>"
      h2 += (f11 > 0) ? "<th class='hili'>#{f11}</th>" : "<th>#{f11}</th>"
      h2 += (f12 > 0) ? "<th class='hili'>#{f12}</th>" : "<th>#{f12}</th>"
      h2 += (f13 > 0) ? "<th class='hili'>#{f13}</th>" : "<th>#{f13}</th>"
      h2 += (f14 > 0) ? "<th class='hili'>#{f14}</th>" : "<th>#{f14}</th>"
      h2 += (f15 > 0) ? "<th class='hili'>#{f15}</th>" : "<th>#{f15}</th>"
      h2 += (f16 > 0) ? "<th class='hili'>#{f16}</th>" : "<th>#{f16}</th>"
      h2 += (f17 > 0) ? "<th class='hili'>#{f17}</th>" : "<th>#{f17}</th>"
      h2 += (f18 > 0) ? "<th class='hili'>#{f18}</th>" : "<th>#{f18}</th>"
      h2 += (f19 > 0) ? "<th class='hili'>#{f19}</th>" : "<th>#{f19}</th>"
      h2 += (f20 > 0) ? "<th class='hili'>#{f20}</th>" : "<th>#{f20}</th>"
      h2 += (f21 > 0) ? "<th class='hili'>#{f21}</th>" : "<th>#{f21}</th>"
      h2 += (f22 > 0) ? "<th class='hili'>#{f22}</th>" : "<th>#{f22}</th>"
      h2 += (f23 > 0) ? "<th class='hili'>#{f23}</th>" : "<th>#{f23}</th>"
      h2 += (f24 > 0) ? "<th class='hili'>#{f24}</th>" : "<th>#{f24}</th>"
      h2 += (f25 > 0) ? "<th class='hili'>#{f25}</th>" : "<th>#{f25}</th>"
      h2 += (f26 > 0) ? "<th class='hili'>#{f26}</th>" : "<th>#{f26}</th>"
      h2 += (f27 > 0) ? "<th class='hili'>#{f27}</th>" : "<th>#{f27}</th>"
      h2 += (f28 > 0) ? "<th class='hili'>#{f28}</th>" : "<th>#{f28}</th>"
      h2 += (f29 > 0) ? "<th class='hili'>#{f29}</th>" : "<th>#{f29}</th>"
      h2 += (f30 > 0) ? "<th class='hili'>#{f30}</th>" : "<th>#{f30}</th>"
      h2 += (f31 > 0) ? "<th class='hili'>#{f31}</th>" : "<th>#{f31}</th>"
      h2 += (f32 > 0) ? "<th class='hili'>#{f32}</th>" : "<th>#{f32}</th>"
      h2 += (f33 > 0) ? "<th class='hili'>#{f33}</th>" : "<th>#{f33}</th>"
      h2 += (f34 > 0) ? "<th class='hili'>#{f34}</th>" : "<th>#{f34}</th>"
      h2 += (f35 > 0) ? "<th class='hili'>#{f35}</th>" : "<th>#{f35}</th>"
      h2 += (f36 > 0) ? "<th class='hili'>#{f36}</th>" : "<th>#{f36}</th>"
      h2 += (f37 > 0) ? "<th class='hili'>#{f37}</th>" : "<th>#{f37}</th>"
      h2 += (f38 > 0) ? "<th class='hili'>#{f38}</th>" : "<th>#{f38}</th>"
      h2 += (f39 > 0) ? "<th class='hili'>#{f39}</th>" : "<th>#{f39}</th>"
      h2 += (f40 > 0) ? "<th class='hili'>#{f40}</th>" : "<th>#{f40}</th>"
      h2 += (f41 > 0) ? "<th class='hili'>#{f41}</th>" : "<th>#{f41}</th>"
      h2 += (f42 > 0) ? "<th class='hili'>#{f42}</th>" : "<th>#{f42}</th>"
      h2 += (f43 > 0) ? "<th class='hili'>#{f43}</th>" : "<th>#{f43}</th>"
      h2 += (f44 > 0) ? "<th class='hili'>#{f44}</th>" : "<th>#{f44}</th>"
      h2 += (f45 > 0) ? "<th class='hili'>#{f45}</th>" : "<th>#{f45}</th>"
      h2 += (f46 > 0) ? "<th class='hili'>#{f46}</th>" : "<th>#{f46}</th>"
      h2 += (f47 > 0) ? "<th class='hili'>#{f47}</th>" : "<th>#{f47}</th>"
      h2 += (f48 > 0) ? "<th class='hili'>#{f48}</th>" : "<th>#{f48}</th>"
      h2 += (f49 > 0) ? "<th class='hili'>#{f49}</th>" : "<th>#{f49}</th>"
      h2 += (f50 > 0) ? "<th class='hili'>#{f50}</th>" : "<th>#{f50}</th>"
      h2 += (f51 > 0) ? "<th class='hili'>#{f51}</th>" : "<th>#{f51}</th>"
      h2 += (f52 > 0) ? "<th class='hili'>#{f52}</th>" : "<th>#{f52}</th>"
      h2 += (f53 > 0) ? "<th class='hili'>#{f53}</th>" : "<th>#{f53}</th>"
      h2 += (f54 > 0) ? "<th class='hili'>#{f54}</th>" : "<th>#{f54}</th>"
      h2 += (f55 > 0) ? "<th class='hili'>#{f55}</th>" : "<th>#{f55}</th>"
      h2 += (f56 > 0) ? "<th class='hili'>#{f56}</th>" : "<th>#{f56}</th>"
      h2 += (f57 > 0) ? "<th class='hili'>#{f57}</th>" : "<th>#{f57}</th>"
      h2 += (f58 > 0) ? "<th class='hili'>#{f58}</th>" : "<th>#{f58}</th>"
      h2 += (f59 > 0) ? "<th class='hili'>#{f59}</th>" : "<th>#{f59}</th>"
      h2 += (f60 > 0) ? "<th class='hili'>#{f60}</th>" : "<th>#{f60}</th>"
      h2 += (f61 > 0) ? "<th class='hili'>#{f61}</th>" : "<th>#{f61}</th>"
      h2 += (f62 > 0) ? "<th class='hili'>#{f62}</th>" : "<th>#{f62}</th>"
      h2 += (f63 > 0) ? "<th class='hili'>#{f63}</th>" : "<th>#{f63}</th>"
      h2 += (f64 > 0) ? "<th class='hili'>#{f64}</th>" : "<th>#{f64}</th>"
      h2 += (f65 > 0) ? "<th class='hili'>#{f65}</th>" : "<th>#{f65}</th>"
      h2 += (f66 > 0) ? "<th class='hili'>#{f66}</th>" : "<th>#{f66}</th>"
      h2 += (f67 > 0) ? "<th class='hili'>#{f67}</th>" : "<th>#{f67}</th>"
      h2 += (f68 > 0) ? "<th class='hili'>#{f68}</th>" : "<th>#{f68}</th>"
      h2 += (f69 > 0) ? "<th class='hili'>#{f69}</th>" : "<th>#{f69}</th>"
      h2 += (f70 > 0) ? "<th class='hili'>#{f70}</th>" : "<th>#{f70}</th>"
      h2 += (f71 > 0) ? "<th class='hili'>#{f71}</th>" : "<th>#{f71}</th>"
      h2 += (f72 > 0) ? "<th class='hili'>#{f72}</th>" : "<th>#{f72}</th>"
      h2 += (f73 > 0) ? "<th class='hili'>#{f73}</th>" : "<th>#{f73}</th>"
      h2 += (f74 > 0) ? "<th class='hili'>#{f74}</th>" : "<th>#{f74}</th>"
      h2 += (f75 > 0) ? "<th class='hili'>#{f75}</th>" : "<th>#{f75}</th>"
      h2 += (f76 > 0) ? "<th class='hili'>#{f76}</th>" : "<th>#{f76}</th>"
      h2 += (f77 > 0) ? "<th class='hili'>#{f77}</th>" : "<th>#{f77}</th>"
      h2 += (f78 > 0) ? "<th class='hili'>#{f78}</th>" : "<th>#{f78}</th>"
      h2 += (f79 > 0) ? "<th class='hili'>#{f79}</th>" : "<th>#{f79}</th>"
      h2 += (f80 > 0) ? "<th class='hili'>#{f80}</th>" : "<th>#{f80}</th>"
      h2 += (f81 > 0) ? "<th class='hili'>#{f81}</th>" : "<th>#{f81}</th>"
      h2 += (f82 > 0) ? "<th class='hili'>#{f82}</th>" : "<th>#{f82}</th>"
      h2 += (f83 > 0) ? "<th class='hili'>#{f83}</th>" : "<th>#{f83}</th>"
      h2 += (f84 > 0) ? "<th class='hili'>#{f84}</th>" : "<th>#{f84}</th>"
      h2 += (f85 > 0) ? "<th class='hili'>#{f85}</th>" : "<th>#{f85}</th>"
      h2 += (f86 > 0) ? "<th class='hili'>#{f86}</th>" : "<th>#{f86}</th>"
      h2 += (f87 > 0) ? "<th class='hili'>#{f87}</th>" : "<th>#{f87}</th>"
      h2 += (f88 > 0) ? "<th class='hili'>#{f88}</th>" : "<th>#{f88}</th>"
      h2 += (f89 > 0) ? "<th class='hili'>#{f89}</th>" : "<th>#{f89}</th>"
      h2 += (f90 > 0) ? "<th class='hili'>#{f90}</th>" : "<th>#{f90}</th>"
      h2 += (f91 > 0) ? "<th class='hili'>#{f91}</th>" : "<th>#{f91}</th>"
      h2 += (f92 > 0) ? "<th class='hili'>#{f92}</th>" : "<th>#{f92}</th>"
      h2 += (f93 > 0) ? "<th class='hili'>#{f93}</th>" : "<th>#{f93}</th>"
      h2 += (f94 > 0) ? "<th class='hili'>#{f94}</th>" : "<th>#{f94}</th>"
      h2 += (f95 > 0) ? "<th class='hili'>#{f95}</th>" : "<th>#{f95}</th>"
      h2 += (f96 > 0) ? "<th class='hili'>#{f96}</th>" : "<th>#{f96}</th>"
      h2 += (f97 > 0) ? "<th class='hili'>#{f97}</th>" : "<th>#{f97}</th>"
      h2 += (f98 > 0) ? "<th class='hili'>#{f98}</th>" : "<th>#{f98}</th>"
      h2 += (f99 > 0) ? "<th class='hili'>#{f99}</th>" : "<th>#{f99}</th>"
      h2 += (f100 > 0) ? "<th class='hili'>#{f100}</th>" : "<th>#{f100}</th>"
      h2 += (f101 > 0) ? "<th class='hili'>#{f101}</th>" : "<th>#{f101}</th>"
      h2 += (f102 > 0) ? "<th class='hili'>#{f102}</th>" : "<th>#{f102}</th>"
      h2 += (f103 > 0) ? "<th class='hili'>#{f103}</th>" : "<th>#{f103}</th>"
      h2 += (f104 > 0) ? "<th class='hili'>#{f104}</th>" : "<th>#{f104}</th>"
      h2 += (f105 > 0) ? "<th class='hili'>#{f105}</th>" : "<th>#{f105}</th>"
      h2 += (f106 > 0) ? "<th class='hili'>#{f106}</th>" : "<th>#{f106}</th>"
      h2 += (f107 > 0) ? "<th class='hili'>#{f107}</th>" : "<th>#{f107}</th>"
      h2 += (f108 > 0) ? "<th class='hili'>#{f108}</th>" : "<th>#{f108}</th>"
      h2 += (f109 > 0) ? "<th class='hili'>#{f109}</th>" : "<th>#{f109}</th>"
      h2 += (f110 > 0) ? "<th class='hili'>#{f110}</th>" : "<th>#{f110}</th>"
      h2 += (f111 > 0) ? "<th class='hili'>#{f111}</th>" : "<th>#{f111}</th>"
      h2 += (f112 > 0) ? "<th class='hili'>#{f112}</th>" : "<th>#{f112}</th>"
      h2 += (f113 > 0) ? "<th class='hili'>#{f113}</th>" : "<th>#{f113}</th>"
      h2 += (f114 > 0) ? "<th class='hili'>#{f114}</th>" : "<th>#{f114}</th>"
      h2 += (f115 > 0) ? "<th class='hili'>#{f115}</th>" : "<th>#{f115}</th>"
      h2 += (f116 > 0) ? "<th class='hili'>#{f116}</th>" : "<th>#{f116}</th>"
      h2 += (f117 > 0) ? "<th class='hili'>#{f117}</th>" : "<th>#{f117}</th>"
      h2 += (f118 > 0) ? "<th class='hili'>#{f118}</th>" : "<th>#{f118}</th>"
      h2 += (f119 > 0) ? "<th class='hili'>#{f119}</th>" : "<th>#{f119}</th>"
      h2 += (f120 > 0) ? "<th class='hili'>#{f120}</th>" : "<th>#{f120}</th>"
      h2 += (f121 > 0) ? "<th class='hili'>#{f121}</th>" : "<th>#{f121}</th>"
      h2 += (f122 > 0) ? "<th class='hili'>#{f122}</th>" : "<th>#{f122}</th>"
      h2 += (f123 > 0) ? "<th class='hili'>#{f123}</th>" : "<th>#{f123}</th>"
      h2 += (f124 > 0) ? "<th class='hili'>#{f124}</th>" : "<th>#{f124}</th>"
      h2 += (f125 > 0) ? "<th class='hili'>#{f125}</th>" : "<th>#{f125}</th>"
      h2 += (f126 > 0) ? "<th class='hili'>#{f126}</th>" : "<th>#{f126}</th>"
      h2 += (f127 > 0) ? "<th class='hili'>#{f127}</th>" : "<th>#{f127}</th>"
      h2 += (f128 > 0) ? "<th class='hili'>#{f128}</th>" : "<th>#{f128}</th>"
      h2 += (f129 > 0) ? "<th class='hili'>#{f129}</th>" : "<th>#{f129}</th>"
      h2 += (f130 > 0) ? "<th class='hili'>#{f130}</th>" : "<th>#{f130}</th>"
      h2 += (f131 > 0) ? "<th class='hili'>#{f131}</th>" : "<th>#{f131}</th>"
      h2 += (f132 > 0) ? "<th class='hili'>#{f132}</th>" : "<th>#{f132}</th>"
      h2 += (f133 > 0) ? "<th class='hili'>#{f133}</th>" : "<th>#{f133}</th>"
      h2 += (f134 > 0) ? "<th class='hili'>#{f134}</th>" : "<th>#{f134}</th>"
      h2 += (f135 > 0) ? "<th class='hili'>#{f135}</th>" : "<th>#{f135}</th>"
      h2 += (f136 > 0) ? "<th class='hili'>#{f136}</th>" : "<th>#{f136}</th>"
      h2 += (f137 > 0) ? "<th class='hili'>#{f137}</th>" : "<th>#{f137}</th>"
      h2 += (f138 > 0) ? "<th class='hili'>#{f138}</th>" : "<th>#{f138}</th>"
      h2 += (f139 > 0) ? "<th class='hili'>#{f139}</th>" : "<th>#{f139}</th>"
      h2 += (f140 > 0) ? "<th class='hili'>#{f140}</th>" : "<th>#{f140}</th>"
      h2 += (f141 > 0) ? "<th class='hili'>#{f141}</th>" : "<th>#{f141}</th>"
      h2 += (f142 > 0) ? "<th class='hili'>#{f142}</th>" : "<th>#{f142}</th>"
      h2 += (f143 > 0) ? "<th class='hili'>#{f143}</th>" : "<th>#{f143}</th>"
      h2 += (f144 > 0) ? "<th class='hili'>#{f144}</th>" : "<th>#{f144}</th>"
      h2 += (f145 > 0) ? "<th class='hili'>#{f145}</th>" : "<th>#{f145}</th>"
      h2 += (f146 > 0) ? "<th class='hili'>#{f146}</th>" : "<th>#{f146}</th>"
      h2 += (f147 > 0) ? "<th class='hili'>#{f147}</th>" : "<th>#{f147}</th>"
      h2 += (f148 > 0) ? "<th class='hili'>#{f148}</th>" : "<th>#{f148}</th>"
      h2 += (f149 > 0) ? "<th class='hili'>#{f149}</th>" : "<th>#{f149}</th>"
      h2 += (f150 > 0) ? "<th class='hili'>#{f150}</th>" : "<th>#{f150}</th>"
      h2 += (f151 > 0) ? "<th class='hili'>#{f151}</th>" : "<th>#{f151}</th>"
      h2 += (f152 > 0) ? "<th class='hili'>#{f152}</th>" : "<th>#{f152}</th>"
      h2 += (f153 > 0) ? "<th class='hili'>#{f153}</th>" : "<th>#{f153}</th>"
      h2 += (f154 > 0) ? "<th class='hili'>#{f154}</th>" : "<th>#{f154}</th>"
      h2 += (f155 > 0) ? "<th class='hili'>#{f155}</th>" : "<th>#{f155}</th>"
      h2 += (f156 > 0) ? "<th class='hili'>#{f156}</th>" : "<th>#{f156}</th>"
      h2 += (f157 > 0) ? "<th class='hili'>#{f157}</th>" : "<th>#{f157}</th>"
      h2 += (f158 > 0) ? "<th class='hili'>#{f158}</th>" : "<th>#{f158}</th>"
      h2 += (f159 > 0) ? "<th class='hili'>#{f159}</th>" : "<th>#{f159}</th>"
      h2 += (f160 > 0) ? "<th class='hili'>#{f160}</th>" : "<th>#{f160}</th>"
      h2 += (f161 > 0) ? "<th class='hili'>#{f161}</th>" : "<th>#{f161}</th>"
      h2 += (f162 > 0) ? "<th class='hili'>#{f162}</th>" : "<th>#{f162}</th>"
      h2 += (f163 > 0) ? "<th class='hili'>#{f163}</th>" : "<th>#{f163}</th>"
      h2 += (f164 > 0) ? "<th class='hili'>#{f164}</th>" : "<th>#{f164}</th>"
      h2 += (f165 > 0) ? "<th class='hili'>#{f165}</th>" : "<th>#{f165}</th>"

      if (year < '52')
        h2 += (f166 > 0) ? "<th class='hili'>#{f166}</th>" : "<th>#{f166}</th>"
        h2 += (f167 > 0) ? "<th class='hili'>#{f167}</th>" : "<th>#{f167}</th>"
        h2 += (f168 > 0) ? "<th class='hili'>#{f168}</th>" : "<th>#{f168}</th>"
        h2 += (f169 > 0) ? "<th class='hili'>#{f169}</th>" : "<th>#{f169}</th>"
        h2 += (f170 > 0) ? "<th class='hili'>#{f170}</th>" : "<th>#{f170}</th>"
        h2 += (f171 > 0) ? "<th class='hili'>#{f171}</th>" : "<th>#{f171}</th>"
        h2 += (f172 > 0) ? "<th class='hili'>#{f172}</th>" : "<th>#{f172}</th>"
        h2 += (f173 > 0) ? "<th class='hili'>#{f173}</th>" : "<th>#{f173}</th>"
      end

      h2 += (f1to4x > 0) ? "<th class='hili'>#{f1to4x}</th>" : "<th>#{f1to4x}</th>"
      h2 += "</tr>\n"
    end
    h2 = "#{h2}<tr bgcolor='yellow'><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th>"
    h2 += "<th align='right'>Total</th><th>&nbsp;</th><th>&nbsp;</th>"

    gTotal = 0
    max = 0
    if (year < '52')
      max = 172
    else
      max = 164
    end
    (5..max).each do |x|
      gTotal += totalCol[x].to_s.to_i
      h2 += "<th><font color='red'>#{totalCol[x]}</font></th>"
    end
    h2 += "<th><font color='red'>#{gTotal}</font></th></tr>\n"
  else
    h1 = "&nbsp;"
    h2 = "<tr></tr>"
  end

  h = h1 if type == '2'
  h = h2 if type == '1'
  h
end

def getForm6(year,pcode,acode,type)
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year}")
  sql = "SELECT * FROM form6 "
  if (acode.length == 4) # request from Amphoe
    if (acode =~ /01$/)
      sql += "WHERE (f6pcode='#{acode}' OR f6pcode='#{pcode}') "
    else
      sql += "WHERE f6pcode='#{acode}' "
    end
  else
    sql += "WHERE f6pcode='#{pcode}' "
  end
  sql += "ORDER BY f6hcode"
  res = con.exec(sql)
  con.close

  h1 = h2  = nil
  n = 0
  ord = otype = nil

  totalCol = Array.new

  found = res.num_tuples
  if (found > 0)
    res.each do |rec|
      n += 1
      ord = sprintf("%03d", n)
      f1 = rec[0]
      f2 = rec[1]
      f3 = rec[2]
      f4 = rec[3]
      f5 = rec[4].to_s
      otype = getOtype(f5)
      if (acode.to_s.length == 4)
        acodex = getAmpCode(f5)
        next if (acodex != acode)
      end
      f6 = rec[5].to_s.to_i
      f7 = rec[6].to_s.to_i
      f8 = rec[7].to_s.to_i
      f9 = rec[8].to_s.to_i
      f10 = rec[9].to_s.to_i
      f11 = rec[10].to_s.to_i
      f12 = rec[11].to_s.to_i
      f13 = rec[12].to_s.to_i
      f14 = rec[13].to_s.to_i
      f15 = rec[14].to_s.to_i
      f16 = rec[15].to_s.to_i
      f17 = rec[16].to_s.to_i
      f18 = rec[17].to_s.to_i
      f19 = rec[18].to_s.to_i
      f20 = rec[19].to_s.to_i
      f21 = rec[20].to_s.to_i
      f22 = rec[21].to_s.to_i
      f23 = rec[22].to_s.to_i
      f24 = rec[23].to_s.to_i
      f25 = rec[24].to_s.to_i
      f26 = rec[25].to_s.to_i
      f27 = rec[26].to_s.to_i
      f28 = rec[27].to_s.to_i
      f29 = rec[28].to_s.to_i
      f30 = rec[29].to_s.to_i
      f31 = rec[30].to_s.to_i
      f32 = rec[31].to_s.to_i
      f33 = rec[32].to_s.to_i
      f34 = rec[33].to_s.to_i
      f35 = rec[34].to_s.to_i
      f36 = rec[35].to_s.to_i
      f37 = rec[36].to_s.to_i
      f38 = rec[37].to_s.to_i
      f39 = rec[38].to_s.to_i
      f40 = rec[39].to_s.to_i
      f41 = rec[40].to_s.to_i
      f42 = rec[41].to_s.to_i
      f43 = rec[42].to_s.to_i
      f44 = rec[43].to_s.to_i
      f45 = rec[44].to_s.to_i
      f46 = rec[45].to_s.to_i
      f47 = rec[46].to_s.to_i
      f48 = rec[47].to_s.to_i
      f49 = rec[48].to_s.to_i
      f50 = rec[49].to_s.to_i
      f51 = rec[50].to_s.to_i
      f52 = rec[51].to_s.to_i
      f53 = rec[52].to_s.to_i
      f54 = rec[53].to_s.to_i
      f55 = rec[54].to_s.to_i
      f56 = rec[55].to_s.to_i
      f57 = rec[56].to_s.to_i
      f58 = rec[57].to_s.to_i
      f59 = rec[58].to_s.to_i
      f60 = rec[59].to_s.to_i
      f61 = rec[60].to_s.to_i
      f62 = rec[61].to_s.to_i
      f63 = rec[62].to_s.to_i
      f64 = rec[63].to_s.to_i
      f65 = rec[64].to_s.to_i
      f66 = rec[65].to_s.to_i
      f67 = rec[66].to_s.to_i
      f68 = rec[67].to_s.to_i
      f69 = rec[68].to_s.to_i
      f70 = rec[69].to_s.to_i
      f71 = rec[70].to_s.to_i
      f72 = rec[71].to_s.to_i
      f73 = rec[72].to_s.to_i
      f74 = rec[73].to_s.to_i
      f75 = rec[74].to_s.to_i
      f76 = rec[75].to_s.to_i
      f77 = rec[76].to_s.to_i
      f78 = rec[77].to_s.to_i
      f79 = rec[78].to_s.to_i
      f80 = rec[79].to_s.to_i
      f81 = rec[80].to_s.to_i
      f82 = rec[81].to_s.to_i
      f83 = rec[82].to_s.to_i
      f84 = rec[83].to_s.to_i
      f85 = rec[84].to_s.to_i
      f86 = rec[85].to_s.to_i
      f87 = rec[86].to_s.to_i
      f88 = rec[87].to_s.to_i
      f89 = rec[88].to_s.to_i
      f90 = rec[89].to_s.to_i
      f91 = rec[90].to_s.to_i
      f92 = rec[91].to_s.to_i
      f93 = rec[92].to_s.to_i
      f94 = rec[93].to_s.to_i
      f95 = rec[94].to_s.to_i
      f96 = rec[95].to_s.to_i
      f97 = rec[96].to_s.to_i
      f98 = rec[97].to_s.to_i
      f99 = rec[98].to_s.to_i
      f100 = rec[99].to_s.to_i
      f101 = rec[100].to_s.to_i
      f102 = rec[101].to_s.to_i
      f103 = rec[102].to_s.to_i
      f104 = rec[103].to_s.to_i
      f105 = rec[104].to_s.to_i
      f106 = rec[105].to_s.to_i
      f107 = rec[106].to_s.to_i
      f108 = rec[107].to_s.to_i
      f109 = rec[108].to_s.to_i
      f110 = rec[109].to_s.to_i
      f111 = rec[110].to_s.to_i
      f112 = rec[111].to_s.to_i
      f113 = rec[112].to_s.to_i
      f114 = rec[113].to_s.to_i
      f115 = rec[114].to_s.to_i
      f116 = rec[115].to_s.to_i
      f117 = rec[116].to_s.to_i
      f118 = rec[117].to_s.to_i
      f119 = rec[118].to_s.to_i
      f120 = rec[119].to_s.to_i
      f121 = rec[120].to_s.to_i
      f122 = rec[121].to_s.to_i
      f123 = rec[122].to_s.to_i
      f124 = rec[123].to_s.to_i
      f125 = rec[124].to_s.to_i
      f126 = rec[125].to_s.to_i
      f127 = rec[126].to_s.to_i
      f128 = rec[127].to_s.to_i
      f129 = rec[128].to_s.to_i
      f130 = rec[129].to_s.to_i
      f131 = rec[130].to_s.to_i
      f132 = rec[131].to_s.to_i
      f133 = rec[132].to_s.to_i
      f134 = rec[133].to_s.to_i
      f135 = rec[134].to_s.to_i
      f136 = rec[135].to_s.to_i
      f137 = rec[136].to_s.to_i
      f138 = rec[137].to_s.to_i
      f139 = rec[138].to_s.to_i
      f140 = rec[139].to_s.to_i
      f141 = rec[140].to_s.to_i
      f142 = rec[141].to_s.to_i
      f143 = rec[142].to_s.to_i
      f144 = rec[143].to_s.to_i
      f145 = rec[144].to_s.to_i
      f146 = rec[145].to_s.to_i
      f147 = rec[146].to_s.to_i
      f148 = rec[147].to_s.to_i
      f149 = rec[148].to_s.to_i
      f150 = rec[149].to_s.to_i
      f151 = rec[150].to_s.to_i
      f152 = rec[151].to_s.to_i
      f153 = rec[152].to_s.to_i
      f154 = rec[153].to_s.to_i
      f155 = rec[154].to_s.to_i
      f156 = rec[155].to_s.to_i
      f157 = rec[156].to_s.to_i
      f158 = rec[157].to_s.to_i
      f159 = rec[158].to_s.to_i
      f160 = rec[159].to_s.to_i
      f161 = rec[160].to_s.to_i
      f162 = rec[161].to_s.to_i
      f163 = rec[162].to_s.to_i
      f164 = rec[163].to_s.to_i
      f165 = rec[164].to_s.to_i
      f166 = rec[165].to_s.to_i
      f167 = rec[166].to_s.to_i
      f168 = rec[167].to_s.to_i
      f169 = rec[168].to_s.to_i
      f170 = rec[169].to_s.to_i
      f171 = rec[170].to_s.to_i
      f172 = rec[171].to_s.to_i
      f173 = rec[172].to_s.to_i
      f174 = rec[173].to_s.to_i
      f175 = rec[174].to_s.to_i
      f176 = rec[175].to_s.to_i
      f177 = rec[176].to_s.to_i
      f178 = rec[177].to_s.to_i
      f179 = rec[178].to_s.to_i
      f180 = rec[179].to_s.to_i
      f181 = rec[180].to_s.to_i
      f182 = rec[181].to_s.to_i
      f183 = rec[182].to_s.to_i
      f184 = rec[183].to_s.to_i
      f185 = rec[184].to_s.to_i
      f186 = rec[185].to_s.to_i
      f187 = rec[186].to_s.to_i
      f188 = rec[187].to_s.to_i
      f189 = rec[188].to_s.to_i
      f190 = rec[189].to_s.to_i
      f191 = rec[190].to_s.to_i
      f192 = rec[191].to_s.to_i
      f193 = rec[192].to_s.to_i
      f194 = rec[193].to_s.to_i
      f195 = rec[194].to_s.to_i
      f196 = rec[195].to_s.to_i
      f197 = rec[196].to_s.to_i
      f198 = rec[197].to_s.to_i
      f199 = rec[198].to_s.to_i
      f200 = rec[199].to_s.to_i
      f201 = rec[200].to_s.to_i
      f202 = rec[201].to_s.to_i
      f203 = rec[202].to_s.to_i
      f204 = rec[203].to_s.to_i
      f205 = rec[204].to_s.to_i
      f206 = rec[205].to_s.to_i
      f207 = rec[206].to_s.to_i
      f208 = rec[207].to_s.to_i
      f209 = rec[208].to_s.to_i
      f210 = rec[209].to_s.to_i
      f211 = rec[210].to_s.to_i
      f212 = rec[211].to_s.to_i
      f213 = rec[212].to_s.to_i
      f214 = rec[213].to_s.to_i
      f215 = rec[214].to_s.to_i
      f216 = rec[215].to_s.to_i
      f217 = rec[216].to_s.to_i
      f218 = rec[217].to_s.to_i
      f219 = rec[218].to_s.to_i
      f220 = rec[219].to_s.to_i
      f221 = rec[220].to_s.to_i
      f222 = rec[221].to_s.to_i
      f223 = rec[222].to_s.to_i
      f224 = rec[223].to_s.to_i
      f225 = rec[224].to_s.to_i
      f226 = rec[225].to_s.to_i
      f227 = rec[226].to_s.to_i
      f228 = rec[227].to_s.to_i
      f229 = rec[228].to_s.to_i
      f230 = rec[229].to_s.to_i
      f231 = rec[230].to_s.to_i
      f232 = rec[231].to_s.to_i
      f233 = rec[232].to_s.to_i
      f234 = rec[233].to_s.to_i
      f235 = rec[234].to_s.to_i
      f236 = rec[235].to_s.to_i
      f237 = rec[236].to_s.to_i
      f238 = rec[237].to_s.to_i
      f239 = rec[238].to_s.to_i
      f240 = rec[239].to_s.to_i
      f241 = rec[240].to_s.to_i
      f242 = rec[241].to_s.to_i
      f243 = rec[242].to_s.to_i
      f244 = rec[243].to_s.to_i
      f245 = rec[244].to_s.to_i
      f246 = rec[245].to_s.to_i
      f247 = rec[246].to_s.to_i
      f248 = rec[247].to_s.to_i
      f249 = rec[248].to_s.to_i
      f250 = rec[249].to_s.to_i
      f251 = rec[250].to_s.to_i
      f252 = rec[251].to_s.to_i
      f253 = rec[252].to_s.to_i
      f254 = rec[253].to_s.to_i
      f255 = rec[254].to_s.to_i
      f256 = rec[255].to_s.to_i
      f257 = rec[256].to_s.to_i
      f258 = rec[257].to_s.to_i
      f259 = rec[258].to_s.to_i
      f260 = rec[259].to_s.to_i
      f261 = rec[260].to_s.to_i
      f262 = rec[261].to_s.to_i
      f263 = rec[262].to_s.to_i
      f264 = rec[263].to_s.to_i
      f265 = rec[264].to_s.to_i
      f266 = rec[265].to_s.to_i
      f267 = rec[266].to_s.to_i
      f268 = rec[267].to_s.to_i
      f269 = rec[268].to_s.to_i
      f270 = rec[269].to_s.to_i
      f271 = rec[270].to_s.to_i
      f272 = rec[271].to_s.to_i
      f273 = rec[272].to_s.to_i
      f274 = rec[273].to_s.to_i
      f275 = rec[274].to_s.to_i
      f276 = rec[275].to_s.to_i
      f277 = rec[276].to_s.to_i
      f278 = rec[277].to_s.to_i
      f279 = rec[278].to_s.to_i
      f280 = rec[279].to_s.to_i
      f281 = rec[280].to_s.to_i
      f282 = rec[281].to_s.to_i
      f283 = rec[282].to_s.to_i
      f284 = rec[283].to_s.to_i
      f285 = rec[284].to_s.to_i
      f286 = rec[285].to_s.to_i
      f287 = rec[286].to_s.to_i
      f288 = rec[287].to_s.to_i
      f289 = rec[288].to_s.to_i
      f290 = rec[289].to_s.to_i
      f291 = rec[290].to_s.to_i
      f292 = rec[291].to_s.to_i
      f293 = rec[292].to_s.to_i
      f294 = rec[293].to_s.to_i
      f295 = rec[294].to_s.to_i
      f296 = rec[295].to_s.to_i
      f297 = rec[296].to_s.to_i
      f298 = rec[297].to_s.to_i
      f299 = rec[298].to_s.to_i
      f300 = rec[299].to_s.to_i
      f301 = rec[300].to_s.to_i
      f302 = rec[301].to_s.to_i
      f303 = rec[302].to_s.to_i
      f304 = rec[303].to_s.to_i
      f305 = rec[304].to_s.to_i
      f306 = rec[305].to_s.to_i
      f307 = rec[306].to_s.to_i
      f308 = rec[307].to_s.to_i
      f309 = rec[308].to_s.to_i
      f310 = rec[309].to_s.to_i
      f311 = rec[310].to_s.to_i
      f312 = rec[311].to_s.to_i
      f313 = rec[312].to_s.to_i
      f314 = rec[313].to_s.to_i
      f315 = rec[314].to_s.to_i
      f316 = rec[315].to_s.to_i
      f317 = rec[316].to_s.to_i
      f318 = rec[317].to_s.to_i
      f319 = rec[318].to_s.to_i
      f320 = rec[319].to_s.to_i
      f321 = rec[320].to_s.to_i

      f1to79 = 0
      (5..320).each do |x|
        if (totalCol[x].nil?)
          totalCol[x] = 0
        end
        totalCol[x] += rec[x].to_s.to_i
        f1to79 += rec[x].to_s.to_i
      end

      h1 = "#{h1}#{ord},#{f1},#{f2},#{f3},#{f4},#{otype}#{f5},#{f6},#{f7},#{f8},#{f9},#{f10},#{f11},#{f12},#{f13},#{f14},#{f15},#{f16},#{f17},#{f18},#{f19},#{f20},#{f21},#{f22},#{f23},#{f24},#{f25},#{f26},#{f27},#{f28},#{f29},#{f30},#{f31},#{f32},#{f33},#{f34},#{f35},#{f36},#{f37},#{f38},#{f39},#{f40},#{f41},#{f42},#{f43},#{f44},#{f45},#{f46},#{f47},#{f48},#{f49},#{f50},#{f51},#{f52},#{f53},#{f54},#{f55},#{f56},#{f57},#{f58},#{f59},#{f60},#{f61},#{f62},#{f63},#{f64},#{f65},#{f66},#{f67},#{f68},#{f69},#{f70},#{f71},#{f72},#{f73},#{f74},#{f75},#{f76},#{f77},#{f78},#{f79},#{f80},#{f81},#{f82},#{f83},#{f84},#{f85},#{f86},#{f87},#{f88},#{f89},#{f90},#{f91},#{f92},#{f93},#{f94},#{f95},#{f96},#{f97},#{f98},#{f99},#{f100},#{f101},#{f102},#{f103},#{f104},#{f105},#{f106},#{f107},#{f108},#{f109},#{f110},#{f111},#{f112},#{f113},#{f114},#{f115},#{f116},#{f117},#{f118},#{f119},#{f120},#{f121},#{f122},#{f123},#{f124},#{f125},#{f126},#{f127},#{f128},#{f129},#{f130},#{f131},#{f132},#{f133},#{f134},#{f135},#{f136},#{f137},#{f138},#{f139},#{f140},#{f141},#{f142},#{f143},#{f144},#{f145},#{f146},#{f147},#{f148},#{f149},#{f150},#{f151},#{f152},#{f153},#{f154},#{f155},#{f156},#{f157},#{f158},#{f159},#{f160},#{f161},#{f162},#{f163},#{f164},#{f165},#{f166},#{f167},#{f168},#{f169},#{f170},#{f171},#{f172},#{f173},#{f174},#{f175},#{f176},#{f177},#{f178},#{f179},#{f180},#{f181},#{f182},#{f183},#{f184},#{f185},#{f186},#{f187},#{f188},#{f189},#{f190},#{f191},#{f192},#{f193},#{f194},#{f195},#{f196},#{f197},#{f198},#{f199},#{f200},#{f201},#{f202},#{f203},#{f204},#{f205},#{f206},#{f207},#{f208},#{f209},#{f210},#{f211},#{f212},#{f213},#{f214},#{f215},#{f216},#{f217},#{f218},#{f219},#{f220},#{f221},#{f222},#{f223},#{f224},#{f225},#{f226},#{f227},#{f228},#{f229},#{f230},#{f231},#{f232},#{f233},#{f234},#{f235},#{f236},#{f237},#{f238},#{f239},#{f240},#{f241},#{f242},#{f243},#{f244},#{f245},#{f246},#{f247},#{f248},#{f249},#{f250},#{f251},#{f252},#{f253},#{f254},#{f255},#{f256},#{f257},#{f258},#{f259},#{f260},#{f261},#{f262},#{f263},#{f264},#{f265},#{f266},#{f267},#{f268},#{f269},#{f270},#{f271},#{f272},#{f273},#{f274},#{f275},#{f276},#{f277},#{f278},#{f279},#{f280},#{f281},#{f282},#{f283},#{f284},#{f285},#{f286},#{f287},#{f288},#{f289},#{f290},#{f291},#{f292},#{f293},#{f294},#{f295},#{f296},#{f297},#{f298},#{f299},#{f300},#{f301},#{f302},#{f303},#{f304},#{f305},#{f306},#{f307},#{f308},#{f309},#{f310},#{f311},#{f312},#{f313},#{f314},#{f315},#{f316},#{f317},#{f318},#{f319},#{f320},#{f321},#{f1to79}\n"

      h2 = "#{h2}<tr bgcolor='#CCCCCC'><th>#{ord}</th><th>#{f1}</th><th>#{f2}</th><th>#{f3}</th><td>#{f4}</td><th>#{otype}</th><th>#{f5}</th>"
      h2 += (f6 > 0) ? "<th class='hili'>#{f6}</th>" : "<th>#{f6}</th>"
      h2 += (f7 > 0) ? "<th class='hili'>#{f7}</th>" : "<th>#{f7}</th>"
      h2 += (f8 > 0) ? "<th class='hili'>#{f8}</th>" : "<th>#{f8}</th>"
      h2 += (f9 > 0) ? "<th class='hili'>#{f9}</th>" : "<th>#{f9}</th>"
      h2 += (f10 > 0) ? "<th class='hili'>#{f10}</th>" : "<th>#{f10}</th>"
      h2 += (f11 > 0) ? "<th class='hili'>#{f11}</th>" : "<th>#{f11}</th>"
      h2 += (f12 > 0) ? "<th class='hili'>#{f12}</th>" : "<th>#{f12}</th>"
      h2 += (f13 > 0) ? "<th class='hili'>#{f13}</th>" : "<th>#{f13}</th>"
      h2 += (f14 > 0) ? "<th class='hili'>#{f14}</th>" : "<th>#{f14}</th>"
      h2 += (f15 > 0) ? "<th class='hili'>#{f15}</th>" : "<th>#{f15}</th>"
      h2 += (f16 > 0) ? "<th class='hili'>#{f16}</th>" : "<th>#{f16}</th>"
      h2 += (f17 > 0) ? "<th class='hili'>#{f17}</th>" : "<th>#{f17}</th>"
      h2 += (f18 > 0) ? "<th class='hili'>#{f18}</th>" : "<th>#{f18}</th>"
      h2 += (f19 > 0) ? "<th class='hili'>#{f19}</th>" : "<th>#{f19}</th>"
      h2 += (f20 > 0) ? "<th class='hili'>#{f20}</th>" : "<th>#{f20}</th>"
      h2 += (f21 > 0) ? "<th class='hili'>#{f21}</th>" : "<th>#{f21}</th>"
      h2 += (f22 > 0) ? "<th class='hili'>#{f22}</th>" : "<th>#{f22}</th>"
      h2 += (f23 > 0) ? "<th class='hili'>#{f23}</th>" : "<th>#{f23}</th>"
      h2 += (f24 > 0) ? "<th class='hili'>#{f24}</th>" : "<th>#{f24}</th>"
      h2 += (f25 > 0) ? "<th class='hili'>#{f25}</th>" : "<th>#{f25}</th>"
      h2 += (f26 > 0) ? "<th class='hili'>#{f26}</th>" : "<th>#{f26}</th>"
      h2 += (f27 > 0) ? "<th class='hili'>#{f27}</th>" : "<th>#{f27}</th>"
      h2 += (f28 > 0) ? "<th class='hili'>#{f28}</th>" : "<th>#{f28}</th>"
      h2 += (f29 > 0) ? "<th class='hili'>#{f29}</th>" : "<th>#{f29}</th>"
      h2 += (f30 > 0) ? "<th class='hili'>#{f30}</th>" : "<th>#{f30}</th>"
      h2 += (f31 > 0) ? "<th class='hili'>#{f31}</th>" : "<th>#{f31}</th>"
      h2 += (f32 > 0) ? "<th class='hili'>#{f32}</th>" : "<th>#{f32}</th>"
      h2 += (f33 > 0) ? "<th class='hili'>#{f33}</th>" : "<th>#{f33}</th>"
      h2 += (f34 > 0) ? "<th class='hili'>#{f34}</th>" : "<th>#{f34}</th>"
      h2 += (f35 > 0) ? "<th class='hili'>#{f35}</th>" : "<th>#{f35}</th>"
      h2 += (f36 > 0) ? "<th class='hili'>#{f36}</th>" : "<th>#{f36}</th>"
      h2 += (f37 > 0) ? "<th class='hili'>#{f37}</th>" : "<th>#{f37}</th>"
      h2 += (f38 > 0) ? "<th class='hili'>#{f38}</th>" : "<th>#{f38}</th>"
      h2 += (f39 > 0) ? "<th class='hili'>#{f39}</th>" : "<th>#{f39}</th>"
      h2 += (f40 > 0) ? "<th class='hili'>#{f40}</th>" : "<th>#{f40}</th>"
      h2 += (f41 > 0) ? "<th class='hili'>#{f41}</th>" : "<th>#{f41}</th>"
      h2 += (f42 > 0) ? "<th class='hili'>#{f42}</th>" : "<th>#{f42}</th>"
      h2 += (f43 > 0) ? "<th class='hili'>#{f43}</th>" : "<th>#{f43}</th>"
      h2 += (f44 > 0) ? "<th class='hili'>#{f44}</th>" : "<th>#{f44}</th>"
      h2 += (f45 > 0) ? "<th class='hili'>#{f45}</th>" : "<th>#{f45}</th>"
      h2 += (f46 > 0) ? "<th class='hili'>#{f46}</th>" : "<th>#{f46}</th>"
      h2 += (f47 > 0) ? "<th class='hili'>#{f47}</th>" : "<th>#{f47}</th>"
      h2 += (f48 > 0) ? "<th class='hili'>#{f48}</th>" : "<th>#{f48}</th>"
      h2 += (f49 > 0) ? "<th class='hili'>#{f49}</th>" : "<th>#{f49}</th>"
      h2 += (f50 > 0) ? "<th class='hili'>#{f50}</th>" : "<th>#{f50}</th>"
      h2 += (f51 > 0) ? "<th class='hili'>#{f51}</th>" : "<th>#{f51}</th>"
      h2 += (f52 > 0) ? "<th class='hili'>#{f52}</th>" : "<th>#{f52}</th>"
      h2 += (f53 > 0) ? "<th class='hili'>#{f53}</th>" : "<th>#{f53}</th>"
      h2 += (f54 > 0) ? "<th class='hili'>#{f54}</th>" : "<th>#{f54}</th>"
      h2 += (f55 > 0) ? "<th class='hili'>#{f55}</th>" : "<th>#{f55}</th>"
      h2 += (f56 > 0) ? "<th class='hili'>#{f56}</th>" : "<th>#{f56}</th>"
      h2 += (f57 > 0) ? "<th class='hili'>#{f57}</th>" : "<th>#{f57}</th>"
      h2 += (f58 > 0) ? "<th class='hili'>#{f58}</th>" : "<th>#{f58}</th>"
      h2 += (f59 > 0) ? "<th class='hili'>#{f59}</th>" : "<th>#{f59}</th>"
      h2 += (f60 > 0) ? "<th class='hili'>#{f60}</th>" : "<th>#{f60}</th>"
      h2 += (f61 > 0) ? "<th class='hili'>#{f61}</th>" : "<th>#{f61}</th>"
      h2 += (f62 > 0) ? "<th class='hili'>#{f62}</th>" : "<th>#{f62}</th>"
      h2 += (f63 > 0) ? "<th class='hili'>#{f63}</th>" : "<th>#{f63}</th>"
      h2 += (f64 > 0) ? "<th class='hili'>#{f64}</th>" : "<th>#{f64}</th>"
      h2 += (f65 > 0) ? "<th class='hili'>#{f65}</th>" : "<th>#{f65}</th>"
      h2 += (f66 > 0) ? "<th class='hili'>#{f66}</th>" : "<th>#{f66}</th>"
      h2 += (f67 > 0) ? "<th class='hili'>#{f67}</th>" : "<th>#{f67}</th>"
      h2 += (f68 > 0) ? "<th class='hili'>#{f68}</th>" : "<th>#{f68}</th>"
      h2 += (f69 > 0) ? "<th class='hili'>#{f69}</th>" : "<th>#{f69}</th>"
      h2 += (f70 > 0) ? "<th class='hili'>#{f70}</th>" : "<th>#{f70}</th>"
      h2 += (f71 > 0) ? "<th class='hili'>#{f71}</th>" : "<th>#{f71}</th>"
      h2 += (f72 > 0) ? "<th class='hili'>#{f72}</th>" : "<th>#{f72}</th>"
      h2 += (f73 > 0) ? "<th class='hili'>#{f73}</th>" : "<th>#{f73}</th>"
      h2 += (f74 > 0) ? "<th class='hili'>#{f74}</th>" : "<th>#{f74}</th>"
      h2 += (f75 > 0) ? "<th class='hili'>#{f75}</th>" : "<th>#{f75}</th>"
      h2 += (f76 > 0) ? "<th class='hili'>#{f76}</th>" : "<th>#{f76}</th>"
      h2 += (f77 > 0) ? "<th class='hili'>#{f77}</th>" : "<th>#{f77}</th>"
      h2 += (f78 > 0) ? "<th class='hili'>#{f78}</th>" : "<th>#{f78}</th>"
      h2 += (f79 > 0) ? "<th class='hili'>#{f79}</th>" : "<th>#{f79}</th>"
      h2 += (f80 > 0) ? "<th class='hili'>#{f80}</th>" : "<th>#{f80}</th>"
      h2 += (f81 > 0) ? "<th class='hili'>#{f81}</th>" : "<th>#{f81}</th>"
      h2 += (f82 > 0) ? "<th class='hili'>#{f82}</th>" : "<th>#{f82}</th>"
      h2 += (f83 > 0) ? "<th class='hili'>#{f83}</th>" : "<th>#{f83}</th>"
      h2 += (f84 > 0) ? "<th class='hili'>#{f84}</th>" : "<th>#{f84}</th>"
      h2 += (f85 > 0) ? "<th class='hili'>#{f85}</th>" : "<th>#{f85}</th>"
      h2 += (f86 > 0) ? "<th class='hili'>#{f86}</th>" : "<th>#{f86}</th>"
      h2 += (f87 > 0) ? "<th class='hili'>#{f87}</th>" : "<th>#{f87}</th>"
      h2 += (f88 > 0) ? "<th class='hili'>#{f88}</th>" : "<th>#{f88}</th>"
      h2 += (f89 > 0) ? "<th class='hili'>#{f89}</th>" : "<th>#{f89}</th>"
      h2 += (f90 > 0) ? "<th class='hili'>#{f90}</th>" : "<th>#{f90}</th>"
      h2 += (f91 > 0) ? "<th class='hili'>#{f91}</th>" : "<th>#{f91}</th>"
      h2 += (f92 > 0) ? "<th class='hili'>#{f92}</th>" : "<th>#{f92}</th>"
      h2 += (f93 > 0) ? "<th class='hili'>#{f93}</th>" : "<th>#{f93}</th>"
      h2 += (f94 > 0) ? "<th class='hili'>#{f94}</th>" : "<th>#{f94}</th>"
      h2 += (f95 > 0) ? "<th class='hili'>#{f95}</th>" : "<th>#{f95}</th>"
      h2 += (f96 > 0) ? "<th class='hili'>#{f96}</th>" : "<th>#{f96}</th>"
      h2 += (f97 > 0) ? "<th class='hili'>#{f97}</th>" : "<th>#{f97}</th>"
      h2 += (f98 > 0) ? "<th class='hili'>#{f98}</th>" : "<th>#{f98}</th>"
      h2 += (f99 > 0) ? "<th class='hili'>#{f99}</th>" : "<th>#{f99}</th>"
      h2 += (f100 > 0) ? "<th class='hili'>#{f100}</th>" : "<th>#{f100}</th>"
      h2 += (f101 > 0) ? "<th class='hili'>#{f101}</th>" : "<th>#{f101}</th>"
      h2 += (f102 > 0) ? "<th class='hili'>#{f102}</th>" : "<th>#{f102}</th>"
      h2 += (f103 > 0) ? "<th class='hili'>#{f103}</th>" : "<th>#{f103}</th>"
      h2 += (f104 > 0) ? "<th class='hili'>#{f104}</th>" : "<th>#{f104}</th>"
      h2 += (f105 > 0) ? "<th class='hili'>#{f105}</th>" : "<th>#{f105}</th>"
      h2 += (f106 > 0) ? "<th class='hili'>#{f106}</th>" : "<th>#{f106}</th>"
      h2 += (f107 > 0) ? "<th class='hili'>#{f107}</th>" : "<th>#{f107}</th>"
      h2 += (f108 > 0) ? "<th class='hili'>#{f108}</th>" : "<th>#{f108}</th>"
      h2 += (f109 > 0) ? "<th class='hili'>#{f109}</th>" : "<th>#{f109}</th>"
      h2 += (f110 > 0) ? "<th class='hili'>#{f110}</th>" : "<th>#{f110}</th>"
      h2 += (f111 > 0) ? "<th class='hili'>#{f111}</th>" : "<th>#{f111}</th>"
      h2 += (f112 > 0) ? "<th class='hili'>#{f112}</th>" : "<th>#{f112}</th>"
      h2 += (f113 > 0) ? "<th class='hili'>#{f113}</th>" : "<th>#{f113}</th>"
      h2 += (f114 > 0) ? "<th class='hili'>#{f114}</th>" : "<th>#{f114}</th>"
      h2 += (f115 > 0) ? "<th class='hili'>#{f115}</th>" : "<th>#{f115}</th>"
      h2 += (f116 > 0) ? "<th class='hili'>#{f116}</th>" : "<th>#{f116}</th>"
      h2 += (f117 > 0) ? "<th class='hili'>#{f117}</th>" : "<th>#{f117}</th>"
      h2 += (f118 > 0) ? "<th class='hili'>#{f118}</th>" : "<th>#{f118}</th>"
      h2 += (f119 > 0) ? "<th class='hili'>#{f119}</th>" : "<th>#{f119}</th>"
      h2 += (f120 > 0) ? "<th class='hili'>#{f120}</th>" : "<th>#{f120}</th>"
      h2 += (f121 > 0) ? "<th class='hili'>#{f121}</th>" : "<th>#{f121}</th>"
      h2 += (f122 > 0) ? "<th class='hili'>#{f122}</th>" : "<th>#{f122}</th>"
      h2 += (f123 > 0) ? "<th class='hili'>#{f123}</th>" : "<th>#{f123}</th>"
      h2 += (f124 > 0) ? "<th class='hili'>#{f124}</th>" : "<th>#{f124}</th>"
      h2 += (f125 > 0) ? "<th class='hili'>#{f125}</th>" : "<th>#{f125}</th>"
      h2 += (f126 > 0) ? "<th class='hili'>#{f126}</th>" : "<th>#{f126}</th>"
      h2 += (f127 > 0) ? "<th class='hili'>#{f127}</th>" : "<th>#{f127}</th>"
      h2 += (f128 > 0) ? "<th class='hili'>#{f128}</th>" : "<th>#{f128}</th>"
      h2 += (f129 > 0) ? "<th class='hili'>#{f129}</th>" : "<th>#{f129}</th>"
      h2 += (f130 > 0) ? "<th class='hili'>#{f130}</th>" : "<th>#{f130}</th>"
      h2 += (f131 > 0) ? "<th class='hili'>#{f131}</th>" : "<th>#{f131}</th>"
      h2 += (f132 > 0) ? "<th class='hili'>#{f132}</th>" : "<th>#{f132}</th>"
      h2 += (f133 > 0) ? "<th class='hili'>#{f133}</th>" : "<th>#{f133}</th>"
      h2 += (f134 > 0) ? "<th class='hili'>#{f134}</th>" : "<th>#{f134}</th>"
      h2 += (f135 > 0) ? "<th class='hili'>#{f135}</th>" : "<th>#{f135}</th>"
      h2 += (f136 > 0) ? "<th class='hili'>#{f136}</th>" : "<th>#{f136}</th>"
      h2 += (f137 > 0) ? "<th class='hili'>#{f137}</th>" : "<th>#{f137}</th>"
      h2 += (f138 > 0) ? "<th class='hili'>#{f138}</th>" : "<th>#{f138}</th>"
      h2 += (f139 > 0) ? "<th class='hili'>#{f139}</th>" : "<th>#{f139}</th>"
      h2 += (f140 > 0) ? "<th class='hili'>#{f140}</th>" : "<th>#{f140}</th>"
      h2 += (f141 > 0) ? "<th class='hili'>#{f141}</th>" : "<th>#{f141}</th>"
      h2 += (f142 > 0) ? "<th class='hili'>#{f142}</th>" : "<th>#{f142}</th>"
      h2 += (f143 > 0) ? "<th class='hili'>#{f143}</th>" : "<th>#{f143}</th>"
      h2 += (f144 > 0) ? "<th class='hili'>#{f144}</th>" : "<th>#{f144}</th>"
      h2 += (f145 > 0) ? "<th class='hili'>#{f145}</th>" : "<th>#{f145}</th>"
      h2 += (f146 > 0) ? "<th class='hili'>#{f146}</th>" : "<th>#{f146}</th>"
      h2 += (f147 > 0) ? "<th class='hili'>#{f147}</th>" : "<th>#{f147}</th>"
      h2 += (f148 > 0) ? "<th class='hili'>#{f148}</th>" : "<th>#{f148}</th>"
      h2 += (f149 > 0) ? "<th class='hili'>#{f149}</th>" : "<th>#{f149}</th>"
      h2 += (f150 > 0) ? "<th class='hili'>#{f150}</th>" : "<th>#{f150}</th>"
      h2 += (f151 > 0) ? "<th class='hili'>#{f151}</th>" : "<th>#{f151}</th>"
      h2 += (f152 > 0) ? "<th class='hili'>#{f152}</th>" : "<th>#{f152}</th>"
      h2 += (f153 > 0) ? "<th class='hili'>#{f153}</th>" : "<th>#{f153}</th>"
      h2 += (f154 > 0) ? "<th class='hili'>#{f154}</th>" : "<th>#{f154}</th>"
      h2 += (f155 > 0) ? "<th class='hili'>#{f155}</th>" : "<th>#{f155}</th>"
      h2 += (f156 > 0) ? "<th class='hili'>#{f156}</th>" : "<th>#{f156}</th>"
      h2 += (f157 > 0) ? "<th class='hili'>#{f157}</th>" : "<th>#{f157}</th>"
      h2 += (f158 > 0) ? "<th class='hili'>#{f158}</th>" : "<th>#{f158}</th>"
      h2 += (f159 > 0) ? "<th class='hili'>#{f159}</th>" : "<th>#{f159}</th>"
      h2 += (f160 > 0) ? "<th class='hili'>#{f160}</th>" : "<th>#{f160}</th>"
      h2 += (f161 > 0) ? "<th class='hili'>#{f161}</th>" : "<th>#{f161}</th>"
      h2 += (f162 > 0) ? "<th class='hili'>#{f162}</th>" : "<th>#{f162}</th>"
      h2 += (f163 > 0) ? "<th class='hili'>#{f163}</th>" : "<th>#{f163}</th>"
      h2 += (f164 > 0) ? "<th class='hili'>#{f164}</th>" : "<th>#{f164}</th>"
      h2 += (f165 > 0) ? "<th class='hili'>#{f165}</th>" : "<th>#{f165}</th>"
      h2 += (f166 > 0) ? "<th class='hili'>#{f166}</th>" : "<th>#{f166}</th>"
      h2 += (f167 > 0) ? "<th class='hili'>#{f167}</th>" : "<th>#{f167}</th>"
      h2 += (f168 > 0) ? "<th class='hili'>#{f168}</th>" : "<th>#{f168}</th>"
      h2 += (f169 > 0) ? "<th class='hili'>#{f169}</th>" : "<th>#{f169}</th>"
      h2 += (f170 > 0) ? "<th class='hili'>#{f170}</th>" : "<th>#{f170}</th>"
      h2 += (f171 > 0) ? "<th class='hili'>#{f171}</th>" : "<th>#{f171}</th>"
      h2 += (f172 > 0) ? "<th class='hili'>#{f172}</th>" : "<th>#{f172}</th>"
      h2 += (f173 > 0) ? "<th class='hili'>#{f173}</th>" : "<th>#{f173}</th>"
      h2 += (f174 > 0) ? "<th class='hili'>#{f174}</th>" : "<th>#{f174}</th>"
      h2 += (f175 > 0) ? "<th class='hili'>#{f175}</th>" : "<th>#{f175}</th>"
      h2 += (f176 > 0) ? "<th class='hili'>#{f176}</th>" : "<th>#{f176}</th>"
      h2 += (f177 > 0) ? "<th class='hili'>#{f177}</th>" : "<th>#{f177}</th>"
      h2 += (f178 > 0) ? "<th class='hili'>#{f178}</th>" : "<th>#{f178}</th>"
      h2 += (f179 > 0) ? "<th class='hili'>#{f179}</th>" : "<th>#{f179}</th>"
      h2 += (f180 > 0) ? "<th class='hili'>#{f180}</th>" : "<th>#{f180}</th>"
      h2 += (f181 > 0) ? "<th class='hili'>#{f181}</th>" : "<th>#{f181}</th>"
      h2 += (f182 > 0) ? "<th class='hili'>#{f182}</th>" : "<th>#{f182}</th>"
      h2 += (f183 > 0) ? "<th class='hili'>#{f183}</th>" : "<th>#{f183}</th>"
      h2 += (f184 > 0) ? "<th class='hili'>#{f184}</th>" : "<th>#{f184}</th>"
      h2 += (f185 > 0) ? "<th class='hili'>#{f185}</th>" : "<th>#{f185}</th>"
      h2 += (f186 > 0) ? "<th class='hili'>#{f186}</th>" : "<th>#{f186}</th>"
      h2 += (f187 > 0) ? "<th class='hili'>#{f187}</th>" : "<th>#{f187}</th>"
      h2 += (f188 > 0) ? "<th class='hili'>#{f188}</th>" : "<th>#{f188}</th>"
      h2 += (f189 > 0) ? "<th class='hili'>#{f189}</th>" : "<th>#{f189}</th>"
      h2 += (f190 > 0) ? "<th class='hili'>#{f190}</th>" : "<th>#{f190}</th>"
      h2 += (f191 > 0) ? "<th class='hili'>#{f191}</th>" : "<th>#{f191}</th>"
      h2 += (f192 > 0) ? "<th class='hili'>#{f192}</th>" : "<th>#{f192}</th>"
      h2 += (f193 > 0) ? "<th class='hili'>#{f193}</th>" : "<th>#{f193}</th>"
      h2 += (f194 > 0) ? "<th class='hili'>#{f194}</th>" : "<th>#{f194}</th>"
      h2 += (f195 > 0) ? "<th class='hili'>#{f195}</th>" : "<th>#{f195}</th>"
      h2 += (f196 > 0) ? "<th class='hili'>#{f196}</th>" : "<th>#{f196}</th>"
      h2 += (f197 > 0) ? "<th class='hili'>#{f197}</th>" : "<th>#{f197}</th>"
      h2 += (f198 > 0) ? "<th class='hili'>#{f198}</th>" : "<th>#{f198}</th>"
      h2 += (f199 > 0) ? "<th class='hili'>#{f199}</th>" : "<th>#{f199}</th>"
      h2 += (f200 > 0) ? "<th class='hili'>#{f200}</th>" : "<th>#{f200}</th>"
      h2 += (f201 > 0) ? "<th class='hili'>#{f201}</th>" : "<th>#{f201}</th>"
      if (year.to_i > 46)
        h2 += (f202 > 0) ? "<th class='hili'>#{f202}</th>" : "<th>#{f202}</th>"
        h2 += (f203 > 0) ? "<th class='hili'>#{f203}</th>" : "<th>#{f203}</th>"
        h2 += (f204 > 0) ? "<th class='hili'>#{f204}</th>" : "<th>#{f204}</th>"
        h2 += (f205 > 0) ? "<th class='hili'>#{f205}</th>" : "<th>#{f205}</th>"
        h2 += (f206 > 0) ? "<th class='hili'>#{f206}</th>" : "<th>#{f206}</th>"
        h2 += (f207 > 0) ? "<th class='hili'>#{f207}</th>" : "<th>#{f207}</th>"
        h2 += (f208 > 0) ? "<th class='hili'>#{f208}</th>" : "<th>#{f208}</th>"
        h2 += (f209 > 0) ? "<th class='hili'>#{f209}</th>" : "<th>#{f209}</th>"
        h2 += (f210 > 0) ? "<th class='hili'>#{f210}</th>" : "<th>#{f210}</th>"
        h2 += (f211 > 0) ? "<th class='hili'>#{f211}</th>" : "<th>#{f211}</th>"
        h2 += (f212 > 0) ? "<th class='hili'>#{f212}</th>" : "<th>#{f212}</th>"
        h2 += (f213 > 0) ? "<th class='hili'>#{f213}</th>" : "<th>#{f213}</th>"
        h2 += (f214 > 0) ? "<th class='hili'>#{f214}</th>" : "<th>#{f214}</th>"
        h2 += (f215 > 0) ? "<th class='hili'>#{f215}</th>" : "<th>#{f215}</th>"
        h2 += (f216 > 0) ? "<th class='hili'>#{f216}</th>" : "<th>#{f216}</th>"
        h2 += (f217 > 0) ? "<th class='hili'>#{f217}</th>" : "<th>#{f217}</th>"
        if (year.to_i > 49)
          h2 += (f218 > 0) ? "<th class='hili'>#{f218}</th>" : "<th>#{f218}</th>"
          h2 += (f219 > 0) ? "<th class='hili'>#{f219}</th>" : "<th>#{f219}</th>"
          h2 += (f220 > 0) ? "<th class='hili'>#{f220}</th>" : "<th>#{f220}</th>"
          h2 += (f221 > 0) ? "<th class='hili'>#{f221}</th>" : "<th>#{f221}</th>"
          h2 += (f222 > 0) ? "<th class='hili'>#{f222}</th>" : "<th>#{f222}</th>"
          h2 += (f223 > 0) ? "<th class='hili'>#{f223}</th>" : "<th>#{f223}</th>"
          h2 += (f224 > 0) ? "<th class='hili'>#{f224}</th>" : "<th>#{f224}</th>"
          h2 += (f225 > 0) ? "<th class='hili'>#{f225}</th>" : "<th>#{f225}</th>"  
          h2 += (f226 > 0) ? "<th class='hili'>#{f226}</th>" : "<th>#{f226}</th>"
          h2 += (f227 > 0) ? "<th class='hili'>#{f227}</th>" : "<th>#{f227}</th>"
          h2 += (f228 > 0) ? "<th class='hili'>#{f228}</th>" : "<th>#{f228}</th>"
          h2 += (f229 > 0) ? "<th class='hili'>#{f229}</th>" : "<th>#{f229}</th>"
          h2 += (f230 > 0) ? "<th class='hili'>#{f230}</th>" : "<th>#{f230}</th>"
          h2 += (f231 > 0) ? "<th class='hili'>#{f231}</th>" : "<th>#{f231}</th>"
          h2 += (f232 > 0) ? "<th class='hili'>#{f232}</th>" : "<th>#{f232}</th>"
          h2 += (f233 > 0) ? "<th class='hili'>#{f233}</th>" : "<th>#{f233}</th>"
          h2 += (f234 > 0) ? "<th class='hili'>#{f234}</th>" : "<th>#{f234}</th>"
          h2 += (f235 > 0) ? "<th class='hili'>#{f235}</th>" : "<th>#{f235}</th>"
          h2 += (f236 > 0) ? "<th class='hili'>#{f236}</th>" : "<th>#{f236}</th>"
          h2 += (f237 > 0) ? "<th class='hili'>#{f237}</th>" : "<th>#{f237}</th>"
          h2 += (f238 > 0) ? "<th class='hili'>#{f238}</th>" : "<th>#{f238}</th>"
          h2 += (f239 > 0) ? "<th class='hili'>#{f239}</th>" : "<th>#{f239}</th>"
          h2 += (f240 > 0) ? "<th class='hili'>#{f240}</th>" : "<th>#{f240}</th>"
          h2 += (f241 > 0) ? "<th class='hili'>#{f241}</th>" : "<th>#{f241}</th>"
          h2 += (f242 > 0) ? "<th class='hili'>#{f242}</th>" : "<th>#{f242}</th>"
          h2 += (f243 > 0) ? "<th class='hili'>#{f243}</th>" : "<th>#{f243}</th>"
          h2 += (f244 > 0) ? "<th class='hili'>#{f244}</th>" : "<th>#{f244}</th>"
          h2 += (f245 > 0) ? "<th class='hili'>#{f245}</th>" : "<th>#{f245}</th>"
          h2 += (f246 > 0) ? "<th class='hili'>#{f246}</th>" : "<th>#{f246}</th>"
          h2 += (f247 > 0) ? "<th class='hili'>#{f247}</th>" : "<th>#{f247}</th>"
          h2 += (f248 > 0) ? "<th class='hili'>#{f248}</th>" : "<th>#{f248}</th>"
          h2 += (f249 > 0) ? "<th class='hili'>#{f249}</th>" : "<th>#{f249}</th>"
          h2 += (f250 > 0) ? "<th class='hili'>#{f250}</th>" : "<th>#{f250}</th>"
          h2 += (f251 > 0) ? "<th class='hili'>#{f251}</th>" : "<th>#{f251}</th>"
          h2 += (f252 > 0) ? "<th class='hili'>#{f252}</th>" : "<th>#{f252}</th>"
          h2 += (f253 > 0) ? "<th class='hili'>#{f253}</th>" : "<th>#{f253}</th>"
          h2 += (f254 > 0) ? "<th class='hili'>#{f254}</th>" : "<th>#{f254}</th>"
          h2 += (f255 > 0) ? "<th class='hili'>#{f255}</th>" : "<th>#{f255}</th>"
          h2 += (f256 > 0) ? "<th class='hili'>#{f256}</th>" : "<th>#{f256}</th>"
          h2 += (f257 > 0) ? "<th class='hili'>#{f257}</th>" : "<th>#{f257}</th>"
          h2 += (f258 > 0) ? "<th class='hili'>#{f258}</th>" : "<th>#{f258}</th>"
          h2 += (f259 > 0) ? "<th class='hili'>#{f259}</th>" : "<th>#{f259}</th>"
          h2 += (f260 > 0) ? "<th class='hili'>#{f260}</th>" : "<th>#{f260}</th>"
          h2 += (f261 > 0) ? "<th class='hili'>#{f261}</th>" : "<th>#{f261}</th>"
          h2 += (f262 > 0) ? "<th class='hili'>#{f262}</th>" : "<th>#{f262}</th>"
          h2 += (f263 > 0) ? "<th class='hili'>#{f263}</th>" : "<th>#{f263}</th>"
          h2 += (f264 > 0) ? "<th class='hili'>#{f264}</th>" : "<th>#{f264}</th>"
          h2 += (f265 > 0) ? "<th class='hili'>#{f265}</th>" : "<th>#{f265}</th>"
          h2 += (f266 > 0) ? "<th class='hili'>#{f266}</th>" : "<th>#{f266}</th>"
          h2 += (f267 > 0) ? "<th class='hili'>#{f267}</th>" : "<th>#{f267}</th>"
          h2 += (f268 > 0) ? "<th class='hili'>#{f268}</th>" : "<th>#{f268}</th>"
          h2 += (f269 > 0) ? "<th class='hili'>#{f269}</th>" : "<th>#{f269}</th>"
          h2 += (f270 > 0) ? "<th class='hili'>#{f270}</th>" : "<th>#{f270}</th>"
          h2 += (f271 > 0) ? "<th class='hili'>#{f271}</th>" : "<th>#{f271}</th>"
          h2 += (f272 > 0) ? "<th class='hili'>#{f272}</th>" : "<th>#{f272}</th>"
          h2 += (f273 > 0) ? "<th class='hili'>#{f273}</th>" : "<th>#{f273}</th>"
          h2 += (f274 > 0) ? "<th class='hili'>#{f274}</th>" : "<th>#{f274}</th>"
          h2 += (f275 > 0) ? "<th class='hili'>#{f275}</th>" : "<th>#{f275}</th>"
          h2 += (f276 > 0) ? "<th class='hili'>#{f276}</th>" : "<th>#{f276}</th>"
          h2 += (f277 > 0) ? "<th class='hili'>#{f277}</th>" : "<th>#{f277}</th>"
          h2 += (f278 > 0) ? "<th class='hili'>#{f278}</th>" : "<th>#{f278}</th>"
          h2 += (f279 > 0) ? "<th class='hili'>#{f279}</th>" : "<th>#{f279}</th>"
          h2 += (f280 > 0) ? "<th class='hili'>#{f280}</th>" : "<th>#{f280}</th>"
          h2 += (f281 > 0) ? "<th class='hili'>#{f281}</th>" : "<th>#{f281}</th>"
          h2 += (f282 > 0) ? "<th class='hili'>#{f282}</th>" : "<th>#{f282}</th>"
          h2 += (f283 > 0) ? "<th class='hili'>#{f283}</th>" : "<th>#{f283}</th>"
          h2 += (f284 > 0) ? "<th class='hili'>#{f284}</th>" : "<th>#{f284}</th>"
          h2 += (f285 > 0) ? "<th class='hili'>#{f285}</th>" : "<th>#{f285}</th>"
          h2 += (f286 > 0) ? "<th class='hili'>#{f286}</th>" : "<th>#{f286}</th>"
          h2 += (f287 > 0) ? "<th class='hili'>#{f287}</th>" : "<th>#{f287}</th>"
          h2 += (f288 > 0) ? "<th class='hili'>#{f288}</th>" : "<th>#{f288}</th>"
          h2 += (f289 > 0) ? "<th class='hili'>#{f289}</th>" : "<th>#{f289}</th>"
          h2 += (f290 > 0) ? "<th class='hili'>#{f290}</th>" : "<th>#{f290}</th>"
          h2 += (f291 > 0) ? "<th class='hili'>#{f291}</th>" : "<th>#{f291}</th>"
          h2 += (f292 > 0) ? "<th class='hili'>#{f292}</th>" : "<th>#{f292}</th>"
          h2 += (f293 > 0) ? "<th class='hili'>#{f293}</th>" : "<th>#{f293}</th>"
          h2 += (f294 > 0) ? "<th class='hili'>#{f294}</th>" : "<th>#{f294}</th>"
          h2 += (f295 > 0) ? "<th class='hili'>#{f295}</th>" : "<th>#{f295}</th>"
          h2 += (f296 > 0) ? "<th class='hili'>#{f296}</th>" : "<th>#{f296}</th>"
          h2 += (f297 > 0) ? "<th class='hili'>#{f297}</th>" : "<th>#{f297}</th>"
          h2 += (f298 > 0) ? "<th class='hili'>#{f298}</th>" : "<th>#{f298}</th>"
          h2 += (f299 > 0) ? "<th class='hili'>#{f299}</th>" : "<th>#{f299}</th>"
          h2 += (f300 > 0) ? "<th class='hili'>#{f300}</th>" : "<th>#{f300}</th>"
          h2 += (f301 > 0) ? "<th class='hili'>#{f301}</th>" : "<th>#{f301}</th>"
          h2 += (f302 > 0) ? "<th class='hili'>#{f302}</th>" : "<th>#{f302}</th>"
          h2 += (f303 > 0) ? "<th class='hili'>#{f303}</th>" : "<th>#{f303}</th>"
          h2 += (f304 > 0) ? "<th class='hili'>#{f304}</th>" : "<th>#{f304}</th>"
          h2 += (f305 > 0) ? "<th class='hili'>#{f305}</th>" : "<th>#{f305}</th>"
          h2 += (f306 > 0) ? "<th class='hili'>#{f306}</th>" : "<th>#{f306}</th>"
          h2 += (f307 > 0) ? "<th class='hili'>#{f307}</th>" : "<th>#{f307}</th>"
          h2 += (f308 > 0) ? "<th class='hili'>#{f308}</th>" : "<th>#{f308}</th>"
          h2 += (f309 > 0) ? "<th class='hili'>#{f309}</th>" : "<th>#{f309}</th>"
          h2 += (f310 > 0) ? "<th class='hili'>#{f310}</th>" : "<th>#{f310}</th>"
          h2 += (f311 > 0) ? "<th class='hili'>#{f311}</th>" : "<th>#{f311}</th>"
          h2 += (f312 > 0) ? "<th class='hili'>#{f312}</th>" : "<th>#{f312}</th>"
          h2 += (f313 > 0) ? "<th class='hili'>#{f313}</th>" : "<th>#{f313}</th>"
          h2 += (f314 > 0) ? "<th class='hili'>#{f314}</th>" : "<th>#{f314}</th>"
          h2 += (f315 > 0) ? "<th class='hili'>#{f315}</th>" : "<th>#{f315}</th>"
          h2 += (f316 > 0) ? "<th class='hili'>#{f316}</th>" : "<th>#{f316}</th>"
          h2 += (f317 > 0) ? "<th class='hili'>#{f317}</th>" : "<th>#{f317}</th>"
          h2 += (f318 > 0) ? "<th class='hili'>#{f318}</th>" : "<th>#{f318}</th>"
          h2 += (f319 > 0) ? "<th class='hili'>#{f319}</th>" : "<th>#{f319}</th>"
          h2 += (f320 > 0) ? "<th class='hili'>#{f320}</th>" : "<th>#{f320}</th>"
          h2 += (f321 > 0) ? "<th class='hili'>#{f321}</th>" : "<th>#{f321}</th>"
          h2 += (f1to79 > 0) ? "<th class='hili'>#{f1to79}</th>" : "<th>#{f1to79}</th>"
        end
      end
      h2 += "</tr>\n"
    end

    h2 = "#{h2}<tr bgcolor='yellow'><th>&nbsp;</th>><th>&nbsp;</th>><th>&nbsp;</th>><th>&nbsp;</th>"
    h2 += "<th align='right'>Total</th><th>&nbsp;</th><th>&nbsp;</th>"
    gTotal = 0
    (5..320).each do |x|
      gTotal += totalCol[x].to_s.to_i
      h2 += "<th><font color='red'>#{totalCol[x]}</th>"
    end
    h2 += "<th><font color='red'>#{gTotal}</th></tr>\n"
  else
    h1 = "&nbsp;"
    h2 = "<tr></tr>"
  end

  h = h1 if type == '2'
  h = h2 if type == '1'

  h
end
  
def updatePass(user, pass)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE member SET password='#{pass}' "
  sql += "WHERE username='#{user}' "
  res = con.exec(sql)
  con.close
  status = "SUCCESS: User Info was updated!"
end

def updateFname(user, fname)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE member SET fname='#{fname}' "
  sql += "WHERE username='#{user}' "
  res = con.exec(sql)
  con.close
  status = "SUCCESS: User Info was updated!"
end

def updateLname(user, lname)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE member SET lname='#{lname}' "
  sql += "WHERE username='#{user}' "
  res = con.exec(sql)
  con.close
  status = "SUCCESS: Last Name changed!!"
end

def updateTelno(user, telno)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE member SET telno='#{telno}' "
  sql += "WHERE username='#{user}' "
  res = con.exec(sql)
  con.close
  status = "SUCCESS: User Info was updated!"
end

def updateEmail(user, email)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE member SET email='#{email}' "
  sql += "WHERE username='#{user}' "
  res = con.exec(sql)
  con.close
  status = "SUCCESS: User Info was updated!"
end

def getAmpNameFromHcode(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_provid,o_ampid FROM office53 "
  sql += "WHERE o_code='#{hcode}' "
  #log("getAmpName: #{sql}")
  res = con.exec(sql)
  pc = res[0][0].to_s.strip
  hc = res[0][1].to_s.strip
  sql = "SELECT amphoe FROM report2 "
  sql += "WHERE provid='#{pc}' AND ampid='#{hc}' LIMIT 1" 
  res = con.exec(sql)
  numRec = res.num_tuples
  amphoe = 'n/a'
  if numRec > 0
    amphoe = "#{res[0][0].to_s}"
  end
  res.clear
  con.close
  amphoe
end

def getProvName(pcode)
  pcode = pcode.to_s.split('').join('')
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_province FROM prov WHERE o_provid='#{pcode[0..1]}' "
  res = con.exec(sql)
  con.close
  numRec = res.num_tuples
  if (numRec == 0)
    name = "ไม่พบรหัส #{pcode}"
  else
    name = "#{res[0][0].to_s}"
  end
  name
end

def getAmpName(pcode,acode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT amphoe FROM report2 "
  sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  res = con.exec(sql)
  con.close
  numRec = res.num_tuples
  name = "ไม่พบรหัส #{pcode}#{acode}"
  name = "#{res[0][0].to_s}" if numRec > 0
  name
end

def getReporter(user)
  pcode = user[0..1]
  acode = user[2..3]
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT reporter FROM report2 "
  sql += "WHERE provid='#{pcode}' AND ampid='#{acode}'"
  res = con.exec(sql)
  con.close
  reporter = res[0][0]
end

def getProvReporter(id)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT reporter,tel FROM report2 "
  sql += "WHERE provid='#{id}' "
  sql += "AND ampid='00' "
  res = con.exec(sql)
  con.close
  rep = tel = nil
  res.each do |rec|
    rep = rec[0]
    tel = rec[1]
  end
  reporter = "#{rep}|#{tel}"
end

def gpCheck(form,hcode)
  flag = false
  if (form == 1 || form == 5)
    # Check f101001..f101004 / f501001..f501004
    con = PGconn.connect("localhost",5432,nil,nil,"resource53")
    sql = "SELECT f#{form}01001,f#{form}01002,f#{form}01003,f#{form}01004 "
    sql += "FROM form#{form} "
    sql += "WHERE f#{form}hcode='#{hcode}' "
    #log("gpCheck: #{sql}")
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    if (found > 0)
      fx01001 = res[0][0].to_s.to_i
      fx01002 = res[0][1].to_s.to_i
      fx01003 = res[0][2].to_s.to_i
      fx01004 = res[0][3].to_s.to_i
      if (fx01001+fx01002+fx01003+fx01004 > 0)
        flag = true
      end
    end
  end
  flag
end

def ssjCheck(hcode)
  flag = false
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_name FROM office53 WHERE o_code='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  if (found > 0)
    hname = res[0][0]
    if (hname =~ /สสจ/)
      flag = true
    end
  end
  flag
end

def ssoCheck(hcode)
  flag = false
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_name FROM office53 WHERE o_code='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  if (found > 0)
    hname = res[0][0]
    if (hname =~ /สสอ/)
      flag = true
    end
  end
  flag
end

def chkForm4(hcode)
  t = Time.now
  repdate = "#{t.day}/#{t.mon}/#{t.year + 543}"
  flag = ''
  # Check if สสจ. สสอ. ศูนย์วิชาการ
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_office FROM office53 WHERE o_code='#{hcode}' "
  res = con.exec(sql)
  otype = res[0][0]
  if (otype =~ /^สสจ/ || otype =~ /^สสอ/ || otype =~ /^ศูนย์วิชาการ/)
    flag = 'DISABLED'
    #->mark X form form4 of reportmon 
    sql = "UPDATE reportmon SET form4='X',repdate='#{repdate}' "
    sql += "WHERE hcode='#{hcode}' "
    res = con.exec(sql)
  end
  con.close
  flag
end

def chkForm3(hcode)
  flag = ''
  # Check if สสจ. สสอ. สอ.
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_office FROM office53 WHERE o_code='#{hcode}' "
  res = con.exec(sql)
  con.close
  otype = res[0][0]
  if (otype =~ /^สสจ/ || otype =~ /^สสอ/ || otype =~ /^สอ/)
    flag = 'DISABLED'
  end
  flag
end

def chkMD001Form1(hcode)
  # Check f101001
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f101001 FROM form1 "
  sql += "WHERE f1hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  total = (found == 0) ? 0 : res[0][0].to_s.to_i
end

def chkMD002Form1(hcode)
  # Check f101002
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f101002 FROM form1 "
  sql += "WHERE f1hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  total = (found == 0) ? 0 : res[0][0].to_s.to_i
end

def chkMD003Form1(hcode)
  # Check f101003
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f101003 FROM form1 "
  sql += "WHERE f1hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  total = (found == 0) ? 0 : res[0][0].to_s.to_i
end

def chkMD004Form1(hcode)
  # Check f101004
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f101004 FROM form1 "
  sql += "WHERE f1hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  total = (found == 0) ? 0 : res[0][0].to_s.to_i
end

def chkMD001Form5(hcode)
  # Check f501001
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f501001 FROM form5 "
  sql += "WHERE f5hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  total = (found == 0) ? 0 : res[0][0].to_s.to_i
end

def chkMD002Form5(hcode)
  # Check f501002
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f501002 FROM form5 "
  sql += "WHERE f5hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  total = (found == 0) ? 0 : res[0][0].to_s.to_i
end

def chkMD003Form5(hcode)
  # Check f501003
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f501003 FROM form5 "
  sql += "WHERE f5hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  total = (found == 0) ? 0 : res[0][0].to_s.to_i
end

def chkMD004Form5(hcode)
  # Check f501004
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f501004 FROM form5 "
  sql += "WHERE f5hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  total = (found == 0) ? 0 : res[0][0].to_s.to_i
end

def autoCheckForm2(hcode)
  t = Time.now
  repdate = "#{t.year}/#{t.mon}/#{t.year + 543}"
  # Check 'X' in reportmon (form2)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET form2='X' "
  sql += "WHERE hcode='#{hcode}' " 
  res = con.exec(sql)
  con.close
end

def chkOtypeHC(hcode)
  flag = ''
  # Check if สอ. หรือ เทศบาล
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_office,o_name FROM office53 WHERE o_code='#{hcode}' "
  res = con.exec(sql)
  con.close
  otype = res[0][0]
  oname = res[0][1]
  if (otype =~ /^สอ/ || oname =~ /^เทศบาล/)
    flag = 'DISABLED'
  end
  flag
end

def chkHospital(hcode)
  flag = false
  # Check if รพ. รพศ. รพท. รพช. รพร. ==> 'ร%'
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_office FROM office53 WHERE o_code='#{hcode}' "
  res = con.exec(sql)
  con.close
  hospital = res[0][0]
  flag = true if (hospital =~ /^รพ/)
  flag
end
 
def popupMsg(msg)
  n = rand.to_s[5..8]
  h = "<html>\n<body>\n"
  h += "<h4>แสดงข้อความผิดพลาด</h4>"
  h += msg
  h += "<p>"
  h += "<input type='button' value='Back' onclick='history.back()'/>"
  h += "</body>\n</html>\n"
  open("/res53/tmp/popup#{n}.html","w").write(h)
  print "Location:/res53/tmp/popup#{n}.html\n\n"
end

# Functions for TABLE failreport
def checkExist(hcode)
  flag = false
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f_hcode FROM failreport WHERE f_hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  flag = true if (found == 1)
  flag
end

def getFailReport(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM failreport WHERE f_hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  info = Array.new
  res.each do |rec|
    hcode = rec[0]
    reason = rec[1]
    remark = rec[2]
    info.push(reason)
    info.push(remark)
  end
  info
end

def addIncomplete(hcode,reason,remark)
  msg = nil
  chk = checkExist(hcode)
  #log("chk: #{chk}")
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  if (chk) # Exist already
    sql = "UPDATE failreport SET f_reason='#{reason}',f_remark='#{remark}' "
    sql += "WHERE f_hcode='#{hcode}' "
    msg = "1 record updated"
  else
    sql = "INSERT INTO failreport VALUES ('#{hcode}','#{reason}','#{remark}') "
    msg = "1 record added"
  end
  #log("res-06.rb: #{sql}")
  res = con.exec(sql)
  con.close
  msg
end

def getAmpCode(hcode) # return 4 digit amphoe code
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_provid||o_ampid "
  sql += "FROM office53 "
  sql += "WHERE o_code='#{hcode}' "
  #log("getAmpCode: #{sql}")
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  acode = (found == 0) ? 'NA' : res[0][0]
end

def getProvOption(pcode)
  opt = nil
  if (pcode.to_s.length == 0)
    opt = "<option value='00' SELECTED></option>"
  else
    opt = "<option value='00'></option>"
  end
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT provid,province "
  sql += "FROM report1 "
  sql += "WHERE provid < 98 "
  sql += "ORDER BY province"
  #log("getProvOption: #{sql}")
  res = con.exec(sql)
  con.close
  res.each do |rec|
    pc = rec[0]
    pn = rec[1]
    if (pcode.to_s.length == 2 && pcode == pc)
      opt += "<option value='#{pc}' SELECTED>#{pn}</option> "
    else
      opt += "<option value='#{pc}'>#{pn}</option> "
    end
  end
  opt
end

def getAmpOption(pcode)
  opt = "<span id='idAmphoe'></span>"
  if (pcode.to_s.length == 2)
    con = PGconn.connect("localhost",5432,nil,nil,"resource53")
    sql = "SELECT DISTINCT provid, ampid, amphoe "
    sql += "FROM report2 "
    sql += "WHERE provid='#{pcode}' AND ampid<>'00' "
    sql += "ORDER BY ampid"
    res = con.exec(sql)
    con.close

    opt = "<span id='idAmphoe'>อำเภอที่ต้องการ <select name='res-amp'><option></option> "
    res.each do |rec|
      provid = rec[0]
      ampid = rec[1]
      amphoe = rec[2]
      opt += "<option value='#{provid}#{ampid}'>อำเภอ#{amphoe}</option> "
    end
    opt += "</select></span>"
  end
  opt
end

def checkFailreport(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f_hcode FROM failreport WHERE f_hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  flag = (found == 0) ? false : true
end

def checkForm2Allow(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_office,o_type FROM office53 WHERE o_code='#{hcode}' " 
  res = con.exec(sql)
  con.close
  office = res[0][0]
  otype = res[0][1]
  allow = true

  #if (office =~ /สสจ/ || office =~ /รพศ/ || office =~ /รพท/ || office =~ /รพช/ || office =~ /รพร/)
  #  allow = true
  #end

  if ((office =~ /สสอ./) || (office =~ /สอ./))
    allow = false
  end
  allow
end

def checkOwner(user, hcode)
  provid = user[0..1]
  ampid2 = '00'
  if (user.length == 4)
    ampid2 = user[2..3]
  end
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT o_code FROM office53 "
  sql += "WHERE o_code='#{hcode}' AND o_provid='#{provid}' "
  sql += "AND o_ampid2='#{ampid2}' " if (provid != '10')
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  owner = (found == 0) ? false : true
end

def checkOtype(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT o_type FROM office53 "
  sql += "WHERE o_code='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  otype = (found == 1) ? res[0][0] : 'X'
end

def recalReport2(pcode, acode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT stat,count(*) "
  sql += "FROM reportmon "
  sql += "WHERE pcode='#{pcode}' AND acode='#{acode}' "
  sql += "GROUP BY stat"
  res = con.exec(sql)
  con.close
  o = x = 0
  res.each do |rec|
    stat = rec[0]
    count = rec[1].to_i
    if (stat == 'o')
     o = count
    else
     x = count
    end
  end
end

def checkComplete(hcode)
  otype = getOtype(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT form1,form2,form3,form4,form5,form6,form7,form8,pcode,acode "
  sql += "FROM reportmon "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  f1 = f2 = f3 = f4 = f5 = f6 = f7 = f8 = nil
  pcode = acode = nil
  res.each do |rec|
    f1 = rec[0]
    f2 = rec[1]
    f3 = rec[2]
    f4 = rec[3]
    f5 = rec[4]
    f6 = rec[5]
    f7 = rec[6]
    f8 = rec[7]
    pcode = rec[8]
    acode = rec[9]
  end
  complete = false
  if ( 
       (otype == 'M' && f2 == 'X' && f3 == 'X' && f4 == 'X') ||
       #((hcode == '02951' || hcode == '02952') && f2 == 'X' && f3 == 'X' && f4 == 'X') ||
       (otype == 'G' && f1 == 'X' && f2 == 'X' && f3 == 'X' && f4 == 'X') ||
       (otype == 'P' && f5 == 'X' && f6 == 'X' && f7 == 'X' && f8 == 'X')
     )
     complete = true
  end
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")

  # Get old stat if x then no need to increment govt/private in report2
  sql = "SELECT stat FROM chkcomplete WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  oldstat = res[0][0]  

  if (complete) # Update stat from 'o' --> 'x' in chkcomplete
    sql = "UPDATE chkcomplete SET stat='x' "
    sql += "WHERE hcode='#{hcode}' "
  else
    sql = "UPDATE chkcomplete SET stat='o' "
    sql += "WHERE hcode='#{hcode}' "
  end
  res = con.exec(sql)

  # Then update report2 if GM -> govt+1 if P -> private+1
  if (oldstat == 'o' && complete)
    if (otype == 'P')
      sql = "UPDATE report2 SET private = private+1 "
    else
      sql = "UPDATE report2 SET govt = govt+1 "
    end
    sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
    log("report2-sql: #{sql}")
    res = con.exec(sql)

    # Finally, recalc balance
    sql = "UPDATE report2 SET balance = totgovt+totpriv-govt-private "    
    res = con.exec(sql)
  end

  # Then update report1 if GM -> govt+1 if P -> private+1
  if (oldstat == 'o' && complete)
    if (otype == 'P')
      sql = "UPDATE report1 SET private = private+1 "
    else
      sql = "UPDATE report1 SET govt = govt+1 "
    end
    sql += "WHERE provid='#{pcode}' "
    log("report1-sql: #{sql}")
    res = con.exec(sql)

    # Finally, recalc balance
    sql = "UPDATE report1 SET balance = total-govt-private "    
    res = con.exec(sql)
  end
  con.close
end

