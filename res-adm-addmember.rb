#!/usr/bin/ruby

require 'cgi'
require 'postgres'

c = CGI::new
user = c['username']
pass = c['password']
off = c['office']
prov = c['provid']
fn = c['fname']
ln = c['lname']
tel = c['telno']
email = c['email']


err = 0

errMsg = "Incomplete form:<br>"
if (user.to_s.strip.length == 0)
  errMsg += "Username must not be blank<br>"
  err += 1
end
if (pass.to_s.strip.length == 0)
  errMsg += "Password must not be blank<br>"
  err += 1
end
if (off.to_s.strip.length == 0)
  errMsg += "Office must not be blank<br>"
  err += 1
end
if (prov.to_s.strip.length == 0)
  errMsg += "Provice Code must not be blank<br>"
  err += 1
end
if (fn.to_s.strip.length == 0)
  errMsg += "First Name must not be blank<br>"
  err += 1
end
if (ln.to_s.strip.length == 0)
  errMsg += "Last Name must not be blank<br>"
  err += 1
end
if (tel.to_s.strip.length == 0)
  errMsg += "Telephone must not be blank<br>"
  err += 1
end
if (email.to_s.strip.length == 0)
  errMsg += "Email must not be blank<br>"
  err += 1
end

if (err == 0) # completed form insert a new entry
  flag = checkDup(user)
  if (flag) # duplicate user
    errMsg = "Sorry duplicate user, select Edit Member"
  else
    con = PGconn.connect("localhost",5432,nil,nil,"resource53")
    sql = "INSERT INTO member VALUES ('#{user}','#{pass}','#{off}','#{fn}','#{ln}',"
    sql += "'#{tel}','#{email}' "
    res = con.exec(sql)
    con.close
  end
end

print <<EOF
Content-type: text/html

<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<head>
<title>Admin: Add a new member</title>
<style>
</style>
<script>
</script>
</head>
<body>
<h4>Add New Member</h4>
<form action="res-adm-addmember.rb" method="GET">
<table border="1" width="50%">
<tr>
  <th align="right">Username:</th>
  <td><input type="text" name="username" value="#{user}"></td>
</tr>
<tr>
  <th align="right">Password:</th>
  <td><input type="text" name="password" value="#{pass}"></td>
</tr>
<tr>
  <th align="right">Office:</th>
  <td><input type="text" name="office" value="#{off}"></td>
</tr>
<tr>
  <th align="right">Province Code:</th>
  <td><input type="text" name="provid" value="#{prov}"></td>
</tr>
<tr>
  <th align="right">First Name:</th>
  <td><input type="text" name="fname" value="#{fn}"></td>
</tr>
<tr>
  <th align="right">Last Name:</th>
  <td><input type="text" name="lname" value="#{ln}"></td>
</tr>
<tr>
  <th align="right">Telephone:</th>
  <td><input type="text" name="telno" value="#{tel}"></td>
</tr>
<tr>
  <th align="right">Email:</th>
  <td><input type="text" name="email" value="#{email}"></td>
</tr>
<tr>
  <th align="right">&nbsp;</th>
  <td><input type="submit" value="Add"></td>
</tr>
</table>
</form>
</body>
</html>
EOF

