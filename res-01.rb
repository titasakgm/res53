#!/usr/bin/ruby

require 'cgi'
require 'res_util.rb'

c = CGI::new
user = c['user']
pass = c['pass']
prov = c['res-prov']

opt_prov = getProvOption(prov)
opt_amp = getAmpOption(prov)

msg1 = nil
msg2 = nil

#errMsg("เปิดให้บริการ 20 ตุลาคม 2553")

if (user.to_s.length > 0)
  sessid = authenUser(user, pass)
  if (sessid != 'FAILED')
    if (user == 'admin')
      print "Location:res-03.rb?user=#{user}&sessid=#{sessid}\n\n"
    else
      print "Location:res-02.rb?user=#{user}&sessid=#{sessid}\n\n"
    end
  else
    msg1 = "Login failed!.."
  end
end

=begin
if (user.to_s.length > 0 && pass == 'hic52')
  sessid = authenUser(user, pass)
  if (user == 'admin')
    print "Location:res-03.rb?user=#{user}&sessid=#{sessid}\n\n"
  else
    print "Location:res-02.rb?user=#{user}&sessid=#{sessid}\n\n"
  end
else
  msg1 = "ขออภัย ปิดรับการบันทึกข้อมูลแล้ว"
end
=end

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<head>
<title>รายงานทรัพยากรสาธารณสุข</title>
<style>
body {
  text:green;
}
li {
  padding-top:5px;
}
#page {
  width: 100%;
  margin: 0;
  padding: 0;
}
#left {
  position:relative;
  float:left;
  width: 21%;
  text-align: center;
}
#right {
  position: relative;
  float: left;
  width: 77%;
  margin-left: 1%;
  /* background-color: #EBE9ED; */
}
#res_title {
  position:relative;
  float:left;
  clear: both;
  width:100%;
  text-align:center;
}
#res_member {
  position:relative;
  float:left;
  width: 100%;
  height: 180px;
  text-align:center;
  background-image: url(images/bgg1.jpg);
}
#res_member td,th {
  font-size:12px;
  font-weight:normal;
}
#res_admin {
  position:relative;
  float:left;
  width: 100%;
  height: 180px;
  margin-top: 2px;
  text-align:center;
  background-image: url(images/bgg1.jpg);
}
#res_admin td,th {
  font-size:14px;
  font-weight:normal;
}
#res_calendar {
  position:relative;
  float: left;
  width: 100%;
  margin-top: 2px;
  text-align: center;
}
#res_option {
  position:relative;
  width: 100%;
  float:left;
}
.ipx60 {
  width:60px;
}
.ipc100 {
  width:100%;
}
#s1 {
  width: 100%;
  padding-top: 2px;
  padding-bottom: 2px;
  background-color: #339900;
}
#s3 {
  width: 100%;
  padding-top: 2px;
  padding-bottom: 2px;
  background-color: #FF9900;
}
#rr {
  position: relative;
  float: right;
  margin-top: 0;
  margin-right: 5px;
  text-align: right;
}
.main {
width:200px;
border:1px solid black;
}

.month {
background-color:black;
font:bold 12px verdana;
color:white;
}

.daysofweek {
background-color:gray;
font:bold 12px verdana;
color:white;
}

.days {
font-size: 12px;
font-family:verdana;
color:black;
background-color: lightyellow;
padding: 2px;
}

.days #today{
font-weight: bold;
color: red;
}
</style>

