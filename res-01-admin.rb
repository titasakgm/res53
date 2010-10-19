#!/usr/bin/ruby

require 'cgi'
require '/res53/res_util.rb'

c = CGI::new
user = c['useradmin']
pass = c['passadmin']
prov = c['res-prov']

opt_prov = getProvOption(prov)
opt_amp = getAmpOption(prov)

msg1 = nil
msg2 = nil

if (user.to_s.length > 0)
  sessid = authenUser(user, pass)
  if (sessid != 'FAILED')
    print "Location:res-03.rb?user=#{user}&sessid=#{sessid}\n\n"
  else
    msg2 = "Login failed!.."
  end
end

print <<EOF
Content-type: text/html

<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
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
  width:100%;
}
#left {
  position:relative;
  float:left;
  width: 200px;
  text-align: center;
}
#right {
  position:relative;
  float:left;
  padding-left: 10px;
}
#res_title {
  position:relative;
  float:left;
  width:100%;
  text-align:center;
}
#res_member {
  position:relative;
  float:left;
  width:100%;
  text-align:center;
}
#res_member td,th {
  font-size:14px;
  font-weight:normal;
}
#res_admin {
  position:relative;
  float:left;
  width:100%;
  padding-top: 100px;
  text-align:center;
}
#res_admin td,th {
  font-size:14px;
  font-weight:normal;
}
#res_option {
  position:relative;
  float:left;
  margin-left:20px;
}
.ipx60 {
  width:60px;
}
.ipc100 {
  width:100%;
}
</style>
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
  if (year != '51')
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
<body>
<div id='page'>

<div id='res_title'><img src='res51-01.png' /><img src='res51-02.png' /><hr></div>
<div id='left'>
<div id='res_member'>
<!-- <img src='member.png' /> -->
<center>
<b>Member</b>
<p>
<form action='res-01.rb' method='POST'>
<table width='90%' border='1'>
<tr>
  <th align='right'>Username:</th>
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
</center>
</div> <!-- eo res_staff div -->

<div id='res_admin'>
<center>
<b>Admin</b>
<p>
<form action='res-01-admin.rb' method='POST'>
<table width='90%' border='1'>
<tr>
  <th align='right'>Username:</th>
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
</center>
</div> <!-- eo res_admin div -->
</div> <!-- eo left div -->

<div id='right'>
<div id='res_option'>
<b>โปรดเลือกรายงานที่ต้องการ</b><br />
<i>วัน#{todayThai}</i>
<form action='res-repGen.rb' method='POST'>
<ul>
<li>ปีที่ต้องการ
<select id='idYear' name='res-year' onchange='ajSelAmphoe()'>
  <option value='00'></option>
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
<li><a href='res-rep2550.html'>สรุปตารางรายงานปีงบประมาณ 2550</a>
<li><a href='hr_report1.rb'>ดูความคืบหน้าข้อมูลการรายงาน</a>
<li><a href='/resource49/hr_report49.rb'>สรุปรายงานข้อมูลปี 2549</a>
<li><a href='/resource48/hr_report48.rb'>สรุปรายงานข้อมูลปี 2548</a>
<li><a href=''>สรุปรายงานข้อมูลบุคลากรส่วนภูมิภาคระดับปฐมภูมิ 
สังกัดสำนักงานปลัดกระทรวงสาธารณสุขปี 2551</a>
<li><a href='ftp://203.157.240.9/pub/resource53/survey52.zip'>Download 
แบบฟอร์มสำรวจทรัพยากรปี 2552</a>
</ul>
</div>
</div> <!-- eo right div -->
</div> <!-- eo page div -->
</body>
</html>
EOF
