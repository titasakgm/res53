#!/usr/bin/ruby

require 'cgi'
require 'res_util.rb'

c = CGI::new
user = c['user'].to_s.split('').join('')
sessid = c['sessid']
msg = c['msg']

provname = ''
provAdminOption = ''
ftpFlag = ''
ftpImg = 'b5'

errmsg = ''
if (msg == 'NOTOWNER')
  errmsg = '<font color="red">ขออภัย ท่านไม่มีสิทธิแก้ไขหน่วยงานที่ระบุ</font>'
end

if user.length == 4 # Amphoe user
  pn = getProvName(user[0..1]) 
  provname = "จังหวัด#{pn}"
  ftpFlag = 'DISABLED'
  ftpImg = 'b5.1'
end

flag = checkSession(user,sessid)
if !flag
  print "Location:/res53\n\n"
  exit
end

progress = getProgress(user)

userInfo = getUserInfo(user)
u = userInfo.split('|')

today = todayThai()

work = getWorkSummary(user)
#log("work: #{work}")
w = work.to_s.split('|')

area = "จังหวัด"
area = "อำเภอ" if user.length == 4

offByProv = Array.new
offByAmp = Array.new
if (user.length == 2)
  offByProv = getOffByProv(user)
  offOK = getOffOK(offByProv)
  offNOK = getOffNOK(offByProv)
elsif (user.length == 4)
  offByAmp = getOffByAmp(user)
  offOK = getOffOK(offByAmp)
  offNOK = getOffNOK(offByAmp)
end

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<head>
<title>บันทึกข้อมูลทรัพยากรสาธารณสุข #{area}#{w[0]}</title>
<style>
body {
  text:green;
}
#page {
  width:100%;
}
#left {
  position:relative;
  float:left;
  width: 25%;
  text-align: center;
}
#right {
  position: relative;
  float: left;
  width: 70%;
  margin-left: 1%;
  /* background-color: #EBE9ED; */
}
#mem-title {
  position: relative;
  float:left;
  width:100%;
  text-align:center;
}
#mem-menu {
  position:relative;
  float:left;
  width:210px;
  text-align:center;
  padding-top:10px;
}
#mem-work {
  position:relative;
  width: 100%;
  margin-left:20px;
  float:left;
}
#rr {
  position: relative;
  float: right;
  margin-top: 0;
  margin-right: 5px;
  text-align: right;
}
.ipx100 {
  width:100px;
}
.imgbtn {
  width: 250px;
}
.ipc100 {
  width:100%;
}
</style>
<script type='text/javascript'>
function submitForm()
{
  var hcode = '';
  var ho1 = document.getElementById('hcode');
  var hc1 = ho1.value;
  var ho2 = document.getElementById("hcodenok");
  var id = ho2.selectedIndex;
  var hc2 = ho2.options[id].value;
  var ho3 = document.getElementById("hcodeok");
  var id = ho3.selectedIndex;
  var hc3 = ho3.options[id].value;

  if (hc1.length > 0)
  {
    hcode = hc1;
    ho2.selectedIndex = 0;
    ho3.selectedIndex = 0;
  }
  else if (hc2.length > 0)
  {
    hcode = hc2;
    ho3.selectedindex = 0;
  }
  else if (hc3.length > 0)
  {
    hcode = hc3;
    ho2.selectedIndex = 0;
  }
  document.getElementById('offReport').value = hcode;
  document.hrFrm.submit();
}

