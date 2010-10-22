#!/usr/bin/ruby

require 'cgi'
require 'res_util.rb'

c = CGI::new
user = c['user']
sessid = c['sessid']

userFlag = ''
user_menu_7 = ''
admin_logo = ''
adminFlag = ''
uinfo = Array.new

if (user != 'admin' && user.length != 2)
  errMsg("Unauthorized Access")
end

if (user.length == 2)
  userFlag = 'DISABLED'
  user_menu_7 = 'bbb7.png'
  uinfo = getUserInfo(user).split('|')
  admin_logo = 'adminprov.jpg'
else
  adminFlag = 'DISABLED'
  user_menu_7 = 'bb7.png'
  admin_logo = 'admin.jpg'
end

today = todayThai()

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8">
<head>
<title>Admin Zone</title>
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
  margin-top: 2px;
  width: 25%;
  text-align: center;
}
#right {
  position: relative;
  float: left;
  margin-top: 2px;
  width: 70%;
  margin-left: 1%;
}
#adm-title {
  position: relative;
  float:left;
  width:100%;
  text-align:center;
}
#adm-menu {
  position:relative;
  float:left;
  width:100%;
  text-align:center;
  padding-top:10px;
}
#adm-work {
  position:relative;
  margin-left:10px;
  float:left;
  width:100%;
}
#rr {
  position: absolute;
  top: 0;
  right: 0;
}
.ipx100 {
  width:100px;
}
.ipx250 {
  width: 250px;
}
.ipc100 {
  width:100%;
}
#d_repstatus, #d_addmember, #d_editmember, #d_editoffice {
  display:none;
}
#d_addmember, #d_editmember, #d_editoffice {
  width: 100%;
}
</style>
<script src="res_script.js"></script>
<script type='text/javascript'>
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
    ajSearchMem();
    return false;
  } else {
    return true;
  }
}
</script>
</head>
<body bgcolor='#FFCCCC'>
<div id='page'>
  <div id='adm-title'><img src='images/#{admin_logo}' width=100% height=170 /><hr></div>
  <div id='left'>
    <center>
    <div id='adm-menu'>
      <b>ADMIN</b>
      <p>
      <table border='0' width='100%'>
      <tr>
        <th><input class='ipx250' type='image' src='images/bb1.png'
             onclick="document.location.href='adm-show-progress.rb?user=#{user}'" />
        </th>
      </tr>
      <tr>
        <th><input class='ipx250' type='image' src='images/bb2.png'
            style='background-color:pink;'
            onclick="document.location.href='res-05.rb?pcode=#{user}'" #{adminFlag}/>
        </th>
      </tr>
      <tr>
        <th><input class='ipx250' type='image' src='images/bb3.png'
            onclick="document.location.href='adm-show-failreport.rb?user=#{user}'" />
        </th>
      </tr>
      <tr>
        <th><input class='ipx250' type='image' src='images/bb4.png'
             onclick="document.location.href='ftp://res#{user}@203.157.240.7/53/'"/>
        </th>
      </tr>
      <tr>
        <th><input class='ipx250' type='image' src='images/bb5.png'
             onclick="addMember()" DISABLED/>
        </th>
      </tr>
      <tr>
        <th><input class='ipx250' type='image' src='images/bb6.png'
            onclick="editMember()" />
        </th>
      </tr>
      <tr>
        <th><input class='ipx250' type='image' src='images/#{user_menu_7}'
            onclick="editOffice()" #{userFlag}/>
        </th>
      </tr>
      <tr>
        <th><input class='ipx250' type='image' src='images/bb8.png'
            onclick="document.location.href='/res53'" />
        </th>
      </tr>
      </table>
    </div> <!-- eo adm-menu -->
    </center>
  </div> <!-- eo left -->

  <div id='right'>
    <div id='adm-work'>
    <b>ยินดีต้อนรับ คุณ#{uinfo[0]} #{uinfo[1]}</b><span id='rr'><i>วัน#{today} </i></span>
    <br />
    <tt>โทรฯ: #{uinfo[2]}</tt><br />
    <tt>Email: #{uinfo[3]}</tt>
      <div id='d_repstatus'></div>
      <div id='d_addmember'>
      <h4>Add New Member</h4>
      <hr>
      <form action="res-adm-addmember.rb" method="GET">
      <table border="1" width="60%">
      <tr>
        <th align="right">Username:</th>
        <td><input class='ipc100' type="text" name="username" /></td>
      </tr>
      <tr>
        <th align="right">Password:</th>
        <td><input class='ipc100' type="text" name="password" /></td>
      </tr>
      <tr>
        <th align="right">Office:</th>
        <td><input class='ipc100' type="text" name="office" /></td>
      </tr>
      <tr>
        <th align="right">Province Code:</th>
        <td><input class='ipc100' type="text" name="provid" /></td>
      </tr>
      <tr>
        <th align="right">First Name:</th>
        <td><input class='ipc100' type="text" name="fname" /></td>
      </tr>
      <tr>
        <th align="right">Last Name:</th>
        <td><input class='ipc100' type="text" name="lname" /></td>
      </tr>
      <tr>
        <th align="right">Telephone:</th>
        <td><input class='ipc100' type="text" name="telno" /></td>
      </tr>
      <tr>
        <th align="right">Email:</th>
        <td><input class='ipc100' type="text" name="email" /></td>
      </tr>
      <tr>
        <th align="right">&nbsp;</th>
        <td><input type="submit" value="Add"></td>
      </tr>
      </table>
      </form>
    </div> <!-- eo d_addmember -->

    <div id='d_editmember'>
      <h4>Edit Member</h4>
      Search: <input id="keymem" type="text" name="keymem" onKeyPress='checkEnter(event)'/>
      <input type='hidden' id='userid' name='userid' value='#{user}' />
      <input type='hidden' id='sessid' name='sessid' value='#{sessid}' />
      <input type='button' value=' OK ' onclick='ajSearchMem()' />
        &nbsp;(กรอกเฉพาะหมายเลข Username เท่านั้น)
    </div> <!-- eo d_editmember -->

    <div id='d_editoffice'>
      <h4>Edit Office</h4>
      Search: <input id="keyoff" type="text" name="keyoff" />
      <input type='hidden' id='userid' name='userid' value='#{user}' />
      <input type='hidden' id='sessid' name='sessid' value='#{sessid}' />
      <input type='button' value=' OK ' onclick='ajSearchOff()' />
    </div> <!-- eo d_editoffice -->
    </div> <!-- eo adm_work -->
  </div> <!-- eo right -->
</div> <!-- eof page -->
</body>
</html>
EOF
