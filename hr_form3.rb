#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'res_util.rb'
require 'hr_util.rb'

inpsize = 20
twidth = "40%"
f3 = Array.new

c = CGI::new

user = c['user'].to_s.split('').join('')
sessid = c['sessid']
year = c['year'].to_s.split('').join('')
otype = c['otype'].to_s.split('').join('')
repId = c['offReport'].to_s.split('').join('')
opt = c['opt'].to_s.split('').join('')

flag = checkSession(user,sessid)
if !flag
  print "Location:/res53\n\n"
  exit
end

f1Flag = nil
f2Flag = nil
f3Flag = chkForm3(repId)
statusMsg = "<font color='red'><b>กรุณาตรวจสอบข้อมูลให้ถูกต้องอีกครั้งก่อนกดปุ่ม</b></font>"
statusMsg = "<font color='red'><b>กรอกข้อมูลได้เฉพาะรถพยาบาล (AMBULANCE)<p><u>ถ้าไม่มีให้ใส่เลข 0 แล้วกดปุ่มบันทึกข้อมูล</u></b></font>" if f3Flag == "DISABLED"

moph = nil

if otype == 'M'
  moph = ":กสธ" 
  f1Flag = "DISABLED" 
  f2Flag = "ENABLED" 
  f1BTN = ''
  # 2550 all (M) must fill form2
  #f2BTN = ''
  f2BTN = "<input type=\"button\" value=\"Form 2\" "
  f2BTN += "style=\"width:100%\" onClick=\"document.location.href='hr_form2.rb?"
  f2BTN += "user=#{user}&sessid=#{sessid}&year=2553"
  f2BTN += "&offReport=#{repId}&opt=0&otype=#{otype}'\">"
else
  f1BTN = "<input type=\"button\" value=\"Form 1\" "
  f1BTN += "style=\"width:100%\" onClick=\"document.location.href='hr_form1.rb?"
  f1BTN += "user=#{user}&sessid=#{sessid}&year=2553"
  f1BTN += "&offReport=#{repId}&opt=0&otype=#{otype}'\">"
  f2BTN = "<input type=\"button\" value=\"Form 2\" "
  f2BTN += "style=\"width:100%\" onClick=\"document.location.href='hr_form2.rb?"
  f2BTN += "user=#{user}&sessid=#{sessid}&year=2553"
  f2BTN += "&offReport=#{repId}&opt=0&otype=#{otype}'\">"
end

offId = user.to_s.split('').join('')
member = getMemberName(offId)
provId = offId
province = getProvName(provId)
repName = getOfficeName(repId)

reporter_id = offId
reporter_id = "#{offId}01" if offId.length == 2
reporter_id = "#{offId}00" if offId == '10'
reporter = getReporter(reporter_id)

if opt.to_s == 'DEL'
  delForm3Data(year, repId)
elsif opt.to_s == 'CLEAR'
  clearForm3Data(year, repId)
end

if opt.to_s != 'CLEAR'
  f3 = getForm3Data(year,repId)
end

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<!-- src: hr_form3.rb -->
<head>
  <title>ข้อมูลทรัพยากรสาธารณสุข</title>
</head>

<body text='blue'>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%">#{f1BTN}</td>
      <td width="25%">#{f2BTN}</td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 4" style="width:100%" onClick="document.location.href='hr_form4.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0&otype=#{otype}' "></td>
    </tr>
  </table>
</td>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="30%"><br></td>
      <td width="30%"><br></td>
      <td width="40%">
      <form action="res-02.rb" method="post">
      <input type="hidden" name="user" value="#{user}">
      <input type="hidden" name="sessid" value="#{sessid}">
      <input type="submit" value="&nbsp;&nbsp;เลือกหน่วยงาน&nbsp;&nbsp;" style="width:100%">
      </form>
      </td>
    </tr>
  </table>