function checkEnter(e)
{ //e is event object passed from function invocation
  var characterCode; //literal character code will be stored in this variable

  if(e && e.which)
  { //if which property of event object is supported (NN4)
    e = e;
    characterCode = e.which; //character code is contained in NN4's which property
  } else {
    e = event;
    characterCode = e.keyCode; //character code is contained in IE's keyCode property
  }

  if(characterCode == 13)
  { //if generated character code is equal to ascii 13 (if enter key)
    submitForm();
    return false;
  } else {
    return true;
  }
}
</script>
</head>
<body bgcolor='#EAF4FD'>
<div id='page'>
  <div id='mem-title'><img src='images/header2.jpg' width=100% height=170 /><hr></div> <!-- eo mem-title -->
  <div id='left'>
  <div id='mem-menu'>
    <b>MEMBER</b>
    <p>
    <table border='0' width='100%'>
    <tr>
      <th><input class='imgbtn' type='image' src='images/b1.png' 
          onclick="document.location.href='res-04.rb?pcode=#{user}'" /></th>
    </tr>
    <tr>
      <th><input class='imgbtn' type='image' src='images/b2.png'
          onclick="document.location.href='ftp://203.157.240.7/pub/resource53/structure53.zip'" /></th>
    </tr>
    <tr>
      <th><input class='imgbtn' type='image' src='images/b3.png'
          onclick="document.location.href='ftp://203.157.240.7/pub/resource53/manual53.zip'" /></th>
    </tr>
    <tr>
      <th><input class='imgbtn' type='image' src='images/b4.png'
          onclick="document.location.href='ftp://203.157.240.7/pub/backup/'" /></th> 
    </tr>
    <tr>
      <th><input class='imgbtn' type='image' src="images/#{ftpImg}.png"
          onclick="document.location.href='ftp://res#{user}@hrm.moph.go.th'" #{ftpFlag} /></th>
    </tr>
    <tr>
      <th><input class='imgbtn' type='image' src='images/b6.png'
          onclick="window.open('adm_userinfo.rb?user=#{user}',null,'left=250,top=250,height=350,width=400,status=yes,toolbar=no,menubar=no,location=no')" />
      </th>
    </tr>
    <tr>
      <th><input class='imgbtn' type='image' src='images/b7.png'
         onclick="document.location.href='/res53'" /></th>
    </tr>
    </table>
  </div> <!-- eo mem-menu -->
  </div> <!-- eo left -->

  <div id='right'>
  <div id='mem-work'>
    <div id='rr'><i>วัน#{today}</i></div> <!-- eo rr -->
    <b>ยินดีต้อนรับ คุณ#{u[0]} #{u[1]}</b><br />
    <tt>โทรฯ: #{u[2]}</tt><br />
    <tt>Email: #{u[3]}</tt>
    <p>
    <b>สรุปความคืบหน้า</b> [#{progress}]<br>
    #{area}#{w[0]} #{provname} มีหน่วยงานรวม <b>#{w[1]}</b> 
    บันทึกครบแล้ว <b>#{w[2].to_i + w[3].to_i}</b> 
    คงเหลือ <font color='red'><b>#{w[4]}</b></font>
    <hr />
    <form id='hrFrm' name='hrFrm' action='hr_formAll.rb' method='GET'>
    <fieldset>
      <legend style='background-color:#FEBF53'>โปรดเลือกหน่วยงาน:</legend>
      <input type='hidden' name='user' value='#{user}'>
      <input type='hidden' name='sessid' value='#{sessid}'>
      <input type='hidden' name='year' value='2553'>
      <input id='offReport' type='hidden' name='offReport'>
      จากรหัส<br />
      <input id='hcode' class='ipx100' type='text' name='hcode'
        onKeyPress='checkEnter(event)'>&nbsp;#{errmsg} หรือ
      <p>
      บันทึกหน่วยงานที่ยังไม่ครบถ้วน<br />
      <select id='hcodenok' name='hcodeNOK'>
        <option></option>
        #{offNOK}
      </select>&nbsp;หรือ
      <p>
      แก้ไขหน่วยงานที่บันทึกครบถ้วนแล้ว<br />
      <select id='hcodeok' name='hcodeOK'>
        <option></option>
        #{offOK}
      </select>
      <p>
      <input type='button' value='ตกลง' onclick='submitForm()' />
      <input type='reset' value='Clear' />
    </fieldset>
    </form>
  </div> <!-- eo mem-work -->
  </div> <!-- eo right -->
</div> <!-- eo page -->
</body>
</html>
EOF
