#!/usr/bin/ruby

require 'postgres'
require 'cgi'
require 'res_util.rb'

c = CGI::new
user = c['user']
oldpass = c['opass'].to_s.split('').join('')
newpass = c['npass'].to_s.split('').join('')
fname = c['fname'].to_s.split('').join('')
lname = c['lname'].to_s.split('').join('')
telno = c['telno'].to_s.split('').join('')
email = c['email'].to_s.split('').join('')
status = "Please enter Old Password!!"

if (oldpass.length > 0)
  if(oldpass != user && user.length == 4) # change user info 2nd time
    errMsg("ขออภัย โปรดติดต่อ Admin จังหวัดเพื่อแก้ไขข้อมูล")
  end
  if (newpass.length > 0)
    status = updatePass(user,newpass)
  end
  if (fname.length > 0)
    status = updateFname(user,fname)
  end
  if (lname.length > 0)
    status = updateLname(user,lname)
  end
  if (telno.length > 0)
    status = updateTelno(user,telno)
  end
  if (email.length > 0)
    status = updateEmail(user,email)
  end
end

info = getUserInfo(user).to_s.split('|')

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<body bgcolor='#AAEDFE'>
<center>
<h4>Change User Info</h4>
<form action="adm_userinfo.rb" method="GET">
<input type="hidden" name="user" value="#{user}" />
<table border="1" width="100%">
<tr>
  <th align="right" width="50%">Username:</th>
  <td>#{user}</td>
</tr>
<tr>
  <th align="right">Old Password:</th>
  <td><input type="password" name="opass" style="width:100%; background-color:yellow;" /></td>
</tr>
<tr>
  <th align="right">New Password:</th>
  <td><input type="password" name="npass" style="width:100%" /></td>
</tr>
<tr>
  <th align="right">First Name:</th>
  <td><input type="text" name="fname" style="width:100%" value="#{info[0]}"/></td>
</tr>
<tr>
  <th align="right">Last Name:</th>
  <td><input type="text" name="lname" style="width:100%" value="#{info[1]}"/></td>
</tr>
<tr>
  <th align="right">Telephone:</th>
  <td><input type="text" name="telno" style="width:100%" value="#{info[2]}"/></td>
</tr>
<tr>
  <th align="right">Email:</th>
  <td><input type="text" name="email" style="width:100%" value="#{info[3]}"/></td>
</tr>
<tr>
  <th align="right">&nbsp;</th>
  <td><input type="submit" value="Update"></td>
</tr>
</table>
</form>
<font color="green"><b><i>#{status}</i></b></font>
</center>
</body>
</html>
EOF
