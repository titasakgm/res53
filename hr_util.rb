def log(msg)
  log = open("/tmp/res53.log","a")
  log.write(msg)
  log.write("\n")
  log.close
end

def errMsg(msg)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
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

def chkDigit(fld, val)

  #item = fld[2..3].to_s.to_i
  #sub =(fld[6].chr == '0') ? fld[4..5].to_s.to_i : fld[4..6].to_s.to_i
  #allDigit = true
  #val.to_s.strip.each_byte do |c|
  #  if c.chr < '0' || c.chr > '9'
  #      allDigit = false
  #  end
  
  # New algirothm to check if all input are digit
  #val = val.to_s.strip!
  #allDigit = false
  #if ((val =~ /\d{#{val.to_s.length}}/) || val.nil?)
  #  allDigit = true
  #end

  # Another algorithm 15/10/2010
  len = val.length
  allDigit = (val =~ /\d{#{len}}/) == 0 ? true : false
  errMsg("Error ข้อ #{fld[2..3]}: ข้อมูลต้องเป็นตัวเลขเท่านั้น") if allDigit == false
end

def authenUser(user,pass)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT username FROM member WHERE username='#{user}' and password='#{pass}'"
  res = con.exec(sql)
  numRec = res.num_tuples
  if numRec == 0
    msg = "FAILED"
  else
    msg = "PASS"
  end
  res.clear
  con.close
  msg
end


def checkMemberDup(offId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT username FROM member WHERE username = '#{offId}'"
  res = con.exec(sql)
  numRec = res.num_tuples
  if numRec == 0
    msg = "NODUP"
  else
    msg = "DUP"
  end
  res.clear
  con.close
  msg
end

def getProvNameOld(provId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_province FROM prov WHERE o_provid='#{provId}' "
  res = con.exec(sql)
  numRec = res.num_tuples
  if numRec == 0
    name = "?????????????? #{provId}"
  else
    name = "#{res[0][0].to_s}"
  end
  res.clear
  con.close
  name
end

def getOfficeName(offId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  #sql = "SELECT o_office,o_province FROM office53 WHERE o_code='#{offId}' "
  #New Office ??? o_name.split(',').first ? o_office+o_province
  sql = "SELECT o_name FROM office53 WHERE o_code='#{offId}' "
  sql += "AND o_provid <> '99' "
  res = con.exec(sql)
  numRec = res.num_tuples
  name = 'NA'
  if numRec > 0
    name = res[0][0].to_s.split(',').first
  end
  res.clear
  con.close
  name
end

def getOfficeType(offId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_type FROM office53 WHERE o_code='#{offId}' "
  res = con.exec(sql)
  numRec = res.num_tuples
  oType = "n/a"
  if numRec > 0
    oType = res[0][0].to_s.strip
  end
  res.clear
  con.close
  oType
end

def regStep1

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<head>
<title>????????????????????</title>
</head>

<body text="green">
<form action="/resource/hr_regis.rb">
Step 1: ????????????: <input type="text" name="offId" size="8">
<input type="submit" value="????">
</form>
<p>
<input type="button" value="Goto Login Page" onClick="document.location.href='/resource/hr_login.rb' ">
</body>
</html>
EOF
exit

end

def regStep2(offId, off)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<head>
<title>????????????????????</title>
</head>

<body text="green">
Step 1: ????????????: <font color="red">#{offId}</font>
<p>
EOF

if off.include?("Invalid")
  print "Step 2: <a href=\"/resource/hr_regis.rb\"><input type=\"button\" value=\"????? Step1\"></a>"
else
  print "Step 2: ????????????<p>"
  regStep3(offId, off)
end

end

def regStep3(offId, off)

inpsize = 15
twidth = "60%"

print <<EOF
<hr>
<h2>????????????????????</h2>
<form action="hr_addMember.rb" method="post">
<table border="1" width="#{twidth}" cellpadding="5">
<tr>
<th align="right"><font color="red"><b>*</b></font>?????????:</th>
<td><input type="hidden" name="offId" value="#{offId}">#{offId} : #{off}</td>
</tr>
<tr>
<th align="right"><font color="red"><b>*</b></font>????:</th>
<td><input type="text" name="fname" size="#{inpsize}"></td>
</tr>
<tr>
<th align="right"><font color="red"><b>*</b></font>????-???:</th>
<td><input type="text" name="lname" size="#{inpsize}"></td>
</tr>
<tr>
<th align="right">?????????/?????:</th>
<td><input type="text" name="telno" size="#{inpsize}"></td>
</tr>
<tr>
<th align="right">email:</th>
<td><input type="text" name="email" size="#{inpsize}"></td>
</tr>
<tr>
<th align="right"><font color="red"><b>*</b></font>??????:</th>
<td><input type="password" name="pwd1" size="#{inpsize}"></td>
</tr>
<tr>
<th align="right"><font color="red"><b>*</b></font>??????????:</th>
<td><input type="password" name="pwd2" size="#{inpsize}">
</td>
</tr>
<tr>
<th><br></th>
<td>
<input type="submit" value="???????">
<input type="reset" value="????">
</td>
</tr>
</table>
</form>
<table border="0" width="#{twidth}">
<tr>
<td colspan="2" align="center">?????????????????????????????? <font color="red"><b>*</b></font></td>
</tr>
</table>
EOF

end

def getProvId(offId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_provid FROM office53 WHERE o_code='#{offId}' "
  res = con.exec(sql)
  numRec = res.num_tuples
  office = "n/a"
  if numRec > 0
    office = "#{res[0][0].to_s}"
  end
  res.clear
  con.close
  office
end

def getProvince(provId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_province FROM prov WHERE o_provid='#{provId}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  province = (found == 0) ? 'n/a' : res[0][0]
  province
end

def getAmphoe(provId, ampId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_amphoe FROM office53 WHERE o_provid='#{provId}' "
  sql += "AND o_ampid='#{ampId}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  amphoe = (found == 0) ? 'n/a' : res[0][0]
end

def getMemberName(user)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT fname,lname FROM member WHERE username='#{user}' "
  res = con.exec(sql)
  numRec = res.num_tuples
  name = "n/a"
  if numRec > 0
    name = "#{res[0][0].to_s} #{res[0][1].to_s}"
  end
  name
end

def getAllHosp(provId)
  allHosp = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  #sql = "SELECT o_code,o_office,o_province FROM office53 "
  sql = "SELECT o_code,o_name,o_type FROM office53 "
  sql = sql << "WHERE o_provid='#{provId}' "
  sql = sql << "ORDER BY o_code"
  res = con.exec(sql)
  numRec = res.num_tuples
(0...numRec).each do |n|
    allHosp[n] = "#{res[n][0].to_s}|#{res[n][1].to_s.split(',').first}|#{res[n][2].to_s.strip}"
  end
  res.clear
  con.close
  allHosp
end

def updateReportMon(code,year,form)
  t = Time.now
  dmy = "#{t.day}/#{t.mon}/#{t.year + 543}"
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET #{form}='X',hyear='#{year}',repdate='#{dmy}'  "
  sql = sql << "WHERE hcode='#{code}' "
  res = con.exec(sql)
  res.clear
  con.close
end

def updateReport2(code,form)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT pcode,acode FROM reportmon "
  govt = nil
  if (form.to_i < 5) # 1-4 for Government
    sql += "WHERE form1='X' AND form2='X' AND form3='X' AND form4='X' "
    govt = true
  else # 5-8 for Public
    sql += "WHERE form5='X' AND form6='X' AND form7='X' AND form8='X' "
    govt = false
  end
  sql += "AND hcode='#{code}' "

  log("updateReport2: #{sql}")
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  if (found == 1)
    pcode = res[0][0]
    acode = res[0][1]
    increment(govt,pcode,acode)
  end    
end

def increment(govt, pcode, acode)
  acode = sprintf("%02d", acode.to_i)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  if (govt)
    sql = "UPDATE report2 SET govt=govt+1,balance=total-govt-private "
    sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  else # Private
    sql = "UPDATE report2 SET private=private+1,balance=total-govt-private "
    sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  end
  log("increment: #{sql}")
  res = con.exec(sql)
  con.close
end

def checkDup(fx, fy, fc, year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT #{fc} FROM #{fx} WHERE #{fy}='#{year}' and #{fc}='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  if numRec > 0
    msg = "DUP"
  else
    msg = "NODUP"
  end
  res.clear
  con.close
  msg
end

############
## CLEAR FORM 1-8
############
def clearForm1Data(year, repId)
  f1 = Array.new
(0..172).each do |n|
      f1[n] = ''
  end
end

def clearForm2Data(year, repId)
  f2 = Array.new
(0..200).each do |n|
      f2[n] = ''
  end
end

def clearForm3Data(year, repId)
  f3 = Array.new
(0..11).each do |n|
      f3[n] = ''
  end
end

def clearForm4Data(year, repId)
  f4 = Array.new
(0..19).each do |n|
      f4[n] = ''
  end
end

def clearForm5Data(year, repId)
  f5 = Array.new
(0..172).each do |n|
      f5[n] = ''
  end
end

def clearForm6Data(year, repId)
  f6 = Array.new
(0..200).each do |n|
      f6[n] = ''
  end
end

def clearForm7Data(year, repId)
  f7 = Array.new
(0..11).each do |n|
      f7[n] = ''
  end
end

def clearForm8Data(year, repId)
  f8 = Array.new
(0..19).each do |n|
      f8[n] = ''
  end
end

############
## DEL FORM 1-8
############
def delForm1Data(year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form1 WHERE f1year='#{year}' and f1hcode='#{repId}'  "
  res = con.exec(sql)
  res.clear
  con.close
end

def delForm2Data(year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form2 WHERE f2year='#{year}' and f2hcode='#{repId}'  "
  res = con.exec(sql)
  res.clear
  con.close
end

def delForm3Data(year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form3 WHERE f3year='#{year}' and f3hcode='#{repId}'  "
  res = con.exec(sql)
  res.clear
  con.close
end

def delForm4Data(year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form4 WHERE f4year='#{year}' and f4hcode='#{repId}'  "
  res = con.exec(sql)
  res.clear
  con.close
end

def delForm5Data(year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form5 WHERE f5year='#{year}' and f5hcode='#{repId}'  "
  res = con.exec(sql)
  res.clear
  con.close
end

def delForm6Data(year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form6 WHERE f6year='#{year}' and f6hcode='#{repId}'  "
  res = con.exec(sql)
  res.clear
  con.close
end

def delForm7Data(year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form7 WHERE f7year='#{year}' and f7hcode='#{repId}'  "
  res = con.exec(sql)
  res.clear
  con.close
end

def delForm8Data(year, repId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form8 WHERE f8year='#{year}' and f8hcode='#{repId}'  "
  res = con.exec(sql)
  res.clear
  con.close
end

############
## GET FORM 1-8
############
def getForm1Data(year, repId)
  f1 = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form1 WHERE f1year='#{year}' and f1hcode='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  numSize = 173
  if numRec > 0
    (0..numSize-1).each do |n|
      f1[n] = res[0][n].to_s
      f1[n] = '&nbsp;' if (f1[n] == nil)
    end
  end
  res.clear
  con.close
  f1
end

def getForm2Data(year, repId)
  f2 = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form2 WHERE f2year='#{year}' and f2hcode='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  numSize = 321
  if numRec > 0
    (5..numSize-1).each do |n|
      f2[n] = res[0][n].to_s
      f2[n] = '&nbsp;' if (f2[n] == nil)
    end
  end
  res.clear
  con.close
  f2
end

def getForm3Data(year, repId)
  f3 = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form3 WHERE f3year='#{year}' and f3hcode='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  numSize = 12
  if numRec > 0
    (0..numSize-1).each do |n|
      f3[n] = res[0][n].to_s
      f3[n] = '&nbsp;' if (f3[n] == nil)
    end
  end
  res.clear
  con.close
  f3
end

def getForm4Data(year, repId)
  f4 = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form4 WHERE f4year='#{year}' and f4hcode='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  numSize = 20
  if numRec > 0
    (0..numSize-1).each do |n|
      f4[n] = res[0][n].to_s
      f4[n] = '&nbsp;' if (f4[n] == nil)
    end
  end
  res.clear
  con.close
  f4
end

def getForm5Data(year, repId)
  f5 = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form5 WHERE f5year='#{year}' and f5hcode='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  numSize = 173
  if numRec > 0
    (0..numSize-1).each do |n|
      f5[n] = res[0][n].to_s
      f5[n] = '&nbsp;' if (f5[n] == nil)
    end
  end
  res.clear
  con.close
  f5
end

def getForm6Data(year, repId)
  f6 = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form6 WHERE f6year='#{year}' and f6hcode='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  numSize = 321
  if numRec > 0
    (0..numSize-1).each do |n|
      f6[n] = res[0][n].to_s
      f6[n] = '&nbsp;' if (f6[n] == nil)
    end
  end
  res.clear
  con.close
  f6
end

def getForm7Data(year, repId)
  f7 = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form7 WHERE f7year='#{year}' and f7hcode='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  numSize = 12
  if numRec > 0
    (0..numSize-1).each do |n|
      f7[n] = res[0][n].to_s
      f7[n] = '&nbsp;' if (f7[n] == nil)
    end
  end
  res.clear
  con.close
  f7
end

def getForm8Data(year, repId)
  f8 = Array.new
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form8 WHERE f8year='#{year}' and f8hcode='#{repId}'  "
  res = con.exec(sql)
  numRec = res.num_tuples
  numSize = 20
  if numRec > 0
    (0..numSize-1).each do |n|
      f8[n] = res[0][n].to_s
      f8[n] = '&nbsp;' if (f8[n] == nil)
    end
  end
  res.clear
  con.close
  f8
end

def getStat(provId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_code FROM office53 WHERE o_provid='#{provId}' "
  res = con.exec(sql)
  numTotal = res.num_tuples
  sql = "SELECT hcode FROM reportmon WHERE pcode='#{provId}' "
  sql = sql << "AND((form1='X' and form2='X' and form3='X' and form4='X') "
  sql = sql << "OR(form5='X' and form6='X' and form7='X' and form8='X') )"
  res = con.exec(sql)
  numFinish = res.num_tuples
  res.clear
  con.close
  info = "จำนวนหน่วยงานทั้งหมด #{numTotal}<br>กรอกรายงานเสร็จแล้ว #{numFinish}<br>คงเหลือ  #{numTotal - numFinish}"
  info
end

def checkFinish(offId)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT hcode FROM reportmon WHERE hcode='#{offId}' "
  sql = sql << "AND((form1='X' and form2='X' and form3='X' and form4='X') "
  sql = sql << "OR(form5='X' and form6='X' and form7='X' and form8='X') )"
  res = con.exec(sql)
  numFinish = res.num_tuples
  msg = 'NO'
  if numFinish == 1
    msg = 'YES'
  end
  res.clear
  con.close
  msg
end

def checkAdminPwd(pwd)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT adm_pwd FROM admin"
  res = con.exec(sql)
  admpwd = res[0][0].to_s
  authen = 'FAIL'
  if pwd == admpwd
    authen = 'PASS'
  end
  res.clear
  con.close
  authen
end

def getUserInfo(user)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT password,office,fname,lname,telno,email FROM member "
  sql = sql << "WHERE username='#{user}' "
  res = con.exec(sql)
  numRec = res.num_tuples
  info = 'n/a|n/a|n/a|n/a|n/a|n/a'
  if numRec == 1
    pwd = res[0][0].to_s
    off = res[0][1].to_s
    fna = res[0][2].to_s
    lna = res[0][3].to_s
    tel = res[0][4].to_s
    ema = res[0][5].to_s
    info = "#{pwd}|#{off}|#{fna}|#{lna}|#{tel}|#{ema}"
  end
  res.clear
  con.close
  info
end

def getOfficeInfo(offID)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_name,o_province,o_office,o_provid,o_type,m_desc "
  sql += "FROM office53,minisid "
  sql += "WHERE o_code='#{offID}' AND o_minisid=m_code"
  res = con.exec(sql)
  numRec = res.num_tuples
  info = 'n/a|n/a|n/a|n/a|n/a|n/a|n/a'
  if numRec == 1
    ona = res[0][0].to_s
    opr = res[0][1].to_s
    oof = res[0][2].to_s
    opi = res[0][3].to_s
    oty = res[0][4].to_s
    omn = res[0][5].to_s
    info = "#{ona}|#{opr}|#{oof}|#{opi}|#{oty}|#{omn}"
  end
  res.clear
  con.close
  info
end

def checkMember(user)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT username FROM member WHERE username='#{user}'"
  res = con.exec(sql)
  numRec = res.num_tuples
  res.clear
  con.close
  status =(numRec > 0) ? 'OLD' : 'NEW'
  status
end

def checkOffice(offID)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_code FROM office53 WHERE o_code='#{offID}' "
  sql += "AND o_provid <> '99' "
  res = con.exec(sql)
  numRec = res.num_tuples
  res.clear
  con.close
  status =(numRec > 0) ? 'OLD' : 'NEW'
  status
end

def checkXForm2(hcode)
  t = Time.now
  repdate = "#{t.day}/#{t.mon}/#{t.year + 543}"
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET form2='X',repdate='#{repdate}' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

def checkXForm6(hcode)
  t = Time.now
  repdate = "#{t.day}/#{t.mon}/#{t.year + 543}"
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET form6='X',repdate='#{repdate}' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

def deleteF14(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form1 WHERE f1hcode='#{hcode}' "
  res = con.exec(sql)
  sql = "DELETE FROM form2 WHERE f2hcode='#{hcode}' "
  res = con.exec(sql)
  sql = "DELETE FROM form3 WHERE f3hcode='#{hcode}' "
  res = con.exec(sql)
  sql = "DELETE FROM form4 WHERE f4hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

def deleteF58(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM form5 WHERE f5hcode='#{hcode}' "
  res = con.exec(sql)
  sql = "DELETE FROM form6 WHERE f6hcode='#{hcode}' "
  res = con.exec(sql)
  sql = "DELETE FROM form7 WHERE f7hcode='#{hcode}' "
  res = con.exec(sql)
  sql = "DELETE FROM form8 WHERE f8hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

def deleteReportmon(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "DELETE FROM reportmon WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

def updateReportmon(hcode,pcode,acode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT hcode FROM reportmon "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  found = res.num_tuples
  if (found == 0) # -> add a new entry
    sql = "INSERT INTO reportmon (hcode,pcode,acode) "
    sql += "VALUES ('#{hcode}','#{pcode}','#{acode}') "
  else
    sql = "UPDATE reportmon "
    sql += "SET pcode='#{pcode}',acode='#{acode}' "
    sql += "WHERE hcode='#{hcode}' "
  end
  res = con.exec(sql)
  con.close
end

