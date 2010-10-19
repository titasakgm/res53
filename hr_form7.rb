#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'res_util.rb'
require 'hr_util.rb'

inpsize = 20
twidth = "40%"
f7 = Array.new

c = CGI::new

user = c['user'].to_s.split('').join('')
sessid = c['sessid']
year = c['year'].to_s.split('').join('')
repId = c['offReport'].to_s.split('').join('')
opt = c['opt'].to_s.split('').join('')

flag = checkSession(user,sessid)
if !flag
  print "Location:/res53\n\n"
  exit
end

offId = user.to_s
member = getMemberName(offId)
provId = offId
province = getProvName(provId)
repName = getOfficeName(repId)

reporter_id = offId
reporter_id = "#{offId}01" if offId.length == 2
reporter_id = "#{offId}00" if offId == '10'
reporter = getReporter(reporter_id)

if opt.to_s == 'DEL'
  delForm7Data(year, repId)
elsif opt.to_s == 'CLEAR'
  clearForm7Data(year, repId)
end

if opt.to_s != 'CLEAR'
  f7 = getForm7Data(year,repId)
end

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<!-- src: hr_form7.rb -->
<head>
  <title>ข้อมูลทรัพยากรสาธารณสุข</title>
</head>

<body text='blue'>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" onClick="document.location.href='hr_form5.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" onClick="document.location.href='hr_form6.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 4" style="width:100%" onClick="document.location.href='hr_form8.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
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
     <tr bgcolor='blue'>
     <th><h3><b><font color='black'>แบบบันทึกข้อมูลทรัพยากรสาธารณสุข</font>
     <font color= 'yellow'>&nbsp;(ภาคเอกชน)</b></font><font color='black'>&nbsp;&nbsp;โดย คุณ#{member}
     <br />#{reporter}</font></h3></th>
     </tr>
     </table>

  <form action='form7.rb' method='post'>
  <input type='hidden' name='f7year' value='2553'>
  <input type='hidden' name='f7pname' value='#{province}'>
  <input type='hidden' name='f7pcode' value='#{provId}'>
  <input type='hidden' name='f7hname' value='#{repName}'>
  <input type='hidden' name='f7hcode' value='#{repId}'>
  <font size='4'><b>ส่วนที่&nbsp;2&nbsp;&nbsp;ครุภัณฑ์การแพทย์ที่มีราคาแพง  ณ 30 กันยายน</b></font>
  <font color='black'>พ.ศ. </font><font color='black'><b>2553</b></font><br>
  <p>

  <font color='black'><b>จังหวัด</b></font>&nbsp;<font color='black'><b>#{province}</b></font>
  <font color='black'><b>รหัสจังหวัด</b></font>&nbsp;<font color='black'><b>#{provId[0..1]}</b></font>
  <font color='black'><b>ชื่อหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repName}</b></font></b>
  <font color='black'><b>รหัสหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repId}</b></font>
  <p>
<table border='1' width='80%'>
<tr bgcolor='pink'>
<th colspan='2'>ครุภัณฑ์การแพทย์</th><th colspan='1'>จำนวน</th>
</tr>

<tr bgcolor='beige'>
<th>1</th><th align = 'left'> เครื่องเอ็กซเรย์คอมพิวเตอร์(CT SCAN).............................................&nbsp;&nbsp;&nbsp;เครื่อง</th>
<td><input type='text' size='10' style='text-align: right' name='f701000' value='#{f7[5].to_s}'></td>
</tr>

<tr>
<th>2</th><th  align = 'left'> เครื่องตรวจอวัยวะภายในด้วยสนามแม่เหล็กไฟฟ้า................................&nbsp;&nbsp;&nbsp;เครื่อง</th>
<td><input type='text' size='10' style='text-align: right' name='f702000' value='#{f7[6].to_s}'></td>
</tr>

<tr bgcolor='beige'>
<th>3</th><th  align = 'left'> เครื่องสลายนิ่ว...................................................................................&nbsp;&nbsp;&nbspเครื่อง</th>
<td><input type='text' size='10' style='text-align: right' name='f703000' value='#{f7[7].to_s}'></td>
</tr>

<tr>
<th>4</th><th  align = 'left'> เครื่องเลเซอร์(เครื่องแกมม่าไนฟ์).......................................................&nbsp;&nbsp;&nbspเครื่อง</th>
<td><input type='text' size='10' style='text-align: right' name='f704000' value='#{f7[8].to_s}'></td>
</tr>

<tr bgcolor='beige'>
<th>5</th><th  align = 'left'> เครื่องอัลตร้าซาวด์.............................................................................&nbsp;&nbsp;&nbspเครื่อง</th>
<td><input type='text' size='10' style='text-align: right' name='f705000' value='#{f7[9].to_s}'></td>
</tr>

<tr>
<th>6</th><th  align = 'left'> เครื่องล้างไต......................................................................................&nbsp;&nbsp;&nbspเครื่อง</th>
<td><input type='text' size='10' style='text-align: right' name='f706000' value='#{f7[10].to_s}'></td>
</tr>

<tr bgcolor='beige'>
<th>7</th><th  align = 'left'> รถพยาบาล(AMBULANCE).....................................................................&nbsp;&nbsp;&nbspคัน </th>
<td><input type='text' size='10' style='text-align: right' name='f707000' value='#{f7[11].to_s}'></td>
</tr>

<tr>
</table>
<font color='black'><b>กรุณาตรวจสอบข้อมูลให้ถูกต้องอีกครั้งก่อนกดปุ่ม</b></font>
<p>
<input type='submit' value='บันทึกข้อมูล'><input type='button' value='ยกเลิก' onClick="document.location.href='hr_form7.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=CLEAR' ">
</form>
<hr>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" onClick="document.location.href='hr_form5.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" onClick="document.location.href='hr_form6.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 4" style="width:100%" onClick="document.location.href='hr_form8.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
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
