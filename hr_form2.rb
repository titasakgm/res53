#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'res_util.rb'
require 'hr_util.rb'

inpsize = 20
twidth = "40%"
f2 = Array.new

c = CGI::new

user = c['user'].to_s.split('').join('')
sessid = c['sessid']
year = c['year'].to_s.split('').join('')
repId = c['offReport'].to_s.split('').join('')
opt = c['opt'].to_s.split('').join('')
otype = c['otype'].to_s.split('').join('')
if (otype.to_s.length == 0)
  otype = getOtype(repId)
  #log("otype: #{otype}")
end

flag = checkSession(user,sessid)
if !flag
  print "Location:/res53\n\n"
  exit
end

offId = user.to_s.split('').join('')
member = getMemberName(offId)
provId = offId[0..1]
province = getProvName(provId)
repName = getOfficeName(repId)
f1Flag = nil
f2Flag = nil
gpFlag = nil
ssjFlag = nil
flagSSJ = nil
ssoFlag = nil
flagSSO = nil

statusMsg = "<font color='red'><b>กรุณาตรวจสอบข้อมูลให้ถูกต้องอีกครั้งก่อนกดปุ่ม</b></font>"
moph = nil

reporter_id = offId
reporter_id = "#{offId}01" if offId.length == 2
reporter_id = "#{offId}00" if offId == '10'
reporter_id = '9800' if offId == '98'
reporter = getReporter(reporter_id)

f2allow = checkForm2Allow(repId)
ssoFlag = ssoCheck(repId)
#hcFlag = chkOtypeHC(repId)

if !(f2allow)
  if (ssoFlag == true)
    statusMsg = "<font color='red'><b>สสอ. ไม่ต้องบันทึก FORM 2</b></font>" 
  else
    statusMsg = "<font color='red'><b>สถานีอนามัย ไม่ต้องบันทึก FORM 2</b></font>"
  end
  hcFlag = 'DISABLED'
  autoCheckForm2(repId) # Check X in reportmon(form2)
end

flag = checkOwner(user,repId)
if !flag
  notOwner(user,repId)
  exit
end

if otype == 'M'
  moph = ":กสธ"
  f1Flag = "DISABLED"
  f2Flag = ''
  f1BTN = ''
  # 2553 all (M) must fill form2
  #f2BTN = ''
  f2BTN = "<input type=\"button\" value=\"Form 2\" "
  f2BTN += "style=\"width:100%\" onClick=\"document.location.href='hr_form2.rb?"
  f2BTN += "user=#{user}&sessid=#{sessid}&year=2553"
  f2BTN += "&offReport=#{repId}&opt=0&otype=#{otype}'\">"
else # G or P
  flagGP = gpCheck(1,repId)
  flagSSJ = ssjCheck(repId)
  flagSSO = ssoCheck(repId)

  gpFlag = "DISABLED"
  if (flagGP)
    gpFlag = nil 
  else
    statusMsg = "<font color='red'><b>จำนวนแพทย์ใน FORM 1 เป็น 0 ไม่สามารถบันทึก FORM 2 ได้</b>"
    statusMsg += "<br />กรุณา key 0 ใส่ช่องบนซ้าย แล้วกดปุ่มบันทึกข้อมูล</font>"
  end

  #log("gpFlag: #{gpFlag}")
  
  f1BTN = "<input type=\"button\" value=\"Form 1\" "
  f1BTN += "style=\"width:100%\" onClick=\"document.location.href='hr_form1.rb?"
  f1BTN += "user=#{user}&sessid=#{sessid}&year=2553"
  f1BTN += "&offReport=#{repId}&opt=0&otype=#{otype}'\" #{f1Flag}>"
  f3BTN = "<input type=\"button\" value=\"Form 3\" "
  f3BTN += "style=\"width:100%\" onClick=\"document.location.href='hr_form3.rb?"
  f3BTN += "user=#{user}&sessid=#{sessid}&year=2553"
  f3BTN += "&offReport=#{repId}&opt=0&otype=#{otype}'\">"
