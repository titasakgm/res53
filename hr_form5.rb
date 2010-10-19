#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'res_util.rb'
require 'hr_util.rb'

inpsize = 20
twidth = "40%"
f5 = Array.new

c = CGI::new

user = c['user'].split('').join('')
sessid = c['sessid']
year = c['year'].split('').join('')
repId = c['offReport'].split('').join('')
opt = c['opt'].to_s.split('').join('')

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
  delForm5Data(year, repId)
elsif opt.to_s == 'CLEAR'
  clearForm5Data(year, repId)
end

if opt.to_s != 'CLEAR'
  f5 = getForm5Data(year,repId)
end

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<!-- src: hr_form5.rb -->
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

<body ='blue'>
<script type="text/javascript" src="js/wz_tooltip.js"></script>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" onClick="document.location.href='hr_form6.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
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
     <th><h3><b><font color='black'>แบบบันทึกข้อมูลทรัพยากรสาธารณสุข</font>
     <font color= 'yellow'>&nbsp;(ภาคเอกชน)</font></b>
     <font color='black'>&nbsp;&nbsp;โดย คุณ#{member}
     <br />#{reporter}</font></h3></th>
     </tr>
     </table>
     <h3>ส่วนที่&nbsp;1&nbsp;&nbsp;บุคลากรทางการแพทย์และสาธารณสุข</h3>

    <form action='form5.rb' method='post'>
    <input type='hidden' name='user' value='#{user}'>
    <input type='hidden' name='sessid' value='#{sessid}'>
    <font size='4'><b>ตารางที่ 1 จำนวนบุคลากรที่ปฏิบัติงานจริงจำแนกตามชื่อตำแหน่ง  ณ 30 กันยายน</b></font>
    <font color='black'>&nbsp;&nbsp; พ.ศ.</font>&nbsp;&nbsp;<font color='black'><b>2553</b></font>

    <p>
    <input type='hidden' name='f5year' value='2553'>
    <input type='hidden' name='f5pname' value='#{province}'>
    <input type='hidden' name='f5pcode' value='#{offId}'>
    <input type='hidden' name='f5hname' value='#{repName}'>
    <input type='hidden' name='f5hcode' value='#{repId}'>
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
   <th colspan='2'><font size='2'>Full Time</font></th><th colspan='2'><font size='2'>Part Time</font></th>
   <th colspan='2'><font size='2'>Full Time</font></th><th colspan='2'><font size='2'>Part Time</font></th>
  </tr>

  <tr bgcolor='pink'>
   <th>ช</th><th>ญ</th><th>ช</th><th>ญ</th>
   <th>ช</th><th>ญ</th><th>ช</th><th>ญ</th>
  </tr>

  <tr bgcolor='beige'>
    <th>1</th><th align='left'>นายแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f501001' value='#{f5[5].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f501002' value='#{f5[6].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f501003' value='#{f5[7].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f501004' value='#{f5[8].to_s}'></td>
    <th>21</th><th align='left'>นักรังสี (นักฟิสิกส์รังสี) </th>
    <td ><input type='text' size='3' style='text-align: right' name='f521001' value='#{f5[85].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f521002' value='#{f5[86].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f521003' value='#{f5[87].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f521004' value='#{f5[88].to_s}'></td>
  </tr>

   
  <tr>
    <th>2</th><th align='left'>ทันตแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f502001' value='#{f5[9].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f502002' value='#{f5[10].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f502003' value='#{f5[11].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f502004' value='#{f5[12].to_s}'></td>
    <th>22</th><th align='left'>นักรังสีการแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f522001' value='#{f5[89].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f522002' value='#{f5[90].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f522003' value='#{f5[91].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f522004' value='#{f5[92].to_s}'></td>
  </tr>

  <tr  bgcolor='beige'>
    <th>3</th><th align='left'><a href='#' onmouseover='Tip(remark(3),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานทันตสาธารณสุข</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f503001' value='#{f5[13].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f503002' value='#{f5[14].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f503003' value='#{f5[15].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f503004' value='#{f5[16].to_s}'></td>
    <th>23</th><th align='left'><a href='#' onmouseover='Tip(remark(23),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานรังสีการแพทย์</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f523001' value='#{f5[93].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f523002' value='#{f5[94].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f523003' value='#{f5[95].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f523004' value='#{f5[96].to_s}'></td>
  </tr>

  <tr>
    <th>4</th><th align='left'>นายสัตวแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f504001' value='#{f5[17].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f504002' value='#{f5[18].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f504003' value='#{f5[19].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f504004' value='#{f5[20].to_s}'></td>
    <th>24</th><th align='left'>นักโภชนาการ</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f524001' value='#{f5[97].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f524002' value='#{f5[98].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f524003' value='#{f5[99].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f524004' value='#{f5[100].to_s}'></td>
  </tr>

  <tr  bgcolor='beige'>
    <th>5</th><th align='left'>สัตวแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f505001' value='#{f5[21].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f505002' value='#{f5[22].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f505003' value='#{f5[23].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f505004' value='#{f5[24].to_s}'></td>
    <th>25</th><th align='left'>โภชนากร</th>
    <td><input type='text' size='3' style='text-align: right' name='f525001' value='#{f5[101].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f525002' value='#{f5[102].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f525003' value='#{f5[103].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f525004' value='#{f5[104].to_s}'></td>
  </tr>

  <tr>
    <th>6</th><th align='left'>เภสัชกร</th>
    <td><input type='text' size='3' style='text-align: right' name='f506001' value='#{f5[25].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f506002' value='#{f5[26].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f506003' value='#{f5[27].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f506004' value='#{f5[28].to_s}'></td>
    <th>26</th><th align='left'>นักจิตวิทยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f526001' value='#{f5[105].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f526002' value='#{f5[106].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f526003' value='#{f5[107].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f526004' value='#{f5[108].to_s}'></td>
  </tr>

  <tr  bgcolor='beige'>
    <th>7</th><th align='left'><a href='#' onmouseover='Tip(remark(7),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานเภสัชกรรม</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f507001' value='#{f5[29].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f507002' value='#{f5[30].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f507003' value='#{f5[31].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f507004' value='#{f5[32].to_s}'></td>
    <th>27</th><th align='left'>นักสังคมสงเคราะห์</th>
    <td><input type='text' size='3' style='text-align: right' name='f527001' value='#{f5[109].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f527002' value='#{f5[110].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f527003' value='#{f5[111].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f527004' value='#{f5[112].to_s}'></td>
  </tr>

  <tr>
    <th>8</th><th align='left'>พยาบาลวิชาชีพ</th>
    <td><input type='text' size='3' style='text-align: right' name='f508001' value='#{f5[33].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f508002' value='#{f5[34].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f508003' value='#{f5[35].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f508004' value='#{f5[36].to_s}'></td>
    <th>28</th><th align='left'><a href='#' onmouseover='Tip(remark(28),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักวิชาการสถิติ</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f528001' value='#{f5[113].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f528002' value='#{f5[114].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f528003' value='#{f5[115].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f528004' value='#{f5[116].to_s}'></td>
  </tr>

  <tr  bgcolor='beige'>
    <th>9</th><th align='left'><a href='#' onmouseover='Tip(remark(9),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>พยาบาลเทคนิค</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f509001' value='#{f5[37].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f509002' value='#{f5[38].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f509003' value='#{f5[39].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f509004' value='#{f5[40].to_s}'></td>
    <th>29</th><th align='left'><a href='#' onmouseover='Tip(remark(29),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานเวชสถิติ</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f529001' value='#{f5[117].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f529002' value='#{f5[118].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f529003' value='#{f5[119].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f529004' value='#{f5[120].to_s}'></td>
  </tr>

  <tr>
    <th>10</th><th align='left'>วิสัญญีพยาบาล</th>
    <td><input type='text' size='3' style='text-align: right' name='f510001' value='#{f5[41].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f510002' value='#{f5[42].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f510003' value='#{f5[43].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f510004' value='#{f5[44].to_s}'></td>
    <th>30</th><th align='left'><a href='#' onmouseover='Tip(remark(30),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานสถิติ</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f530001' value='#{f5[121].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f530002' value='#{f5[122].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f530003' value='#{f5[123].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f530004' value='#{f5[124].to_s}'></td>
  </tr>

  <tr bgcolor='beige'>
    <th>11</th><th align='left'><a href='#' onmouseover='Tip(remark(11),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานผดุงครรภ์สาธารณสุข</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f511001' value='#{f5[45].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f511002' value='#{f5[46].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f511003' value='#{f5[47].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f511004' value='#{f5[48].to_s}'></td>
    <th>31</th><th align='left'><a href='#' onmouseover='Tip(remark(31),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานสาธารณสุข</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f531001' value='#{f5[125].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f531002' value='#{f5[126].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f531003' value='#{f5[127].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f531004' value='#{f5[128].to_s}'></td>
  </tr>

  <tr>
    <th>12</th><th align='left'><a href='#' onmouseover='Tip(remark(12),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักวิชาการสาธารณสุข</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f512001' value='#{f5[49].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f512002' value='#{f5[50].to_s}'></td>
    <td><input type='text' size='3' style='text-align: right' name='f512003' value='#{f5[51].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f512004' value='#{f5[52].to_s}'</td>
    <th>32</th><th align='left'><a href='#' onmouseover='Tip(remark(32),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักวิเคราะห์นโยบายและแผน</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f532001' value='#{f5[129].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f532002' value='#{f5[130].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f532003' value='#{f5[131].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f532004' value='#{f5[132].to_s}'</td>
  </tr>

  <tr bgcolor='beige'>
    <th>13</th><th align='left'>นักวิชาการสุขาภิบาล</th>
    <td><input type='text' size='3' style='text-align: right' name='f513001' value='#{f5[53].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f513002' value='#{f5[54].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f513003' value='#{f5[55].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f513004' value='#{f5[56].to_s}'</td>
    <th>33</th><th align='left'>ผู้ปฏิบัติงานด้านการแพทย์แผนไทย</th>
    <td><input type='text' size='3' style='text-align: right' name='f533001' value='#{f5[133].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f533002' value='#{f5[134].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f533003' value='#{f5[135].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f533004' value='#{f5[136].to_s}'</td>
  </tr>
   
  <tr>
    <th>14</th><th align='left'>นักกายภาพบำบัด</th>
    <td><input type='text' size='3' style='text-align: right' name='f514001' value='#{f5[57].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f514002' value='#{f5[58].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f514003' value='#{f5[59].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f514004' value='#{f5[60].to_s}'</td>
    <th>34</th><th align='left'>นักวิชาการเงินและบัญชี</th>
    <td><input type='text' size='3' style='text-align: right' name='f534001' value='#{f5[137].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f534002' value='#{f5[138].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f534003' value='#{f5[139].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f534004' value='#{f5[140].to_s}'</td>
  </tr>

  <tr bgcolor='beige'>
    <th>15</th><th align='left'>นักอาชีวบำบัด</th>
    <td><input type='text' size='3' style='text-align: right' name='f515001' value='#{f5[61].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f515002' value='#{f5[62].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f515003' value='#{f5[63].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f515004' value='#{f5[64].to_s}'</td>
    <th>35</th><th align='left'>นักวิชาการคอมพิวเตอร์</th>
    <td><input type='text' size='3' style='text-align: right' name='f535001' value='#{f5[141].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f535002' value='#{f5[142].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f535003' value='#{f5[143].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f535004' value='#{f5[144].to_s}'</td>
  </tr>

  <tr>
    <th>16</th><th align='left'>เจ้าพนักงานอาชีวบำบัด</th>
    <td><input type='text' size='3' style='text-align: right' name='f516001' value='#{f5[65].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f516002' value='#{f5[66].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f516003' value='#{f5[67].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f516004' value='#{f5[68].to_s}'</td>
    <th>36</th><th align='left'><a href='#' onmouseover='Tip(remark(36),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักจัดการงานทั่วไป</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f536001' value='#{f5[145].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f536002' value='#{f5[146].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f536003' value='#{f5[147].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f536004' value='#{f5[148].to_s}'</td>
  </tr>

  <tr bgcolor='beige'>
    <th>17</th><th align='left'><a href='#' onmouseover='Tip(remark(17),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานเวชกรรมฟื้นฟู</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f517001' value='#{f5[69].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f517002' value='#{f5[70].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f517003' value='#{f5[71].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f517004' value='#{f5[72].to_s}'</td>
    <th>37</th><th align='left'><a href='#' onmouseover='Tip(remark(37),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักทรัพยากรบุคคล</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f537001' value='#{f5[149].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f537002' value='#{f5[150].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f537003' value='#{f5[151].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f537004' value='#{f5[152].to_s}'</td>
  </tr>

  <tr>
    <th>18</th><th align='left'>นักเทคนิคการแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f518001' value='#{f5[73].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f518002' value='#{f5[74].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f518003' value='#{f5[75].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f518004' value='#{f5[76].to_s}'</td>
    <th>38</th><th align='left'><a href='#' onmouseover='Tip(remark(38),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานโสตทัศนศึกษา</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f538001' value='#{f5[153].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f538002' value='#{f5[154].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f538003' value='#{f5[155].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f538004' value='#{f5[156].to_s}'</td>
  </tr>

  <tr  bgcolor='beige'>
    <th>19</th><th align='left'>นักวิทยาศาสตร์การแพทย์</th>
    <td><input type='text' size='3' style='text-align: right' name='f519001' value='#{f5[77].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f519002' value='#{f5[78].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f519003' value='#{f5[79].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f519004' value='#{f5[80].to_s}'</td>
    <th>39</th><th align='left'>นักวิชาการอาหารและยา</th>
    <td><input type='text' size='3' style='text-align: right' name='f539001' value='#{f5[157].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f539002' value='#{f5[158].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f539003' value='#{f5[159].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f539004' value='#{f5[160].to_s}'</td>
  </tr>

  <tr>
    <th>20</th><th align='left'><a href='#' onmouseover='Tip(remark(20),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>เจ้าพนักงานวิทยาศาสตร์การแพทย์</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f520001' value='#{f5[81].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f520002' value='#{f5[82].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f520003' value='#{f5[83].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f520004' value='#{f5[84].to_s}'</td>
    <th>40</th><th align='left'><a href='#' onmouseover='Tip(remark(40),
      TITLE,"คำอธิบาย",WIDTH,250,ABOVE,true)'
      onmouseout='UnTip()'>นักกิจกรรมบำบัด</a></th>
    <td><input type='text' size='3' style='text-align: right' name='f540001' value='#{f5[161].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f540002' value='#{f5[162].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f540003' value='#{f5[163].to_s}'</td>
    <td><input type='text' size='3' style='text-align: right' name='f540004' value='#{f5[164].to_s}'</td>
  </tr>
  
</table>
<font color='black'><b>กรุณาตรวจสอบข้อมูลให้ถูกต้องอีกครั้งก่อนกดปุ่ม</b></font>
<p>
<input type='submit' value='บันทึกข้อมูล'><input type='button' value='ยกเลิก' onClick="document.location.href='hr_form5.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=CLEAR' ">
</form>
<hr>
<table width="100%" border="0">
<tr>
<td width="50%">
  <table width="100%" border="0">
    <tr>
      <td width="25%"><input type="button" value="Form 1" style="width:100%" disabled></td>
      <td width="25%"><input type="button" value="Form 2" style="width:100%" onClick="document.location.href='hr_form6.rb?user=#{user}&sessid=#{sessid}&year=2553&offReport=#{repId}&opt=0' "></td>
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
