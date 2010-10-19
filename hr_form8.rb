#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'res_util.rb'
require 'hr_util.rb'

inpsize = 20
twidth = "40%"
f8 = Array.new

s00 = s01 = s02 =s03 = s04 = s05 = s06 = s07 = s08 = s09 = s10 = nil
s11 = s12 =s13 = s14 = s15 = s16 = s17 = s18 = s19 = s20 = s21 = nil
s22 = s23 = s24 = s25 = s26 = s27 = s99 = nil

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
  delForm8Data(year, repId)
elsif opt.to_s == 'CLEAR'
  clearForm8Data(year, repId)
end

if opt.to_s != 'CLEAR'
  f8 = getForm8Data(year,repId)
  case f8[5]
    when '00' then s00 = 'selected'
    when '01' then s01 = 'selected'
    when '02' then s02 = 'selected'
    when '03' then s03 = 'selected'
    when '04' then s04 = 'selected'
    when '05' then s05 = 'selected'
    when '06' then s06 = 'selected'
    when '07' then s07 = 'selected'
    when '08' then s08 = 'selected'
    when '09' then s09 = 'selected'
    when '10' then s10 = 'selected'
    when '11' then s11 = 'selected'
    when '12' then s12 = 'selected'
    when '13' then s13 = 'selected'
    when '14' then s14 = 'selected'
    when '15' then s15 = 'selected'
    when '16' then s16 = 'selected'
    when '17' then s17 = 'selected'
    when '18' then s18 = 'selected'
    when '19' then s19 = 'selected'
    when '20' then s20 = 'selected'
    when '21' then s21 = 'selected'
    when '22' then s22 = 'selected'
    when '23' then s23 = 'selected'
    when '24' then s24 = 'selected'
    when '25' then s25 = 'selected'
    when '26' then s26 = 'selected'
    when '27' then s27 = 'selected'
    when '99' then s99 = 'selected'
  end
end

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<head >
      <title>ข้อมูลทรัพยากรสาธารณสุข</title>
</head>

<body text = 'blue'>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" onClick="document.location.href='hr_form5.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" onClick="document.location.href='hr_form6.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" onClick="document.location.href='hr_form7.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 4" style="width:100%" disabled></td>
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

  <form action='form8.rb' method='post'>
  <input type='hidden' name='f8year' value='2553'>
  <input type='hidden' name='f8pname' value='#{province}'>
  <input type='hidden' name='f8pcode' value='#{provId}'>
  <input type='hidden' name='f8hname' value='#{repName}'>
  <input type='hidden' name='f8hcode' value='#{repId}'>
  <h3>ส่วนที่&nbsp;3&nbsp;&nbsp; การให้บริการของสถานบริการ
  <font color='black'>&nbsp;&nbsp; ช่วงปีงบประมาณ</font>&nbsp;&nbsp;
  <font color='black'>พ.ศ. </font><font color='black'><b>2553</b></font></h3>
  <p>
  <font color='black'><b>จังหวัด</b></font>&nbsp;<font color='black'><b>#{province}</b></font>
  <font color='black'><b>รหัสจังหวัด</b></font>&nbsp;<font color='black'><b>#{provId[0..1]}</b></font>
  <font color='black'><b>ชื่อหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repName}</b></font></b>
  <font color='black'><b>รหัสหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repId}</b></font>
  <p>
