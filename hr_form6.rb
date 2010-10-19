#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'res_util.rb'
require 'hr_util.rb'

inpsize = 20
twidth = "40%"

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

flagGP = gpCheck(5,repId)

gpFlag = "DISABLED"
statusMsg = "<font color='red'><b>กรุณาตรวจสอบข้อมูลให้ถูกต้องอีกครั้งก่อนกดปุ่ม</b></font>"
if (flagGP)
  gpFlag = nil
else
  statusMsg = "<font color='red'><b>จำนวนแพทย์ใน FORM 1 เป็น 0 ไม่สามารถบันทึก FORM 2 ได้</b>"
  statusMsg += "<br />กรุณา key 0 ใส่ช่องบนซ้าย แล้วกดปุ่มบันทึกข้อมูล</font>"
end

if opt.to_s == 'DEL'
  delForm6Data(year, repId)
elsif opt.to_s == 'CLEAR'
  clearForm6Data(year, repId)
end

if opt.to_s != 'CLEAR'
  f6 = getForm6Data(year,repId)
  if (flagGP==false) # form6 f601001=f601002=f601003=f601004=0
    (5..321).each do |n|
      f6[n] = ' '
    end
  end
end

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<!-- src: hr_form6.rb -->
<head>
<title>ข้อมูลทรัพยากรสาธารณสุข</title>
<script>
function enableSubmit()
{
  var val1 = document.getElementById('f601001').value;
  var val2 = document.getElementById('f601002').value;
  var val3 = document.getElementById('f601003').value;
  var val4 = document.getElementById('f601004').value;
  if (val1 == 0 || val2 == 0 || val3 == 0 || val4 == 0)
  {
    document.getElementById('f6submit').disabled = false;
  }
}
</script>

</head>

