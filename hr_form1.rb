#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'res_util.rb'
require 'hr_util.rb'

inpsize = 20
twidth = "40%"
f1 = Array.new

c = CGI::new

user = c['user'].split('').join('')
sessid = c['sessid']
year = c['year'].split('').join('')
repId = c['offReport'].split('').join('')
opt = c['opt']

flag = checkSession(user,sessid)
if !flag
  print "Location:/res53\n\n"
  exit
end

offId = user.to_s
member = getMemberName(offId)
provId = user
province = getProvName(provId)

repName = getOfficeName(repId)
if (repName == 'NA')
  print "Location:/res53/res-02.rb?user=#{user}&sessid=#{sessid}\n\n"
end

reporter_id = offId
reporter_id = "#{offId}01" if offId.length == 2
reporter_id = "#{offId}00" if offId == '10'
reporter = getReporter(reporter_id)

if opt.to_s == 'DEL'
  delForm1Data(year, repId)
elsif opt.to_s == 'CLEAR'
  clearForm1Data(year, repId)
end

if opt.to_s != 'CLEAR'
  f1 = getForm1Data(year,repId)
end

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<!-- src: hr_form1.rb -->
<head >
<title>ข้อมูลทรัพยากรสาธารณสุข</title>
<style>
a {
  text-decoration: none;
}
</style>
<script type="text/javascript">
function remark(n)
{
  var msg = 'Test';
  if (n == 3)
    msg = 'ตำแหน่งเดิมคือ ผู้ช่วยทันตแพทย์ ช่างทันตกรรม ทันตาภิบาล เจ้าพนักงานทันตสาธารณสุข';
  else if (n == 7)
    msg = 'ตำแหน่งเดิมคือ ผู้ช่วยเภสัชกร เจ้าพนักงานเภสัชกรรม';
  else if (n == 9)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่พยาบาล พยาบาลเทคนิค';
  else if (n == 11)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่ผดุงครรภ์สาธารณสุข';
  else if (n == 12)
    msg = 'ตำแหน่งเดิมคือ นักวิชาการสุขศึกษา นักวิชาการส่งเสริมสุขภาพ นักวิชาการควบคุมโรค นักวิชาการสาธารณสุข';
  else if (n == 17)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่กายภาพบำบัด เจ้าพนักงานเวชกรรมฟื้นฟู';
  else if (n == 20)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่วิทยาศาสตร์การแพทย์ เจ้าพนักงานวิทยาศาสตร์การแพทย์';
  else if (n == 23)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่รังสีการแพทย์ เจ้าหน้าที่เอ็กซเรย์';
  else if (n == 28)
    msg = 'ตำแหน่งเดิมคือ นักสถิติ';
  else if (n == 29)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่เวชสถิติ';
  else if (n == 30)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่สถิติ เจ้าพนักงานสถิติ';
  else if (n == 31)
    msg = 'ตำแหน่งเดิมคือ เจ้าพนักงานควบคุมโรค เจ้าหน้าที่ควบคุมโรค เจ้าหน้าที่ส่งเสริมสุขภาพ เจ้าหน้าที่สุขาภิบาล เจ้าพนักงานสุขาภิบาล';
  else if (n == 32)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่วิเคราะห์นโยบายและแผน';
  else if (n == 36)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่บริหารงานทั่วไป';
  else if (n == 37)
    msg = 'ตำแหน่งเดิมคือ บุคลากร';
  else if (n == 38)
    msg = 'ตำแหน่งเดิมคือ เจ้าหน้าที่โสตทัศนศึกษา เจ้าพนักงานโสตทัศนศึกษา';
  else if (n == 40)
  {
    msg = 'สายงานนี้คลุมถึงตำแหน่งต่างๆ ที่ปฏิบัติงานทางวิชาการในการ ส่งเสริม ป้องกัน ';
    msg += 'บำบัด ฟื้นฟูสมรรถภาพ ของผู้ที่มีความบกพร่องหรือพิการทางด้านร่างกาย จิตใจ ';
    msg += 'การเรียนรู้ และพัฒนาการซึ่งมีลักษณะงานที่ปฏิบัติเกี่ยวกับ การปฏิบัติงานบริหาร';
    msg += 'ทางกิจกรรมบำบัด การนิเทศงาน และฝึกอบรมวิชา กิจกรรมบำบัด';
    msg += '<p><b>คุณวุฒิ</b> ได้รับปริญญาตรี หรือคุณวุฒิอย่างอื่นที่เทียบได้ในระดับเดียวกัน ';
    msg += 'ในสาขาวิทยาศาสตร์การแพทย์ ทางกิจกรรมบำบัด และได้รับใบอนุญาต';
    msg += 'เป็นผู้ประกอบโรคศิลปะสาขากิจกรรมบำบัด';
  }
  return msg;
}
</script>
</head>