<script type="text/javascript">
/***********************************************
* Basic Calendar-By Brian Gosselin at http://scriptasylum.com/bgaudiodr/
* Script featured on Dynamic Drive (http://www.dynamicdrive.com)
* This notice must stay intact for use
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/
function buildCal(m, y, cM, cH, cDW, cD, brdr)
{
  var newY = parseInt(y + 543); //change from 2009 to 2552

  var mn=['มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน','กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'];
  var dim=[31,0,31,30,31,30,31,31,30,31,30,31];

  var oD = new Date(y, m-1, 1); //DD replaced line to fix date bug when current day is 31st
  oD.od=oD.getDay()+1; //DD replaced line to fix date bug when current day is 31st

  var todaydate=new Date() //DD added
  var scanfortoday=(y==todaydate.getFullYear() && m==todaydate.getMonth()+1)? todaydate.getDate() : 0 //DD added

  dim[1]=(((oD.getFullYear()%100!=0)&&(oD.getFullYear()%4==0))||(oD.getFullYear()%400==0))?29:28;
  var t='<div class="'+cM+'"><table class="'+cM+'" cols="7" cellpadding="0" border="'+brdr+'" cellspacing="0"><tr align="center">';
  t+='<td colspan="7" align="center" class="'+cH+'">'+mn[m-1]+' - '+newY+'</td></tr><tr align="center">';
  for(s=0;s<14;s+=2)
    t += '<td class="'+cDW+'">'+"อาจ อ พ พฤศ ส ".substr(s,2)+'</td>';
  t += '</tr><tr align="center">';
  for(i=1;i<=42;i++)
  {
    var x=((i-oD.od>=0)&&(i-oD.od<dim[m-1]))? i-oD.od+1 : '&nbsp;';
    if (x==scanfortoday) //DD added
      x = '<span id="today">'+x+'</span>' //DD added
    t+='<td class="'+cD+'">'+x+'</td>';
    if (((i)%7==0)&&(i<36))
      t+='</tr><tr align="center">';
  }
  return t+='</tr></table></div>';
}
</script>

<script>
var req = null;
function createRequest()
{
  try {
    req = new XMLHttpRequest();
  } catch (microsoft) {
    try {
        req = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (othermicrosoft) {
      try {
          req = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (failed) {
          req = null;
      }
    }
  }
  if (req == null)
    alert("Error: cannot crate request!");
}

function ajSelAmphoe()
{
  var year = document.getElementById("idYear").value;
  if (year < '51')
  {
    document.getElementById('idAmphoe').innerHTML = '';
    return false;
  }
  createRequest();
  var prov = document.getElementById("idProv");
  var id = prov.selectedIndex;
  var pcode = prov.options[id].value;
  var url = "ajSelAmphoe.rb?pcode=" + pcode;
  req.open("GET", url, true);
  req.onreadystatechange = processReq;
  req.send(null);
}

function processReq()
{
  if (req.readyState == 4)
  {
    if (req.status == 200 || req.status == 304)
    {
      var info = req.responseText;
      document.getElementById('idAmphoe').innerHTML = info;
    }
  }
}
</script>
</head>
<body bgcolor='#FDE4C9'>
<div id='page'>
  <div id='res_title'><img src='images/header1.jpg' width=100% height=170 /><hr></div> <!-- eo res_title -->
  <div id='left'>
    <div id='res_member'>
    <center>
      <div id='s1'><b>Member</b></div>
      <div id='s2'>
      <p>
      <form action='res-01.rb' method='POST'>
      <table width='90%' border='0'>
      <tr>
        <th align='right' width=50%>Username:</th>
        <td><input  class='ipc100' type='text' name='user'></td>
      </tr>
      <tr>
        <th align='right'>Password:</th>
        <td><input class='ipc100' type='password' name='pass'></td>
      </tr>
      <tr>
        <th>&nbsp;</th>
        <td><input class='ipc100' type='submit' value='Login'></td>
      </tr>
      </table>
      #{msg1}
      </form>
      </div> <!-- eo s2 div -->
    </center>
    </div> <!-- eo res_member div -->

    <div id='res_admin'>
    <center>
      <div id='s3'><b>Admin</b></div> <!-- eo s3 -->
      <div id='s4'>
      <p>
      <form action='res-01-admin.rb' method='POST'>
      <table width='90%' border='0'>
      <tr>
        <th align='right' width=50%>Username:</th>
        <td><input  class='ipc100' type='text' name='useradmin'></td>
      </tr>
      <tr>
        <th align='right'>Password:</th>
        <td><input class='ipc100' type='password' name='passadmin'></td>
      </tr>
      <tr>
        <th>&nbsp;</th>
        <td><input class='ipc100' type='submit' value='Login'></td>
      </tr>
      </table>
      #{msg2}
      </form>
      </div> <!-- eo s4 div -->
    </center>
    </div> <!-- eo res_admin div -->

    <div id='res_calendar'>
    <center>
    <script type="text/javascript">
      var todaydate=new Date()
      var curmonth=todaydate.getMonth()+1 //get current month (1-12)
      var curyear=todaydate.getFullYear() //get current year
      document.write(buildCal(curmonth ,curyear, "main", "month", "daysofweek", "days", 1));
    </script>
    </center>
    <a href="http://www.easycounter.com/">
    <img src="http://www.easycounter.com/counter.php?titasak" border="0" alt="Free Hit Counter"></a>
    <br><a href="http://www.easycounter.com/">Website Hit Counters</a>

    </div> <!-- eo res_calendar -->
  </div> <!-- eo left div -->

  <div id='right'>
    <div id='res_option'>
      <div id='rr'><i>วัน#{todayThai}</i></div> <!-- eo rr -->
      <b>โปรดเลือกรายงานที่ต้องการ</b>
      <br />
      <form action='res-repGen.rb' method='GET'>
      <ul>
      <li>ปีที่ต้องการ
      <select id='idYear' name='res-year' onchange='ajSelAmphoe()'>
        <option value='00'></option>
        <option value='53'>พ.ศ. 2553</option>
        <option value='52'>พ.ศ. 2552</option>
	<option value='51'>พ.ศ. 2551</option>
        <option value='50'>พ.ศ. 2550</option>
        <option value='49'>พ.ศ. 2549</option>
        <option value='48'>พ.ศ. 2548</option>
        <option value='47'>พ.ศ. 2547</option>
        <option value='46'>พ.ศ. 2546</option>
        <option value='45'>พ.ศ. 2545</option>
      </select>
      </li>
      <li>ประเภทรายงานที่ต้องการ
      <select name='res-form'>
        <option value='0'></option>
        <option value='1'>บุคลากรทางการแพทย์และสาธารณสุข</option>
        <option value='2'>แพทย์ที่ศึกษาต่อเฉพาะทางจำแนกตามวุฒิบัตร</option>
        <option value='3'>ครุภัณฑ์การแพทย์ที่มีราคาแพง</option>
        <option value='4'>การให้บริการของสถานพยาบาล</option>
      </select>
      </li>
      <li>จังหวัดที่ต้องการ
      <select id='idProv' name='res-prov' onchange='ajSelAmphoe()' onclick='ajSelAmphoe()'>
      #{opt_prov}
      </select>
      &nbsp;
      #{opt_amp}
      </li>
      <li>ประเภทเอกสารต้องการ
      <select name='res-type'>
        <option value='1'>HTML</option>
        <option value='2'>CSV / Excel</option>
      </select>
      </li>
      <li>
      <input type='submit' value='ตกลง' />
      <input type='reset' value='Clear' />
      </li>
      </ul>
    </form>
    <hr />
    <ul>
      <li><a href='/res53/hr_report1.rb'>ดูความคืบหน้าข้อมูลการรายงาน</a>
      <li><a href='res-rep2552.html'>สรุปรายงานข้อมูลปี 2552</a>
      <li><a href='res-rep2551.html'>สรุปรายงานข้อมูลปี 2551</a>
      <li><a href='res-rep2550.html'>สรุปรายงานข้อมูลปี 2550</a>
      <li><a href='/res49/hr_report49.rb'>สรุปรายงานข้อมูลปี 2549</a>
      <li><a href='/res48/hr_report48.rb'>สรุปรายงานข้อมูลปี 2548</a>
      <!--
      <li><a href='http://neo.moph.go.th/ftppis/rpt_menu.php'>สรุปรายงานข้อมูลบุคลากรส่วนภูมิภาคและระดับปฐมภูมิ 
          สังกัดสำนักงานปลัดกระทรวงสาธารณสุขปี 2551</a>
      //-->
      <li><a href='/res53/undercon.html'>สรุปรายงานข้อมูลบุคลากรส่วนภูมิภาคและระดับปฐมภูมิ 
          สังกัดสำนักงานปลัดกระทรวงสาธารณสุขปี 2551</a>
      <li><a href='ftp://203.157.240.7/pub/resource52/usermanual.doc'>
          Download  หนังสือคู่มือการใช้งานโปรแกรมระบบรายงานทรัพยากรสาธารณสุข   เริ่มปีงบประมาณ 2551 ถึงปีปัจจุบัน       </a>
      <li><a href='ftp://203.157.240.7/pub/resource53/2009-08-20-NakonNayok'>Download
     PowerPoint บรรยายในการประชุมที่นครนายก</a>
      <li><a href='ftp://203.157.240.7/pub/resource52/2009-12-03-form1-update/Postion-Definition-V-10.pdf'>Download
          หนังสือเวียนที่ นร 1008/ ว 10  เรื่องมาตรฐานกำหนดตำแหน่ง</a>
      <li><a href='ftp://203.157.240.7/pub/resource53/survey53.zip'>Download 
          แบบฟอร์มสำรวจทรัพยากรปี 2553</a>
      <li><a href='http://www.google.com/chrome/eula.html?hl=th&platform=win&brand=CHMB'><img src='images/chrome-download.png'></a>
     </div> <!-- eo options -->
  </div> <!-- eo right div -->
</div> <!-- eo page div -->
</body>
</html>
EOF