<h3 align = 'left'>1.   ประเภทการให้บริการ&nbsp;&nbsp;&nbsp;&nbsp;
<select name='f801010'>
<option value='00' #{s00}>ทั่วไป
<option value='01' #{s01}>กามโรคและโรคเอดส์
<option value='02' #{s02}>กายภาพบำบัด
<option value='03' #{s03}>กุมารเวช
<option value='04' #{s04}>จักษุ
<option value='05' #{s05}>จิตวิทยา/ปัญญาอ่อน
<option value='06' #{s06}>เซลล์วิทยา
<option value='07' #{s07}>ทันตกรรม
<option value='08' #{s08}>บำบัดยาเสพติด
<option value='09' #{s09}>ประสาท
<option value='10' #{s10}>ผิวหนัง
<option value='11' #{s11}>มาเลเรีย
<option value='12' #{s12}>แม่และเด็ก(ส่งเสริมอนามัย)
<option value='13' #{s13}>โรคเขตร้อน
<option value='14' #{s14}>โรคติดต่อทั่วไป
<option value='15' #{s15}>โรคเท้าช้าง
<option value='16' #{s16}>โรคมะเร็ง
<option value='17' #{s17}>โรคไม่ติดต่อ
<option value='18' #{s18}>โรคเรื้อน
<option value='19' #{s19}>วัณโรค โรคปอด
<option value='20' #{s20}>วางแผนครอบครัว
<option value='21' #{s21}>ศัลยกรรม
<option value='22' #{s22}>ส่งเสริมสุขภาพ
<option value='23' #{s23}>สูติ
<option value='24' #{s24}>โสต
<option value='25' #{s25}>ศอ นาสิก
<option value='26' #{s26}>อาชีวบำบัด
<option value='27' #{s27}>อายุรกรรม
<option value='99' #{s99}>ไม่ระบุ
</select>
 


     <h3 align = 'left'>2.  การให้บริการของสถานบริการปีงบประมาณ(ตั้งแต่วันที่ 1 ตุลาคม - 30 กันยายน)</h3>
     

     <table border='1' width='100%' >

     <tr bgcolor= 'pink'>
     <th>รายการ</th><th>หน่วยนับ</th><th>จำนวน</th>
     </tr>

    <tr bgcolor='beige'>
    <th align='left'>2.1 จำนวนเตียงผู้ป่วย</th>
    <td ><input type='text' size='7' style='text-align:right'  name='f802010' value='#{f8[8].to_s}'></td>
    <th>เตียง</th>
    </tr>

    <tr>
    <th align='left'>2.2 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) ศัลยกรรม</th>
    <td><input type='text' size='7' style='text-align:right' name='f802020' value='#{f8[9].to_s}'></td>
    <th>เตียง</th>
    </tr>

    <tr bgcolor='beige'>
    <th align='left'> 2.3 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) อายุรกรรม</th>
    <td><input type='text' size='7' style='text-align:right' name='f802030' value='#{f8[10].to_s}'></td>
    <th>เตียง</th>
    </tr>

    <tr>
    <th align='left'>2.4 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) กุมารเวชกรรม</th>
    <td><input type='text' size='7' style='text-align:right' name='f802040' value='#{f8[11].to_s}'></td>
    <th>เตียง</th>  
    </tr>

    <tr bgcolor='beige'>
    <th align='left'>2.5 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) สูติ-นารีเวชกรรม</th>
    <td><input type='text' size='7' style='text-align:right' name='f802050' value='#{f8[12].to_s}'></td>
    <th>เตียง</th>  
    </tr>

    <tr>
    <th align='left'>2.6 จำนวนเตียงผู้ป่วยหนัก(I.C.U.) รวม</th>
    <td><input type='text' size='7' style='text-align:right' name='f802060' value='#{f8[13].to_s}'></td>
    <th>เตียง</th>  
    </tr>

    <tr bgcolor='beige'>
    <th align='left'>2.7 จำนวนผู้ป่วยนอกใหม่ที่มารับบริการครั้งแรกของปี</th>
    <td><input type='text' size='7' style='text-align:right' name='f802070' value='#{f8[14].to_s}'></td>
    <th>คน</th>  
    </tr>     

    <tr>
    <th align='left'>2.8 จำนวนผู้ป่วยนอกทั้งหมดที่มารับบริการ</th>
    <td><input type='text' size='7' style='text-align:right' name='f802080' value='#{f8[15].to_s}'></td>
    <th>ครั้ง</th>  
    </tr> 

    <tr bgcolor='beige'>
    <th align='left'>2.9 จำนวนผู้รับบริการอื่น ๆที่มารับบริการครั้งแรก</th>
    <td><input type='text' size='7' style='text-align:right' name='f802090' value='#{f8[16].to_s}'></td>
    <th>คน</th>  
    </tr>

    <tr>
    <th align='left'>2.10 จำนวนผู้รับบริการอื่น ๆ ที่มารับบริการทั้งหมด</th>
    <td><input type='text' size='7' style='text-align:right' name='f802100' value='#{f8[17].to_s}'></td>
    <th>ครั้ง</th>  
    </tr>

    <tr bgcolor='beige'>
    <th align='left'>2.11 จำนวนผู้ป่วยใน</th>
    <td><input type='text'size='7' style='text-align:right' name='f802110' value='#{f8[18].to_s}'></td>
    <th>ราย</th>  
    </tr>

    <tr>
    <th align='left'>2.12 จำนวนวันอยู่ในโรงพยาบาล(Patient day)ของผู้ป่วยในทั้งหมด</th>
    <td><input type='text' size='7' style='text-align:right' name='f802120' value='#{f8[19].to_s}'></td>
    <th>วัน</th>  
    </tr>
</table>                
<center>
<font color='black'><b>กรุณาตรวจสอบข้อมูลให้ถูกต้องอีกครั้งก่อนกดปุ่ม</b></font>
<p>
<input type='submit' value='บันทึกข้อมูล'><input type='button' 
value='ยกเลิก' onClick="document.location.href='hr_form8.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=CLEAR' ">
</form>
</center>
<hr>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" onClick="document.location.href='hr_form5.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" onClick="document.location.href='hr_form6.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" onClick="document.location.href='hr_form7.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 4" style="width:100%" disabled></td>
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