<body text='blue'>
<script type="text/javascript" src="js/wz_tooltip.js"></script>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" onClick="document.location.href='hr_form2.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" onClick="document.location.href='hr_form3.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 4" style="width:100%" onClick="document.location.href='hr_form4.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
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
     <th><h3><b><font color='black'>แบบบันทึกข้อมูลทรัพยากรสาธารณสุข</font>
     <font color= 'yellow'>&nbsp;(ภาครัฐ)</font></b>
     <font color='black'>&nbsp;&nbsp;โดย คุณ#{member}
     <br />#{reporter}</font></h3></th>
     </tr>
     </table>
     <h3>ส่วนที่&nbsp;1&nbsp;&nbsp;บุคลากรทางการแพทย์และสาธารณสุข</h3>

    <form action='form1.rb' method='post'>
    <input type='hidden' name='user' value='#{user}'>
    <input type='hidden' name='sessid' value='#{sessid}'>
    <font size='4'><b>ตารางที่ 1 จำนวนบุคลากรที่ปฏิบัติงานจริงจำแนกตามชื่อตำแหน่ง  ณ 30 กันยายน</b></font>
    <font color='black'>&nbsp;&nbsp; พ.ศ.</font>&nbsp;&nbsp;<font color='black'><b>2553</b></font>

    <p>
    <input type='hidden' name='f1year' value='2553'>
    <input type='hidden' name='f1pname' value='#{province}'>
    <input type='hidden' name='f1pcode' value='#{offId}'>
    <input type='hidden' name='f1hname' value='#{repName}'>
    <input type='hidden' name='f1hcode' value='#{repId}'>
    <font color='black'><b>จังหวัด</b></font>&nbsp;<font color='black'><b>#{province}</b></font>
    <font color='black'><b>รหัสจังหวัด</b></font>&nbsp;<font color='black'><b>#{provId[0..1]}</b></font>
    <font color='black'><b>ชื่อหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repName}</b></font></b>
    <font color='black'><b>รหัสหน่วยงาน</b></font>&nbsp;<font color='black'><b>#{repId}</b></font>
    </p>

    <table border='1' width='100%' >

    <tr bgcolor='pink'>
    <th rowspan='3'><font size='2'>ลำดับ</font></th>
    <th rowspan='3'><font size='2'>ชื่อตำแหน่ง</font></th>
    <th colspan='4'><font size='2'>จำนวน(คน)</font></th>
    <th rowspan='3'><font size='2'>ลำดับ</font></th>
    <th rowspan='3'><font size='2'>ชื่อตำแหน่ง</font></th>
    <th colspan='4'><font size='2'>จำนวน(คน)</font></th>
    </tr>

  <tr bgcolor='pink'>
   <th colspan='2'><font size='2'>ขรก.และ<br>พ.ของรัฐ</font></th><th colspan='2'><font size='2'>ลูกจ้าง</font></th>
   <th colspan='2'><font size='2'>ขรก.และ<br>พ.ของรัฐ</font></th><th colspan='2'><font size='2'>ลูกจ้าง</font></th>
  </tr>

  <tr bgcolor='pink'>
   <th>ช</th><th>ญ</th><th>ช</th><th>ญ</th>
   <th>ช</th><th>ญ</th><th>ช</th><th>ญ</th>
  </tr>

  <tr bgcolor='beige'>
    <th>1</th><th align='left'>นายแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f101001' value='#{f1[5].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f101002' value='#{f1[6].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f101003' value='#{f1[7].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f101004' value='#{f1[8].to_s}'></td>
    <th>21</th><th align='left'>นักรังสี (นักฟิสิกส์รังสี) </th>
    <td ><input type='text' size='3' style='text-align: right' name='f121001' value='#{f1[85].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f121002' value='#{f1[86].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f121003' value='#{f1[87].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f121004' value='#{f1[88].to_s}'></td>
  </tr>

   
  <tr>
    <th>2</th><th align='left'>ทันตแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f102001' value='#{f1[9].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f102002' value='#{f1[10].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f102003' value='#{f1[11].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f102004' value='#{f1[12].to_s}'></td>
    <th>22</th><th align='left'>นักรังสีการแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f122001' value='#{f1[89].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f122002' value='#{f1[90].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f122003' value='#{f1[91].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f122004' value='#{f1[92].to_s}'></td>
  </tr>

  <tr  bgcolor='beige'>
    <th>3</th><th align='left'><a href='#' onmouseover='Tip(remark(3),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานทันตสาธารณสุข</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f103001' value='#{f1[13].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f103002' value='#{f1[14].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f103003' value='#{f1[15].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f103004' value='#{f1[16].to_s}'></td>
    <th>23</th><th align='left'><a href='#' onmouseover='Tip(remark(23),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานรังสีการแพทย์</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f123001' value='#{f1[93].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f123002' value='#{f1[94].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f123003' value='#{f1[95].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f123004' value='#{f1[96].to_s}'></td>
  </tr>

  <tr>
    <th>4</th><th align='left'>นายสัตวแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f104001' value='#{f1[17].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f104002' value='#{f1[18].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f104003' value='#{f1[19].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f104004' value='#{f1[20].to_s}'></td>
    <th>24</th><th align='left'>นักโภชนาการ</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f124001' value='#{f1[97].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f124002' value='#{f1[98].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f124003' value='#{f1[99].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f124004' value='#{f1[100].to_s}'></td>
  </tr>

  <tr  bgcolor='beige'>
    <th>5</th><th align='left'>สัตวแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f105001' value='#{f1[21].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f105002' value='#{f1[22].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f105003' value='#{f1[23].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f105004' value='#{f1[24].to_s}'></td>
    <th>25</th><th align='left'>โภชนากร</th>
    <td><input type='text' size='3' style='text-align: right' name='f125001' value='#{f1[101].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f125002' value='#{f1[102].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f125003' value='#{f1[103].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f125004' value='#{f1[104].to_s}'></td>
  </tr>

  <tr>
    <th>6</th><th align='left'>เภสัชกร</th>
    <td><input type='text' size='3' style='text-align: right' name='f106001' value='#{f1[25].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f106002' value='#{f1[26].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f106003' value='#{f1[27].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f106004' value='#{f1[28].to_s}'></td>
    <th>26</th><th align='left'>นักจิตวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f126001' value='#{f1[105].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f126002' value='#{f1[106].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f126003' value='#{f1[107].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f126004' value='#{f1[108].to_s}'></td>
  </tr>

  <tr  bgcolor='beige'>
    <th>7</th><th align='left'><a href='#' onmouseover='Tip(remark(7),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานเภสัชกรรม</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f107001' value='#{f1[29].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f107002' value='#{f1[30].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f107003' value='#{f1[31].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f107004' value='#{f1[32].to_s}'></td>
    <th>27</th><th align='left'>นักสังคมสงเคราะห์</th>
    <td><input type='text' size='3' style='text-align: right' name='f127001' value='#{f1[109].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f127002' value='#{f1[110].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f127003' value='#{f1[111].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f127004' value='#{f1[112].to_s}'></td>
  </tr>

  <tr>
    <th>8</th><th align='left'>พยาบาลวิชาชีพ</th>
    <td><input type='text' size='3' style='text-align: right' name='f108001' value='#{f1[33].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f108002' value='#{f1[34].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f108003' value='#{f1[35].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f108004' value='#{f1[36].to_s}'></td>
    <th>28</th><th align='left'><a href='#' onmouseover='Tip(remark(28),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักวิชาการสถิติ</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f128001' value='#{f1[113].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f128002' value='#{f1[114].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f128003' value='#{f1[115].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f128004' value='#{f1[116].to_s}'></td>
  </tr>

  <tr  bgcolor='beige'>
    <th>9</th><th align='left'><a href='#' onmouseover='Tip(remark(9),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>พยาบาลเทคนิค</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f109001' value='#{f1[37].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f109002' value='#{f1[38].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f109003' value='#{f1[39].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f109004' value='#{f1[40].to_s}'></td>
    <th>29</th><th align='left'><a href='#' onmouseover='Tip(remark(29),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานเวชสถิติ</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f129001' value='#{f1[117].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f129002' value='#{f1[118].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f129003' value='#{f1[119].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f129004' value='#{f1[120].to_s}'></td>
  </tr>

  <tr>
    <th>10</th><th align='left'>วิสัญญีพยาบาล</th>
    <td><input type='text' size='3' style='text-align: right' name='f110001' value='#{f1[41].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f110002' value='#{f1[42].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f110003' value='#{f1[43].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f110004' value='#{f1[44].to_s}'></td>
    <th>30</th><th align='left'><a href='#' onmouseover='Tip(remark(30),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานสถิติ</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f130001' value='#{f1[121].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f130002' value='#{f1[122].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f130003' value='#{f1[123].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f130004' value='#{f1[124].to_s}'></td>
  </tr>

  <tr bgcolor='beige'>
    <th>11</th><th align='left'><a href='#' onmouseover='Tip(remark(11),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานผดุงครรภ์สาธารณสุข</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f111001' value='#{f1[45].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f111002' value='#{f1[46].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f111003' value='#{f1[47].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f111004' value='#{f1[48].to_s}'></td>
    <th>31</th><th align='left'><a href='#' onmouseover='Tip(remark(31),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานสาธารณสุข</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f131001' value='#{f1[125].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f131002' value='#{f1[126].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f131003' value='#{f1[127].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f131004' value='#{f1[128].to_s}'></td>
  </tr>

  <tr>
    <th>12</th><th align='left'><a href='#' onmouseover='Tip(remark(12),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักวิชาการสาธารณสุข</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f112001' value='#{f1[49].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f112002' value='#{f1[50].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f112003' value='#{f1[51].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f112004' value='#{f1[52].to_s}'</td>
    <th>32</th><th align='left'><a href='#' onmouseover='Tip(remark(32),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักวิเคราะห์นโยบายและแผน</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f132001' value='#{f1[129].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f132002' value='#{f1[130].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f132003' value='#{f1[131].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f132004' value='#{f1[132].to_s}'</td>
  </tr>

  <tr bgcolor='beige'>
    <th>13</th><th align='left'>นักวิชาการสุขาภิบาล</th>
    <td><input type='text' size='3' style='text-align: right' name='f113001' value='#{f1[53].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f113002' value='#{f1[54].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f113003' value='#{f1[55].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f113004' value='#{f1[56].to_s}'</td>
    <th>33</th><th align='left'>ผู้ปฏิบัติงานด้านการแพทย์แผนไทย</th>
    <td><input type='text' size='3' style='text-align: right' name='f133001' value='#{f1[133].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f133002' value='#{f1[134].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f133003' value='#{f1[135].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f133004' value='#{f1[136].to_s}'</td>
  </tr>
   
  <tr>
    <th>14</th><th align='left'>นักกายภาพบำบัด</th>
    <td><input type='text' size='3' style='text-align: right' name='f114001' value='#{f1[57].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f114002' value='#{f1[58].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f114003' value='#{f1[59].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f114004' value='#{f1[60].to_s}'</td>
    <th>34</th><th align='left'>นักวิชาการเงินและบัญชี</th>
    <td><input type='text' size='3' style='text-align: right' name='f134001' value='#{f1[137].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f134002' value='#{f1[138].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f134003' value='#{f1[139].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f134004' value='#{f1[140].to_s}'</td>
  </tr>

  <tr bgcolor='beige'>
    <th>15</th><th align='left'>นักอาชีวบำบัด</th>
    <td><input type='text' size='3' style='text-align: right' name='f115001' value='#{f1[61].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f115002' value='#{f1[62].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f115003' value='#{f1[63].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f115004' value='#{f1[64].to_s}'</td>
    <th>35</th><th align='left'>นักวิชาการคอมพิวเตอร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f135001' value='#{f1[141].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f135002' value='#{f1[142].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f135003' value='#{f1[143].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f135004' value='#{f1[144].to_s}'</td>
  </tr>

  <tr>
    <th>16</th><th align='left'>เจ้าพนักงานอาชีวบำบัด</th>
    <td><input type='text' size='3' style='text-align: right' name='f116001' value='#{f1[65].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f116002' value='#{f1[66].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f116003' value='#{f1[67].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f116004' value='#{f1[68].to_s}'</td>
    <th>36</th><th align='left'><a href='#' onmouseover='Tip(remark(36),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักจัดการงานทั่วไป</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f136001' value='#{f1[145].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f136002' value='#{f1[146].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f136003' value='#{f1[147].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f136004' value='#{f1[148].to_s}'</td>
  </tr>

  <tr bgcolor='beige'>
    <th>17</th><th align='left'><a href='#' onmouseover='Tip(remark(17),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานเวชกรรมฟื้นฟู</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f117001' value='#{f1[69].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f117002' value='#{f1[70].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f117003' value='#{f1[71].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f117004' value='#{f1[72].to_s}'</td>
    <th>37</th><th align='left'><a href='#' onmouseover='Tip(remark(37),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักทรัพยากรบุคคล</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f137001' value='#{f1[149].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f137002' value='#{f1[150].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f137003' value='#{f1[151].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f137004' value='#{f1[152].to_s}'</td>
  </tr>

  <tr>
    <th>18</th><th align='left'>นักเทคนิคการแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f118001' value='#{f1[73].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f118002' value='#{f1[74].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f118003' value='#{f1[75].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f118004' value='#{f1[76].to_s}'</td>
    <th>38</th><th align='left'><a href='#' onmouseover='Tip(remark(38),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานโสตทัศนศึกษา</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f138001' value='#{f1[153].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f138002' value='#{f1[154].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f138003' value='#{f1[155].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f138004' value='#{f1[156].to_s}'</td>
  </tr>

  <tr  bgcolor='beige'>
    <th>19</th><th align='left'>นักวิทยาศาสตร์การแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f119001' value='#{f1[77].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f119002' value='#{f1[78].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f119003' value='#{f1[79].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f119004' value='#{f1[80].to_s}'</td>
    <th>39</th><th align='left'>นักวิชาการอาหารและยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f139001' value='#{f1[157].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f139002' value='#{f1[158].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f139003' value='#{f1[159].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f139004' value='#{f1[160].to_s}'</td>
  </tr>

  <tr>
    <th>20</th><th align='left'><a href='#' onmouseover='Tip(remark(20),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานวิทยาศาสตร์การแพทย์</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f120001' value='#{f1[81].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f120002' value='#{f1[82].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f120003' value='#{f1[83].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f120004' value='#{f1[84].to_s}'</td>
    <th>40</th><th align='left'><a href='#' onmouseover='Tip(remark(40),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักกิจกรรมบำบัด</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f140001' value='#{f1[161].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f140002' value='#{f1[162].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f140003' value='#{f1[163].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f140004' value='#{f1[164].to_s}'</td>
  </tr>
  
</table>
<font color='black'><b>กรุณาตรวจสอบข้อมูลให้ถูกต้องอีกครั้งก่อนกดปุ่ม</b></font>
<p>
<input type='submit' value='บันทึกข้อมูล'><input type='button' value='ยกเลิก' onClick="document.location.href='hr_form1.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=CLEAR' ">
</form>
<hr>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" onClick="document.location.href='hr_form2.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 3" style="width:100%" onClick="document.location.href='hr_form3.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
      <td width="25%"><input type="button" value="Form 4" style="width:100%" onClick="document.location.href='hr_form4.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
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