</td>
</tr>
</table>
<center>
  <table border='1' width='100%' >
  <tr bgcolor='#9900FF'>
  <th><h3><font color='black'>แบบบันทึกข้อมูลทรัพยากรสาธารณสุข</font>
  <font color='black'><b>&nbsp;(ภาครัฐ#{moph})</b></font><font color='black'>&nbsp;&nbsp;โดย คุณ#{member}
  <br />#{reporter}</font></h3></th>
  </tr>
  </table>
  <h3>ส่วนที่&nbsp;2&nbsp;&nbsp;ครุภัณฑ์การแพทย์ที่มีราคาแพง  ณ 30 กันยายน
  <font color='black'>พ.ศ. </font><font color='black'><b>2553</b></font></h3>
  <form action='form3.rb' method='post'>
  <input type='hidden' name='f3year' value='2553'>
  <input type='hidden' name='f3pname' value='#{province}'>
  <input type='hidden' name='f3pcode' value='#{provId}'>
  <input type='hidden' name='f3hname' value='#{repName}'>
  <input type='hidden' name='f3hcode' value='#{repId}'>
  <p>

  <font color='black'><b>จังหวัด</b></font>&nbsp;<font color='black'><b>#{province}</b></font>
  <font color='black'><b>รหัสจังหวัด</b></font>&nbsp;<font color='black'><b>#{provId[0..1]}</b></font>
  <font color='black'><b>ชื่อหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repName}</b></font></b>
  <font color='black'><b>รหัสหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repId}</b></font>
  <p>

<table border='1' width='80%'>
<tr bgcolor='pink'>
<th colspan='2'>ครุภัณฑ์การแพทย์</th><th colspan='2'>จำนวน</th>
</tr>

<tr bgcolor='beige'>
<th width='5%'>1</th><th align='left'> เครื่องเอ็กซเรย์คอมพิวเตอร์(CT SCAN).............................................</th>
<td width='10%' align='center'><input type='text' name='f301000' 
size='5' value='#{f3[5].to_s}' style='text-align:right;' #{f3Flag}></td>
<th width='10%' align='right'>เครื่อง</th>
</tr>

<tr>
<th>2</th><th align='left'> เครื่องตรวจอวัยวะภายในด้วยสนามแม่เหล็กไฟฟ้า................................</th>
<td align='center'><input type='text' name='f302000' size='5' 
value='#{f3[6].to_s}' style='text-align:right;' #{f3Flag}></td>
<th width='10%' align='right'>เครื่อง</th>
</tr>

<tr bgcolor='beige'>
<th>3</th><th  align = 'left'> เครื่องสลายนิ่ว.............................................................................</th>
<td align='center'><input type='text' name='f303000' size='5' 
value='#{f3[7].to_s}' style='text-align:right;' #{f3Flag}></td>
<th width='10%' align='right'>เครื่อง</th>
</tr>

<tr>
<th>4</th><th align='left'> เครื่องเลเซอร์(เครื่องแกมม่าไนฟ์) .....................................................</th>
<td align='center'><input type='text' name='f304000' size='5' 
value='#{f3[8].to_s}' style='text-align:right;' #{f3Flag}></td>
<th width='10%' align='right'>เครื่อง</th>
</tr>

<tr bgcolor='beige'>
<th>5</th><th align='left'> เครื่องอัลตร้าซาวด์.........................................................................</th>
<td align='center'><input type='text' name='f305000' size='5' 
value='#{f3[9].to_s}' style='text-align:right;' #{f3Flag}></td>
<th width='10%' align='right'>เครื่อง</th>
</tr>

<tr>
<th>6</th><th align='left'> เครื่องล้างไต..................................................................................</th>
<td align='center'><input type='text' name='f306000' size='5' 
value='#{f3[10].to_s}' style='text-align:right;' #{f3Flag}></td>
<th width='10%' align='right'>เครื่อง</th>
</tr>

<tr bgcolor='beige'>
<th>7</th><th align='left'> รถพยาบาล(AMBULANCE)...............................................................</th>
<td align='center'><input type='text' name='f307000' size='5' value='#{f3[11].to_s}' style='text-align:right;'></td>
<th width='10%' align='right'>คัน</th>
</tr>

<tr>
</table>
#{statusMsg}
<p>
<input 
type='submit' value='บันทึกข้อมูล'><input type='button' 
value='ยกเลิก' onClick="document.location.href='hr_form3.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=CLEAR' ">
</form>
<hr>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%">#{f1BTN}</td>
      <td width="25%">#{f2BTN}</td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 4" style="width:100%" onClick="document.location.href='hr_form4.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0&otype=#{otype}' "></td>
    </tr>
  </table>
</td>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="30%"><br></td>
      <td width="30%"><br></td>
      <td width="40%">
      <form action="res-02.rb" method="post">
      <input type="hidden" name="user" value="#{user}">
      <input type="hidden" name="sessid" value="#{sessid}">
      <input type="submit" value="&nbsp;&nbsp;เลือกหน่วยงาน&nbsp;&nbsp;" style="width:100%">
      </form>
      </td>
    </tr>
  </table>
</td>
</tr>
</table>
</center>
</body>
</html>
EOF