end

if opt.to_s == 'DEL'
  delForm2Data(year, repId)
elsif opt.to_s == 'CLEAR'
  clearForm2Data(year, repId)
end

if opt.to_s != 'CLEAR'
  f2 = getForm2Data(year,repId)
  if ( (flagGP==false) && (flagSSJ==false) ) # form1 f101001=f101002=f101003=f101004=0
    (5..321).each do |n|
      f2[n] = ' '
    end
  end
end

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<!-- src: hr_form2.rb -->
<head>
<title>ข้อมูลทรัพยากรสาธารณสุข</title>
<script>
function enableSubmit()
{
  var val1 = document.getElementById('f201001').value;
  var val2 = document.getElementById('f201002').value;
  var val3 = document.getElementById('f201003').value;
  var val4 = document.getElementById('f201004').value;
  if (val1 == 0 || val2 == 0 || val3 == 0 || val4 == 0)
  {
    document.getElementById('f2submit').disabled = false;
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
      <td width="25%">#{f1BTN}</td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" onClick="document.location.href='hr_form3.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0&otype=#{otype}' "></td>
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
  <th><h3><font color='black'><b>แบบบันทึกข้อมูลทรัพยากรสาธารณสุข</b></font>
  <font color='black'><b>&nbsp;(ภาครัฐ)</b></font>
  <font color='black'>&nbsp;&nbsp;โดย คุณ#{member}
  <br />#{reporter}</font></h3></th>
  </tr>
  </table>
  <h3>ส่วนที่&nbsp;1&nbsp;&nbsp;บุคลากรทางการแพทย์และสาธารณสุข</h3>
  <h4><font color='red'>ข้อ20  สาขารังสีวิทยาทั่วไป   
      มีอนุสาขาตั้งแต่ข้อ 25-28</font></h4>
  <h4><font color='red'>ข้อ21 สาขารังสีวิทยาวินิจฉัย  
      มีอนุสาขาตั้งแต่ข้อ 29-32</font></h4>
  <form action='form2.rb' method='post'>
  <input type='hidden' name='f2year' value='2553'>
  <input type='hidden' name='f2pname' value='#{province}'>
  <input type='hidden' name='f2pcode' value='#{provId}'>
  <input type='hidden' name='f2hname' value='#{repName}'>
  <input type='hidden' name='f2hcode' value='#{repId}'>
  <font size='4'><b>ตารางที่ 2: &nbsp;จำนวน<font color='black'><b>แพทย์ที่ศึกษาต่อเฉพาะทาง
  </b></font>จำแนกตามวุฒิบัตรหรือหนังสืออนุมัติความเชี่ยวชาญ</b></font><br>
  <font size='4'><b>เฉพาะทางจากแพทยสภา &nbsp; ณ 30 กันยายน&nbsp;</font>
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
     <th colspan='2'>ขรก.และ<br>พ.ของรัฐ</th><th colspan='2'>ลูกจ้าง</th>
     <th colspan='2'>ขรก.และ<br>พ.ของรัฐ</th><th colspan='2'>ลูกจ้าง</th>
  </tr>
  <tr bgcolor='pink'>
    <th>ช</th><th>ญ</th><th>ช</th><th>ญ</th>
    <th>ช</th><th>ญ</th><th>ช</th><th>ญ</th>
  </tr>
   <tr bgcolor='beige'>
    <th>1</th><th align='left'>กุมารเวชศาสตร์โรคหัวใจ</th>
    <td><input type='text' size='3' style='text-align: right' name='f201001' id='f201001' 
                value='#{f2[5].to_s}' #{hcFlag} onchange='enableSubmit()'></td>
    <td><input type='text' size='3' style='text-align: right' name='f201002' id='f201002'
                value='#{f2[6].to_s}' #{hcFlag} onchange='enableSubmit()'></td>
    <td><input type='text' size='3' style='text-align: right' name='f201003' id='f201003'
                value='#{f2[7].to_s}' #{hcFlag} onchange='enableSubmit()'></td>
    <td><input type='text' size='3' style='text-align: right' name='f201004' id='f201004'
                value='#{f2[8].to_s}' #{hcFlag} onchange='enableSubmit()'></td>
    <th>41</th><th align='left'>แขนงเวชศาสตร์ป้องกันคลินิก</th>
    <td><input type='text' size='3' style='text-align: right' name='f241001' value='#{f2[165].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f241002' value='#{f2[166].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f241003' value='#{f2[167].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f241004' value='#{f2[168].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>2</th><th align='left'>กุมารเวชศาสตร์โรคระบบการหายใจ</th>
    <td><input type='text' size='3' style='text-align: right' name='f202001' value='#{f2[9].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f202002' value='#{f2[10].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f202003' value='#{f2[11].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f202004' value='#{f2[12].to_s}' #{hcFlag}></td>
    <th>42</th><th align='left'>แขนงเวชศาสตร์การบิน</th>
    <td><input type='text' size='3' style='text-align: right' name='f242001' value='#{f2[169].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f242002' value='#{f2[170].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f242003' value='#{f2[171].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f242004' value='#{f2[172].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>3</th><th align='left'>กุมารเวชศาสตร์โรคต่อมไร้ท่อและเมตาบอลิสม</th>
    <td><input type='text' size='3' style='text-align: right' name='f203001' value='#{f2[13].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f203002' value='#{f2[14].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f203003' value='#{f2[15].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f203004' value='#{f2[16].to_s}' #{hcFlag}></td>
    <th>43</th><th align='left'>แขนงอาชีวเวชศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f243001' value='#{f2[173].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f243002' value='#{f2[174].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f243003' value='#{f2[175].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f243004' value='#{f2[176].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>4</th><th align='left'>กุมารเวชศาสตร์พัฒนาการและพฤติกรรม</th>
    <td><input type='text' size='3' style='text-align: right' name='f204001' value='#{f2[17].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f204002' value='#{f2[18].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f204003' value='#{f2[19].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f204004' value='#{f2[20].to_s}' #{hcFlag}></td>
    <th>44</th><th align='left'>แขนงสุขภาพจิตชุมชน</th>
    <td><input type='text' size='3' style='text-align: right' name='f244001' value='#{f2[177].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f244002' value='#{f2[178].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f244003' value='#{f2[179].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f244004' value='#{f2[180].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>5</th><th align='left'>กุมารเวชศาสตร์โรคไต</th>
    <td><input type='text' size='3' style='text-align: right' name='f205001' value='#{f2[21].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f205002' value='#{f2[22].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f205003' value='#{f2[23].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f205004' value='#{f2[24].to_s}' #{hcFlag}></td>
    <th>45</th><th align='left'>เวชศาสตร์ฟื้นฟู</th>
    <td><input type='text' size='3' style='text-align: right' name='f245001' value='#{f2[181].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f245002' value='#{f2[182].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f245003' value='#{f2[183].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f245004' value='#{f2[184].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>6</th><th align='left'>กุมารเวชศาสตร์โรคติดเชื้อ</th>
    <td><input type='text' size='3' style='text-align: right' name='f206001' value='#{f2[25].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f206002' value='#{f2[26].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f206003' value='#{f2[27].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f206004' value='#{f2[28].to_s}' #{hcFlag}></td>
     <th>46</th><th align='left'>ศัลยศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f246001' value='#{f2[185].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f246002' value='#{f2[186].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f246003' value='#{f2[187].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f246004' value='#{f2[188].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>7</th><th align='left'>กุมารเวชศาสตร์โรคทางเดินอาหารและโรคตับ</th>
    <td><input type='text' size='3' style='text-align: right' name='f207001' value='#{f2[29].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f207002' value='#{f2[30].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f207003' value='#{f2[31].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f207004' value='#{f2[32].to_s}' #{hcFlag}></td>
    <th>47</th><th align='left'>ประสาทศัลยศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f247001' value='#{f2[189].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f247002' value='#{f2[190].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f247003' value='#{f2[191].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f247004' value='#{f2[192].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>8</th><th align='left'>กุมารเวชศาสตร์ประสาทวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f208001' value='#{f2[33].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f208002' value='#{f2[34].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f208003' value='#{f2[35].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f208004' value='#{f2[36].to_s}' #{hcFlag}></td>
    <th>48</th><th align='left'>ศัลยศาสตร์ตกแต่ง</th>
    <td><input type='text' size='3' style='text-align: right' name='f248001' value='#{f2[193].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f248002' value='#{f2[194].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f248003' value='#{f2[195].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f248004' value='#{f2[196].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>9</th><th align='left'>กุมารเวชศาสตร์โรคภูมิแพ้และภูมิคุ้มกัน</th>
    <td><input type='text' size='3' style='text-align: right' name='f209001' value='#{f2[37].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f209002' value='#{f2[38].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f209003' value='#{f2[39].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f209004' value='#{f2[40].to_s}' #{hcFlag}></td>
     <th>49</th><th align='left'>ศัลยศาสตร์ทรวงอก</th>
    <td><input type='text' size='3' style='text-align: right' name='f249001' value='#{f2[197].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f249002' value='#{f2[198].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f249003' value='#{f2[199].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f249004' value='#{f2[200].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>10</th><th align='left'>กุมารเวชศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f210001' value='#{f2[41].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f210002' value='#{f2[42].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f210003' value='#{f2[43].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f210004' value='#{f2[44].to_s}' #{hcFlag}></td>
    <th>50</th><th align='left'>ศัลยศาสตร์ยูโรวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f250001' value='#{f2[201].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f250002' value='#{f2[202].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f250003' value='#{f2[203].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f250004' value='#{f2[204].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>11</th><th align='left'>กุมารเวชศาสตร์โรคเลือด</th>
    <td><input type='text' size='3' style='text-align: right' name='f211001' value='#{f2[45].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f211002' value='#{f2[46].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f211003' value='#{f2[47].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f211004' value='#{f2[48].to_s}' #{hcFlag}></td>
    <th>51</th><th align='left'>กุมารศัลยศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f251001' value='#{f2[205].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f251002' value='#{f2[206].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f251003' value='#{f2[207].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f251004' value='#{f2[208].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>12</th><th align='left'>กุมารเวชศาสตร์ทารกแรกเกิดและปริกำเนิด</th>
    <td><input type='text' size='3' style='text-align: right' name='f212001' value='#{f2[49].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f212002' value='#{f2[50].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f212003' value='#{f2[51].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f212004' value='#{f2[52].to_s}' #{hcFlag}></td>
    <th>52</th><th align='left'>ศัลยศาสตร์ลำไส้ใหญ่และทวารหนัก</th>
    <td><input type='text' size='3' style='text-align: right' name='f252001' value='#{f2[209].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f252002' value='#{f2[210].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f252003' value='#{f2[211].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f252004' value='#{f2[212].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>13</th><th align='left'>จักษุวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f213001' value='#{f2[53].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f213002' value='#{f2[54].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f213003' value='#{f2[55].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f213004' value='#{f2[56].to_s}' #{hcFlag}></td>
    <th>53</th><th align='left'>ศัลยศาสตร์หลอดเลือด</th>
    <td><input type='text' size='3' style='text-align: right' name='f253001' value='#{f2[213].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f253002' value='#{f2[214].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f253003' value='#{f2[215].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f253004' value='#{f2[216].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>14</th><th align='left'>จิตเวชศาสตร์เด็กและวัยรุ่น</th>
    <td><input type='text' size='3' style='text-align: right' name='f214001' value='#{f2[57].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f214002' value='#{f2[58].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f214003' value='#{f2[59].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f214004' value='#{f2[60].to_s}' #{hcFlag}></td>
    <th>54</th><th align='left'>ศัลยศาสตร์อุบัติเหตุ</th>
    <td><input type='text' size='3' style='text-align: right' name='f254001' value='#{f2[217].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f254002' value='#{f2[218].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f254003' value='#{f2[219].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f254004' value='#{f2[220].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>15</th><th align='left'>จิตเวชศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f215001' value='#{f2[61].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f215002' value='#{f2[62].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f215003' value='#{f2[63].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f215004' value='#{f2[64].to_s}' #{hcFlag}></td>
    <th>55</th><th align='left'>ศัลยศาสตร์มะเร็งวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f255001' value='#{f2[221].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f255002' value='#{f2[222].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f255003' value='#{f2[223].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f255004' value='#{f2[224].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>16</th><th align='left'>พยาธิวิทยาคลินิก</th>
    <td><input type='text' size='3' style='text-align: right' name='f216001' value='#{f2[65].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f216002' value='#{f2[66].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f216003' value='#{f2[67].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f216004' value='#{f2[68].to_s}' #{hcFlag}></td>
    <th>56</th><th align='left'>ศัลยศาสตร์ออร์โธปิดิกส์</th>
    <td><input type='text' size='3' style='text-align: right' name='f256001' value='#{f2[225].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f256002' value='#{f2[226].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f256003' value='#{f2[227].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f256004' value='#{f2[228].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>17</th><th align='left'>นิติเวชศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f217001' value='#{f2[69].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f217002' value='#{f2[70].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f217003' value='#{f2[71].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f217004' value='#{f2[72].to_s}' #{hcFlag}></td>
     <th>57</th><th align='left'>สูติศาสตร์-นรีเวชวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f257001' value='#{f2[229].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f257002' value='#{f2[230].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f257003' value='#{f2[231].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f257004' value='#{f2[232].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>18</th><th align='left'>พยาธิวิทยาทั่วไป</th>
    <td><input type='text' size='3' style='text-align: right' name='f218001' value='#{f2[73].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f218002' value='#{f2[74].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f218003' value='#{f2[75].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f218004' value='#{f2[76].to_s}' #{hcFlag}></td>
    <th>58</th><th align='left'>เวชศาสตร์มารดาและทารกในครรภ์</th>
    <td><input type='text' size='3' style='text-align: right' name='f258001' value='#{f2[233].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f258002' value='#{f2[234].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f258003' value='#{f2[235].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f258004' value='#{f2[236].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>19</th><th align='left'>พยาธิวิทยากายวิภาค</th>
    <td><input type='text' size='3' style='text-align: right' name='f219001' value='#{f2[77].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f219002' value='#{f2[78].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f219003' value='#{f2[79].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f219004' value='#{f2[80].to_s}' #{hcFlag}></td>
    <th>59</th><th align='left'>มะเร็งนรีเวชวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f259001' value='#{f2[237].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f259002' value='#{f2[238].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f259003' value='#{f2[239].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f259004' value='#{f2[240].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>20</th><th align='left'>รังสีวิทยาทั่วไป</th>
    <td><input type='text' size='3' style='text-align: right' name='f220001' value='#{f2[81].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f220002' value='#{f2[82].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f220003' value='#{f2[83].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f220004' value='#{f2[84].to_s}' #{hcFlag}></td>
    <th>60</th><th align='left'>เวชศาสตร์การเจริญพันธุ์</th>
    <td><input type='text' size='3' style='text-align: right' name='f260001' value='#{f2[241].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f260002' value='#{f2[242].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f260003' value='#{f2[243].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f260004' value='#{f2[244].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>21</th><th align='left'>รังสีวิทยาวินิจฉัย</th>
    <td><input type='text' size='3' style='text-align: right' name='f221001' value='#{f2[85].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f221002' value='#{f2[86].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f221003' value='#{f2[87].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f221004' value='#{f2[88].to_s}' #{hcFlag}></td>
    <th>61</th><th align='left'>โสต ศอ นาสิกวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f261001' value='#{f2[245].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f261002' value='#{f2[246].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f261003' value='#{f2[247].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f261004' value='#{f2[248].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>22</th><th align='left'>รังสีรักษาและมะเร็งวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f222001' value='#{f2[89].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f222002' value='#{f2[90].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f222003' value='#{f2[91].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f222004' value='#{f2[92].to_s}' #{hcFlag}></td>
    <th>62</th><th align='left'>ศัลยศาสตร์ตกแต่งและเสริมสร้างใบหน้า</th>
    <td><input type='text' size='3' style='text-align: right' name='f262001' value='#{f2[249].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f262002' value='#{f2[250].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f262003' value='#{f2[251].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f262004' value='#{f2[252].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>23</th><th align='left'>เวชศาสตร์นิวเคลียร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f223001' value='#{f2[93].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f223002' value='#{f2[94].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f223003' value='#{f2[95].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f223004' value='#{f2[96].to_s}' #{hcFlag}></td>
     <th>63</th><th align='left'>อายุรศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f263001' value='#{f2[253].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f263002' value='#{f2[254].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f263003' value='#{f2[255].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f263004' value='#{f2[256].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>24</th><th align='left'>รังสีรักษาและเวชศาสตร์นิวเคลียร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f224001' value='#{f2[97].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f224002' value='#{f2[98].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f224003' value='#{f2[99].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f224004' value='#{f2[100].to_s}' #{hcFlag}></td>
    <th>64</th><th align='left'>อายุรศาสตร์โรคเลือด</th>
    <td><input type='text' size='3' style='text-align: right' name='f264001' value='#{f2[257].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f264002' value='#{f2[258].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f264003' value='#{f2[259].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f264004' value='#{f2[260].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>25</th><th align='left'>ภาพวินิจฉัยระบบประสาท(1001)</th>
    <td><input type='text' size='3' style='text-align: right' name='f225001' value='#{f2[101].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f225002' value='#{f2[102].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f225003' value='#{f2[103].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f225004' value='#{f2[104].to_s}' #{hcFlag}></td>
    <th>65</th><th align='left'>อายุรศาสตร์มะเร็งวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f265001' value='#{f2[261].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f265002' value='#{f2[262].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f265003' value='#{f2[263].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f265004' value='#{f2[264].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>26</th><th align='left'>รังสีร่วมรักษาระบบประสาท(1002)</th>
    <td><input type='text' size='3' style='text-align: right' name='f226001' value='#{f2[105].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f226002' value='#{f2[106].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f226003' value='#{f2[107].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f226004' value='#{f2[108].to_s}' #{hcFlag}></td>
    <th>66</th><th align='left'>ประสาทวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f266001' value='#{f2[265].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f266002' value='#{f2[266].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f266003' value='#{f2[267].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f266004' value='#{f2[268].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>27</th><th align='left'>รังสีร่วมรักษาของลำตัว(1003)</th>
    <td><input type='text' size='3' style='text-align: right' name='f227001' value='#{f2[109].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f227002' value='#{f2[110].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f227003' value='#{f2[111].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f227004' value='#{f2[112].to_s}' #{hcFlag}></td>
    <th>67</th><th align='left'>ตจวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f267001' value='#{f2[269].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f267002' value='#{f2[270].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f267003' value='#{f2[271].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f267004' value='#{f2[272].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>28</th><th align='left'>ภาพวินิจฉัยชั้นสูง(1004)</th>
    <td><input type='text' size='3' style='text-align: right' name='f228001' value='#{f2[113].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f228002' value='#{f2[114].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f228003' value='#{f2[115].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f228004' value='#{f2[116].to_s}' #{hcFlag}></td>
    <th>68</th><th align='left'>เวชศาสตร์ฉุกเฉิน</th>
    <td><input type='text' size='3' style='text-align: right' name='f268001' value='#{f2[273].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f268002' value='#{f2[274].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f268003' value='#{f2[275].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f268004' value='#{f2[276].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>29</th><th align='left'>ภาพวินิจฉัยระบบประสาท(1101)</th>
    <td><input type='text' size='3' style='text-align: right' name='f229001' value='#{f2[117].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f229002' value='#{f2[118].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f229003' value='#{f2[119].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f229004' value='#{f2[120].to_s}' #{hcFlag}></td>
    <th>69</th><th align='left'>โลหิตวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f269001' value='#{f2[277].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f269002' value='#{f2[278].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f269003' value='#{f2[279].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f269004' value='#{f2[280].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>30</th><th align='left'>รังสีร่วมรักษาระบบประสาท(1102)</th>
    <td><input type='text' size='3' style='text-align: right' name='f230001' value='#{f2[121].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f230002' value='#{f2[122].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f230003' value='#{f2[123].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f230004' value='#{f2[124].to_s}' #{hcFlag}></td>
    <th>70</th><th align='left'>อายุรศาสตร์โรคทรวงอก</th>
    <td><input type='text' size='3' style='text-align: right' name='f270001' value='#{f2[281].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f270002' value='#{f2[282].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f270003' value='#{f2[283].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f270004' value='#{f2[284].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>31</th><th align='left'>รังสีร่วมรักษาของลำตัว(1103)</th>
    <td><input type='text' size='3' style='text-align: right' name='f231001' value='#{f2[125].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f231002' value='#{f2[126].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f231003' value='#{f2[127].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f231004' value='#{f2[128].to_s}' #{hcFlag}></td>
    <th>71</th><th align='left'>อายุรศาสตร์โรคติดเชื้อ</th>
    <td><input type='text' size='3' style='text-align: right' name='f271001' value='#{f2[285].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f271002' value='#{f2[286].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f271003' value='#{f2[287].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f271004' value='#{f2[288].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>32</th><th align='left'>ภาพวินิจฉัยชั้นสูง(1104)</th>
    <td><input type='text' size='3' style='text-align: right' name='f232001' value='#{f2[129].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f232002' value='#{f2[130].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f232003' value='#{f2[131].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f232004' value='#{f2[132].to_s}' #{hcFlag}></td>
    <th>72</th><th align='left'>อายุรศาสตร์โรคข้อและรูมาติสซั่ม</th>
    <td><input type='text' size='3' style='text-align: right' name='f272001' value='#{f2[289].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f272002' value='#{f2[290].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f272003' value='#{f2[291].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f272004' value='#{f2[292].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>33</th><th align='left'>วิสัญญีวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f233001' value='#{f2[133].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f233002' value='#{f2[134].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f233003' value='#{f2[135].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f233004' value='#{f2[136].to_s}' #{hcFlag}></td>
    <th>73</th><th align='left'>อายุรศาสตร์โรคต่อมไร้ท่อและเมตะบอลิสม</th>
    <td><input type='text' size='3' style='text-align: right' name='f273001' value='#{f2[293].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f273002' value='#{f2[294].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f273003' value='#{f2[295].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f273004' value='#{f2[296].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>34</th><th align='left'>วิสัญญีวิทยาเพื่อการผ่าตัดหัวใจหลอดเลือดใหญ่และทรวงอก</th>
    <td><input type='text' size='3' style='text-align: right' name='f234001' value='#{f2[137].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f234002' value='#{f2[138].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f234003' value='#{f2[139].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f234004' value='#{f2[140].to_s}' #{hcFlag}></td>
    <th>74</th><th align='left'>อายุรศาสตร์โรคภูมิแพ้และอิมมูโนวิทยาคลินิก</th>
    <td><input type='text' size='3' style='text-align: right' name='f274001' value='#{f2[297].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f274002' value='#{f2[298].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f274003' value='#{f2[299].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f274004' value='#{f2[300].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>35</th><th align='left'>วิสัญญีวิทยาสำหรับผู้ป่วยโรคทางระบบประสาท</th>
    <td><input type='text' size='3' style='text-align: right' name='f235001' value='#{f2[141].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f235002' value='#{f2[142].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f235003' value='#{f2[143].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f235004' value='#{f2[144].to_s}' #{hcFlag}></td>
    <th>75</th><th align='left'>อายุรศาสตร์โรคระบบทางเดินอาหาร</th>
    <td><input type='text' size='3' style='text-align: right' name='f275001' value='#{f2[301].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f275002' value='#{f2[302].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f275003' value='#{f2[303].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f275004' value='#{f2[304].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>36</th><th align='left'>เวชปฏิบัติทั่วไป</th>
    <td><input type='text' size='3' style='text-align: right' name='f236001' value='#{f2[145].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f236002' value='#{f2[146].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f236003' value='#{f2[147].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f236004' value='#{f2[148].to_s}' #{hcFlag}></td>
    <th>76</th><th align='left'>อายุรศาสตร์โรคไต</th>
    <td><input type='text' size='3' style='text-align: right' name='f276001' value='#{f2[305].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f276002' value='#{f2[306].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f276003' value='#{f2[307].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f276004' value='#{f2[308].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>37</th><th align='left'>เวชศาสตร์ครอบครัว</th>
    <td><input type='text' size='3' style='text-align: right' name='f237001' value='#{f2[149].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f237002' value='#{f2[150].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f237003' value='#{f2[151].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f237004' value='#{f2[152].to_s}' #{hcFlag}></td>
    <th>77</th><th align='left'>อายุรศาสตร์โรคหัวใจ</th>
    <td><input type='text' size='3' style='text-align: right' name='f277001' value='#{f2[309].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f277002' value='#{f2[310].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f277003' value='#{f2[311].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f277004' value='#{f2[312].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>38</th><th align='left'>เวชศาสตร์ป้องกัน</th>
    <td><input type='text' size='3' style='text-align: right' name='f238001' value='#{f2[153].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f238002' value='#{f2[154].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f238003' value='#{f2[155].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f238004' value='#{f2[156].to_s}' #{hcFlag}></td>
    <th>78</th><th align='left'>อายุรศาสตร์โรคระบบการหายใจและภาวะวิกฤต</th>
    <td><input type='text' size='3' style='text-align: right' name='f278001' value='#{f2[313].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f278002' value='#{f2[314].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f278003' value='#{f2[315].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f278004' value='#{f2[316].to_s}' #{hcFlag}></td>
  </tr>
  <tr bgcolor='beige'>
    <th>39</th><th align='left'>แขนงสาธารณสุขศาสตร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f239001' value='#{f2[157].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f239002' value='#{f2[158].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f239003' value='#{f2[159].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f239004' value='#{f2[160].to_s}' #{hcFlag}></td>
    <th>79</th><th align='left'>เวชบำบัดวิกฤต</th>
    <td><input type='text' size='3' style='text-align: right' name='f279001' value='#{f2[317].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f279002' value='#{f2[318].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f279003' value='#{f2[319].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f279004' value='#{f2[320].to_s}' #{hcFlag}></td>
  </tr>
  <tr>
    <th>40</th><th align='left'>แขนงระบาดวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f240001' value='#{f2[161].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f240002' value='#{f2[162].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f240003' value='#{f2[163].to_s}' #{hcFlag}></td>
    <td><input type='text' size='3' style='text-align: right' name='f240004' value='#{f2[164].to_s}' #{hcFlag}></td>
    <th>&nbsp;</th>&nbsp;<th align='left'></th>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<font color='black'><b>#{statusMsg}</b></font>
<p>
<input id='f2submit' type='submit' value='บันทึกข้อมูล' #{gpFlag} #{hcFlag}><input type='button' 
value='ยกเลิก' onClick="document.location.href='hr_form2.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=CLEAR' ">
</form>
<hr>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
  <tr>
      <td width="25%">#{f1BTN}</td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" onClick="document.location.href='hr_form3.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0&otype=#{otype}' "></td>
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