<body text='blue'>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" onClick="document.location.href='hr_form5.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" onClick="document.location.href='hr_form7.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
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
  <th><h3><font color='black'><b>แบบบันทึกข้อมูลทรัพยากรสาธารณสุข</b></font>
  <font color='black'><b>&nbsp;(ภาคเอกชน)</b></font><font color='black'>&nbsp;&nbsp;โดย คุณ#{member}
  <br />#{reporter}</font></h3></th>
  </tr>
  </table>
  <h3>ส่วนที่&nbsp;1&nbsp;&nbsp;บุคลากรทางการแพทย์และสาธารณสุข</h3>
  <h4><font color='red'>ข้อ20  สาขารังสีวิทยาทั่วไป
      มีอนุสาขาตั้งแต่ข้อ 25-28</font></h4>
  <h4><font color='red'>ข้อ21 สาขารังสีวิทยาวินิจฉัย
      มีอนุสาขาตั้งแต่ข้อ 29-32</font></h4>
  <form action='form6.rb' method='post'>
  <input type='hidden' name='f6year' value='2553'>
  <input type='hidden' name='f6pname' value='#{province}'>
  <input type='hidden' name='f6pcode' value='#{provId}'>
  <input type='hidden' name='f6hname' value='#{repName}'>
  <input type='hidden' name='f6hcode' value='#{repId}'>
  <font size='4'><b>ตารางที่ 2: &nbsp;จำนวน<font color='black'><b>แพทย์ที่ศึกษาต่อเฉพาะทาง</b></font>จำแนกตามวุฒิบัตรหรือหนังสืออนุมัติความเชี่ยวชาญ</b></font><br>
  <font size='2'><b>เฉพาะทางจากแพทยสภา &nbsp; ณ 30 กันยายน&nbsp;</font>
  <font color='black'>พ.ศ. </font><font color='black'><b>2553</b></font><br>
  <p>

  <font color='black'><b>จังหวัด</b></font>&nbsp;<font color='black'><b>#{province}</b></font>
  <font color='black'><b>รหัสจังหวัด</b></font>&nbsp;<font color='black'><b>#{provId[0..1]}</b></font>
  <font color='black'><b>ชื่อหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repName}</b></font></b>
  <font color='black'><b>รหัสหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repId}</b></font>
  <p>

  <table border='1' width=100%>
  <tr bgcolor='pink'>
     <th rowspan='3'>ลำดับ</th><th rowspan='3'>ความเชี่ยวชาญเฉพาะทาง</th><th colspan='4'>จำนวน(คน)</th>
     <th rowspan='3'>ลำดับ</th><th rowspan='3'>ความเชี่ยวชาญเฉพาะทาง</th><th colspan='4'>จำนวน(คน)</th>
  </tr>
  <tr bgcolor='pink'>
     <th colspan='2'>Full Time</th><th colspan='2'>Part Time</th>
     <th colspan='2'>Full Time</th><th colspan='2'>Part Time</th>
  </tr>
  <tr bgcolor='pink'>
    <th>ช</th><th>ญ</th><th>ช</th><th>ญ</th>
    <th>ช</th><th>ญ</th><th>ช</th><th>ญ</th>
  </tr>
  <tr bgcolor='beige'>
    <th>1</th><th align='left'>กุมารเวชศาสตร์โรคหัวใจ</th>
    <td><input type='text' size='3' style='text-align: right' name='f601001' id='f601001'
        value='#{f6[5].to_s}' onchange='enableSubmit()'></td>
    <td><input type='text' size='3' style='text-align: right' name='f601002' id='f601002'
        value='#{f6[6].to_s}' onchange='enableSubmit()'></td>
    <td><input type='text' size='3' style='text-align: right' name='f601003' id='f601003'
        value='#{f6[7].to_s}' onchange='enableSubmit()'></td>
    <td><input type='text' size='3' style='text-align: right' name='f601004' id='f601004'
        value='#{f6[8].to_s}' onchange='enableSubmit()'></td>
    <th>41</th><th align='left'>แขนงเวชศาสตร์ป้องกันคลินิก</th>
    <td><input type='text' size='3' style='text-align: right' name='f641001' value='#{f6[165].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f641002' value='#{f6[166].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f641003' value='#{f6[167].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f641004' value='#{f6[168].to_s}'></td>
  </tr>
  <tr>
    <th>2</th><th align='left'>กุมารเวชศาสตร์โรคระบบการหายใจ</th>
    <td><input type='text' size='3' style='text-align: right' name='f602001' value='#{f6[9].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f602002' value='#{f6[10].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f602003' value='#{f6[11].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f602004' value='#{f6[12].to_s}'></td>
    <th>42</th><th align='left'>แขนงเวชศาสตร์การบิน</th>
    <td><input type='text' size='3' style='text-align: right' name='f642001' value='#{f6[169].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f642002' value='#{f6[170].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f642003' value='#{f6[171].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f642004' value='#{f6[172].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>3</th><th align='left'>กุมารเวชศาสตร์โรคต่อมไร้ท่อและเมตาบอลิสม</th>
    <td><input type='text' size='3' style='text-align: right' name='f603001' value='#{f6[13].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f603002' value='#{f6[14].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f603003' value='#{f6[15].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f603004' value='#{f6[16].to_s}'></td>
    <th>43</th><th align='left'>แขนงอาชีวเวชศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f643001' value='#{f6[173].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f643002' value='#{f6[174].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f643003' value='#{f6[175].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f643004' value='#{f6[176].to_s}'></td>
  </tr>
  <tr>
    <th>4</th><th align='left'>กุมารเวชศาสตร์พัฒนาการและพฤติกรรม</th>
    <td><input type='text' size='3' style='text-align: right' name='f604001' value='#{f6[17].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f604002' value='#{f6[18].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f604003' value='#{f6[19].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f604004' value='#{f6[20].to_s}'></td>
    <th>44</th><th align='left'>แขนงสุขภาพจิตชุมชน</th>
    <td><input type='text' size='3' style='text-align: right' name='f644001' value='#{f6[177].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f644002' value='#{f6[178].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f644003' value='#{f6[179].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f644004' value='#{f6[180].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>5</th><th align='left'>กุมารเวชศาสตร์โรคไต</th>
    <td><input type='text' size='3' style='text-align: right' name='f605001' value='#{f6[21].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f605002' value='#{f6[22].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f605003' value='#{f6[23].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f605004' value='#{f6[24].to_s}'></td>
    <th>45</th><th align='left'>เวชศาสตร์ฟื้นฟู</th>
    <td><input type='text' size='3' style='text-align: right' name='f645001' value='#{f6[181].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f645002' value='#{f6[182].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f645003' value='#{f6[183].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f645004' value='#{f6[184].to_s}'></td>
  </tr>
  <tr>
    <th>6</th><th align='left'>กุมารเวชศาสตร์โรคติดเชื้อ</th>
    <td><input type='text' size='3' style='text-align: right' name='f606001' value='#{f6[25].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f606002' value='#{f6[26].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f606003' value='#{f6[27].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f606004' value='#{f6[28].to_s}'></td>
    <th>46</th><th align='left'>ศัลยศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f646001' value='#{f6[185].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f646002' value='#{f6[186].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f646003' value='#{f6[187].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f646004' value='#{f6[188].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>7</th><th align='left'>กุมารเวชศาสตร์โรคทางเดินอาหารและโรคตับ</th>
    <td><input type='text' size='3' style='text-align: right' name='f607001' value='#{f6[29].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f607002' value='#{f6[30].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f607003' value='#{f6[31].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f607004' value='#{f6[32].to_s}'></td>
    <th>47</th><th align='left'>ประสาทศัลยศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f647001' value='#{f6[189].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f647002' value='#{f6[190].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f647003' value='#{f6[191].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f647004' value='#{f6[192].to_s}'></td>
  </tr>
  <tr>
    <th>8</th><th align='left'>กุมารเวชศาสตร์ประสาทวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f608001' value='#{f6[33].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f608002' value='#{f6[34].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f608003' value='#{f6[35].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f608004' value='#{f6[36].to_s}'></td>
    <th>48</th><th align='left'>ศัลยศาสตร์ตกแต่ง</th>
    <td><input type='text' size='3' style='text-align: right' name='f648001' value='#{f6[193].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f648002' value='#{f6[194].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f648003' value='#{f6[195].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f648004' value='#{f6[196].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>9</th><th align='left'>กุมารเวชศาสตร์โรคภูมิแพ้และภูมิคุ้มกัน</th>
    <td><input type='text' size='3' style='text-align: right' name='f609001' value='#{f6[37].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f609002' value='#{f6[38].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f609003' value='#{f6[39].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f609004' value='#{f6[40].to_s}'></td>
    <th>49</th><th align='left'>ศัลยศาสตร์ทรวงอก</th>
    <td><input type='text' size='3' style='text-align: right' name='f649001' value='#{f6[197].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f649002' value='#{f6[198].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f649003' value='#{f6[199].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f649004' value='#{f6[200].to_s}'></td>
  </tr>
  <tr>
    <th>10</th><th align='left'>กุมารเวชศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f610001' value='#{f6[41].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f610002' value='#{f6[42].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f610003' value='#{f6[43].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f610004' value='#{f6[44].to_s}'></td>
    <th>50</th><th align='left'>ศัลยศาสตร์ยูโรวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f650001' value='#{f6[201].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f650002' value='#{f6[202].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f650003' value='#{f6[203].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f650004' value='#{f6[204].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>11</th><th align='left'>กุมารเวชศาสตร์โรคเลือด</th>
    <td><input type='text' size='3' style='text-align: right' name='f611001' value='#{f6[45].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f611002' value='#{f6[46].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f611003' value='#{f6[47].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f611004' value='#{f6[48].to_s}'></td>
    <th>51</th><th align='left'>กุมารศัลยศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f651001' value='#{f6[205].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f651002' value='#{f6[206].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f651003' value='#{f6[207].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f651004' value='#{f6[208].to_s}'></td>
  </tr>
  <tr>
    <th>12</th><th align='left'>กุมารเวชศาสตร์ทารกแรกเกิดและปริกำเนิด</th>
    <td><input type='text' size='3' style='text-align: right' name='f612001' value='#{f6[49].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f612002' value='#{f6[50].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f612003' value='#{f6[51].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f612004' value='#{f6[52].to_s}'></td>
    <th>52</th><th align='left'>ศัลยศาสตร์ลำไส้ใหญ่และทวารหนัก</th>
    <td><input type='text' size='3' style='text-align: right' name='f652001' value='#{f6[209].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f652002' value='#{f6[210].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f652003' value='#{f6[211].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f652004' value='#{f6[212].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>13</th><th align='left'>จักษุวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f613001' value='#{f6[53].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f613002' value='#{f6[54].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f613003' value='#{f6[55].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f613004' value='#{f6[56].to_s}'></td>
    <th>53</th><th align='left'>ศัลยศาสตร์หลอดเลือด</th>
    <td><input type='text' size='3' style='text-align: right' name='f653001' value='#{f6[213].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f653002' value='#{f6[214].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f653003' value='#{f6[215].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f653004' value='#{f6[216].to_s}'></td>
  </tr>
  <tr>
    <th>14</th><th align='left'>จิตเวชศาสตร์เด็กและวัยรุ่น</th>
    <td><input type='text' size='3' style='text-align: right' name='f614001' value='#{f6[57].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f614002' value='#{f6[58].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f614003' value='#{f6[59].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f614004' value='#{f6[60].to_s}'></td>
    <th>54</th><th align='left'>ศัลยศาสตร์อุบัติเหตุ</th>
    <td><input type='text' size='3' style='text-align: right' name='f654001' value='#{f6[217].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f654002' value='#{f6[218].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f654003' value='#{f6[219].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f654004' value='#{f6[220].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>15</th><th align='left'>จิตเวชศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f615001' value='#{f6[61].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f615002' value='#{f6[62].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f615003' value='#{f6[63].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f615004' value='#{f6[64].to_s}'></td>
    <th>55</th><th align='left'>ศัลยศาสตร์มะเร็งวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f655001' value='#{f6[221].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f655002' value='#{f6[222].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f655003' value='#{f6[223].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f655004' value='#{f6[224].to_s}'></td>
  </tr>
  <tr>
    <th>16</th><th align='left'>พยาธิวิทยาคลินิก</th>
    <td><input type='text' size='3' style='text-align: right' name='f616001' value='#{f6[65].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f616002' value='#{f6[66].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f616003' value='#{f6[67].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f616004' value='#{f6[68].to_s}'></td>
    <th>56</th><th align='left'>ศัลยศาสตร์ออร์โธปิดิกส์</th>
    <td><input type='text' size='3' style='text-align: right' name='f656001' value='#{f6[225].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f656002' value='#{f6[226].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f656003' value='#{f6[227].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f656004' value='#{f6[228].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>17</th><th align='left'>นิติเวชศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f617001' value='#{f6[69].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f617002' value='#{f6[70].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f617003' value='#{f6[71].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f617004' value='#{f6[72].to_s}'></td>
     <th>57</th><th align='left'>สูติศาสตร์-นรีเวชวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f657001' value='#{f6[229].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f657002' value='#{f6[230].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f657003' value='#{f6[231].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f657004' value='#{f6[232].to_s}'></td>
  </tr>
  <tr>
    <th>18</th><th align='left'>พยาธิวิทยาทั่วไป</th>
    <td><input type='text' size='3' style='text-align: right' name='f618001' value='#{f6[73].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f618002' value='#{f6[74].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f618003' value='#{f6[75].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f618004' value='#{f6[76].to_s}'></td>
    <th>58</th><th align='left'>เวชศาสตร์มารดาและทารกในครรภ์</th>
    <td><input type='text' size='3' style='text-align: right' name='f658001' value='#{f6[233].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f658002' value='#{f6[234].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f658003' value='#{f6[235].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f658004' value='#{f6[236].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>19</th><th align='left'>พยาธิวิทยากายวิภาค</th>
    <td><input type='text' size='3' style='text-align: right' name='f619001' value='#{f6[77].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f619002' value='#{f6[78].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f619003' value='#{f6[79].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f619004' value='#{f6[80].to_s}'></td>
    <th>59</th><th align='left'>มะเร็งนรีเวชวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f659001' value='#{f6[237].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f659002' value='#{f6[238].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f659003' value='#{f6[239].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f659004' value='#{f6[240].to_s}'></td>
  </tr>
  <tr>
    <th>20</th><th align='left'>รังสีวิทยาทั่วไป</th>
    <td><input type='text' size='3' style='text-align: right' name='f620001' value='#{f6[81].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f620002' value='#{f6[82].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f620003' value='#{f6[83].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f620004' value='#{f6[84].to_s}'></td>
    <th>60</th><th align='left'>เวชศาสตร์การเจริญพันธุ์</th>
    <td><input type='text' size='3' style='text-align: right' name='f660001' value='#{f6[241].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f660002' value='#{f6[242].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f660003' value='#{f6[243].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f660004' value='#{f6[244].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>21</th><th align='left'>รังสีวิทยาวินิจฉัย</th>
    <td><input type='text' size='3' style='text-align: right' name='f621001' value='#{f6[85].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f621002' value='#{f6[86].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f621003' value='#{f6[87].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f621004' value='#{f6[88].to_s}'></td>
    <th>61</th><th align='left'>โสต ศอ นาสิกวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f661001' value='#{f6[245].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f661002' value='#{f6[246].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f661003' value='#{f6[247].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f661004' value='#{f6[248].to_s}'></td>
  </tr>
  <tr>
    <th>22</th><th align='left'>รังสีรักษาและมะเร็งวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f622001' value='#{f6[89].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f622002' value='#{f6[90].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f622003' value='#{f6[91].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f622004' value='#{f6[92].to_s}'></td>
    <th>62</th><th align='left'>ศัลยศาสตร์ตกแต่งและเสริมสร้างใบหน้า</th>
    <td><input type='text' size='3' style='text-align: right' name='f662001' value='#{f6[249].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f662002' value='#{f6[250].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f662003' value='#{f6[251].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f662004' value='#{f6[252].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>23</th><th align='left'>เวชศาสตร์นิวเคลียร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f623001' value='#{f6[93].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f623002' value='#{f6[94].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f623003' value='#{f6[95].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f623004' value='#{f6[96].to_s}'></td>
    <th>63</th><th align='left'>อายุรศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f663001' value='#{f6[253].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f663002' value='#{f6[254].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f663003' value='#{f6[255].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f663004' value='#{f6[256].to_s}'></td>
  </tr>
  <tr>
    <th>24</th><th align='left'>รังสีรักษาและเวชศาสตร์นิวเคลียร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f624001' value='#{f6[97].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f624002' value='#{f6[98].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f624003' value='#{f6[99].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f624004' value='#{f6[100].to_s}'></td>
    <th>64</th><th align='left'>อายุรศาสตร์โรคเลือด</th>
    <td><input type='text' size='3' style='text-align: right' name='f664001' value='#{f6[257].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f664002' value='#{f6[258].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f664003' value='#{f6[259].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f664004' value='#{f6[260].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>25</th><th align='left'>ภาพวินิจฉัยระบบประสาท(1001)</th>
    <td><input type='text' size='3' style='text-align: right' name='f625001' value='#{f6[101].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f625002' value='#{f6[102].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f625003' value='#{f6[103].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f625004' value='#{f6[104].to_s}'></td>
    <th>65</th><th align='left'>อายุรศาสตร์มะเร็งวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f665001' value='#{f6[261].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f665002' value='#{f6[262].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f665003' value='#{f6[263].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f665004' value='#{f6[264].to_s}'></td>
  </tr>
  <tr>
    <th>26</th><th align='left'>รังสีร่วมรักษาระบบประสาท(1002)</th>
    <td><input type='text' size='3' style='text-align: right' name='f626001' value='#{f6[105].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f626002' value='#{f6[106].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f626003' value='#{f6[107].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f626004' value='#{f6[108].to_s}'></td>
    <th>66</th><th align='left'>ประสาทวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f666001' value='#{f6[265].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f666002' value='#{f6[266].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f666003' value='#{f6[267].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f666004' value='#{f6[268].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>27</th><th align='left'>รังสีร่วมรักษาของลำตัว(1003)</th>
    <td><input type='text' size='3' style='text-align: right' name='f627001' value='#{f6[109].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f627002' value='#{f6[110].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f627003' value='#{f6[111].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f627004' value='#{f6[112].to_s}'></td>
    <th>67</th><th align='left'>ตจวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f667001' value='#{f6[269].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f667002' value='#{f6[270].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f667003' value='#{f6[271].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f667004' value='#{f6[272].to_s}'></td>
  </tr>
  <tr>
    <th>28</th><th align='left'>ภาพวินิจฉัยชั้นสูง(1004)</th>
    <td><input type='text' size='3' style='text-align: right' name='f628001' value='#{f6[113].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f628002' value='#{f6[114].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f628003' value='#{f6[115].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f628004' value='#{f6[116].to_s}'></td>
    <th>68</th><th align='left'>เวชศาสตร์ฉุกเฉิน</th>
    <td><input type='text' size='3' style='text-align: right' name='f668001' value='#{f6[273].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f668002' value='#{f6[274].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f668003' value='#{f6[275].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f668004' value='#{f6[276].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>29</th><th align='left'>ภาพวินิจฉัยระบบประสาท(1101)</th>
    <td><input type='text' size='3' style='text-align: right' name='f629001' value='#{f6[117].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f629002' value='#{f6[118].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f629003' value='#{f6[119].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f629004' value='#{f6[120].to_s}'></td>
    <th>69</th><th align='left'>โลหิตวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f669001' value='#{f6[277].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f669002' value='#{f6[278].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f669003' value='#{f6[279].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f669004' value='#{f6[280].to_s}'></td>
  </tr>
  <tr>
    <th>30</th><th align='left'>รังสีร่วมรักษาระบบประสาท(1102)</th>
    <td><input type='text' size='3' style='text-align: right' name='f630001' value='#{f6[121].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f630002' value='#{f6[122].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f630003' value='#{f6[123].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f630004' value='#{f6[124].to_s}'></td>
    <th>70</th><th align='left'>อายุรศาสตร์โรคทรวงอก</th>
    <td><input type='text' size='3' style='text-align: right' name='f670001' value='#{f6[281].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f670002' value='#{f6[282].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f670003' value='#{f6[283].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f670004' value='#{f6[284].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>31</th><th align='left'>รังสีร่วมรักษาของลำตัว(1103)</th>
    <td><input type='text' size='3' style='text-align: right' name='f631001' value='#{f6[125].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f631002' value='#{f6[126].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f631003' value='#{f6[127].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f631004' value='#{f6[128].to_s}'></td>
    <th>71</th><th align='left'>อายุรศาสตร์โรคติดเชื้อ</th>
    <td><input type='text' size='3' style='text-align: right' name='f671001' value='#{f6[285].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f671002' value='#{f6[286].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f671003' value='#{f6[287].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f671004' value='#{f6[288].to_s}'></td>
  </tr>
  <tr>
    <th>32</th><th align='left'>ภาพวินิจฉัยชั้นสูง(1104)</th>
    <td><input type='text' size='3' style='text-align: right' name='f632001' value='#{f6[129].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f632002' value='#{f6[130].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f632003' value='#{f6[131].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f632004' value='#{f6[132].to_s}'></td>
    <th>72</th><th align='left'>อายุรศาสตร์โรคข้อและรูมาติสซั่ม</th>
    <td><input type='text' size='3' style='text-align: right' name='f672001' value='#{f6[289].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f672002' value='#{f6[290].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f672003' value='#{f6[291].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f672004' value='#{f6[292].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>33</th><th align='left'>วิสัญญีวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f633001' value='#{f6[133].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f633002' value='#{f6[134].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f633003' value='#{f6[135].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f633004' value='#{f6[136].to_s}'></td>
    <th>73</th><th align='left'>อายุรศาสตร์โรคต่อมไร้ท่อและเมตะบอลิสม</th>
    <td><input type='text' size='3' style='text-align: right' name='f673001' value='#{f6[293].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f673002' value='#{f6[294].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f673003' value='#{f6[295].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f673004' value='#{f6[296].to_s}'></td>
  </tr>
  <tr>
    <th>34</th><th align='left'>วิสัญญีวิทยาเพื่อการผ่าตัดหัวใจหลอดเลือดใหญ่และทรวงอก</th>
    <td><input type='text' size='3' style='text-align: right' name='f634001' value='#{f6[137].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f634002' value='#{f6[138].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f634003' value='#{f6[139].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f634004' value='#{f6[140].to_s}'></td>
    <th>74</th><th align='left'>อายุรศาสตร์โรคภูมิแพ้และอิมมูโนวิทยาคลินิก</th>
    <td><input type='text' size='3' style='text-align: right' name='f674001' value='#{f6[297].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f674002' value='#{f6[298].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f674003' value='#{f6[299].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f674004' value='#{f6[300].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>35</th><th align='left'>วิสัญญีวิทยาสำหรับผู้ป่วยโรคทางระบบประสาท</th>
    <td><input type='text' size='3' style='text-align: right' name='f635001' value='#{f6[141].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f635002' value='#{f6[142].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f635003' value='#{f6[143].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f635004' value='#{f6[144].to_s}'></td>
    <th>75</th><th align='left'>อายุรศาสตร์โรคระบบทางเดินอาหาร</th>
    <td><input type='text' size='3' style='text-align: right' name='f675001' value='#{f6[301].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f675002' value='#{f6[302].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f675003' value='#{f6[303].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f675004' value='#{f6[304].to_s}'></td>
  </tr>
  <tr>
    <th>36</th><th align='left'>เวชปฏิบัติทั่วไป</th>
    <td><input type='text' size='3' style='text-align: right' name='f636001' value='#{f6[145].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f636002' value='#{f6[146].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f636003' value='#{f6[147].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f636004' value='#{f6[148].to_s}'></td>
    <th>76</th><th align='left'>อายุรศาสตร์โรคไต</th>
    <td><input type='text' size='3' style='text-align: right' name='f676001' value='#{f6[305].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f676002' value='#{f6[306].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f676003' value='#{f6[307].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f676004' value='#{f6[308].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>37</th><th align='left'>เวชศาสตร์ครอบครัว</th>
    <td><input type='text' size='3' style='text-align: right' name='f637001' value='#{f6[149].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f637002' value='#{f6[150].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f637003' value='#{f6[151].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f637004' value='#{f6[152].to_s}'></td>
    <th>77</th><th align='left'>อายุรศาสตร์โรคหัวใจ</th>
    <td><input type='text' size='3' style='text-align: right' name='f677001' value='#{f6[309].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f677002' value='#{f6[310].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f677003' value='#{f6[311].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f677004' value='#{f6[312].to_s}'></td>
  </tr>
  <tr>
    <th>38</th><th align='left'>เวชศาสตร์ป้องกัน</th>
    <td><input type='text' size='3' style='text-align: right' name='f638001' value='#{f6[153].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f638002' value='#{f6[154].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f638003' value='#{f6[155].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f638004' value='#{f6[156].to_s}'></td>
    <th>78</th><th align='left'>อายุรศาสตร์โรคระบบการหายใจและภาวะวิกฤต</th>
    <td><input type='text' size='3' style='text-align: right' name='f678001' value='#{f6[313].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f678002' value='#{f6[314].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f678003' value='#{f6[315].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f678004' value='#{f6[316].to_s}'></td>
  </tr>
  <tr bgcolor='beige'>
    <th>39</th><th align='left'>แขนงสาธารณสุขศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f639001' value='#{f6[157].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f639002' value='#{f6[158].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f639003' value='#{f6[159].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f639004' value='#{f6[160].to_s}'></td>
    <th>79</th><th align='left'>เวชบำบัดวิกฤต</th>
    <td><input type='text' size='3' style='text-align: right' name='f679001' value='#{f6[317].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f679002' value='#{f6[318].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f679003' value='#{f6[319].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f679004' value='#{f6[320].to_s}'></td>
  </tr>
  <tr>
    <th>40</th><th align='left'>แขนงระบาดวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f640001' value='#{f6[161].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f640002' value='#{f6[162].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f640003' value='#{f6[163].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f640004' value='#{f6[164].to_s}'></td>
    <th>&nbsp;</th><th align='left'>&nbsp;</th>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
</tr>
</table>
#{statusMsg}
<p>
<input id='f6submit' type='submit' value='บันทึกข้อมูล' #{gpFlag}><input type='button' 
value='ยกเลิก' onClick="document.location.href='hr_form6.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=CLEAR' ">
</form>
<hr>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" onClick="document.location.href='hr_form5.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" onClick="document.location.href='hr_form7.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
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
