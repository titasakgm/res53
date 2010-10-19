#!/usr/bin/ruby

require 'cgi'
require 'res_util.rb'

c = CGI::new
#Admin's sessid
admin = c['admin']
sessid = c['sessid']
flag = checkSession(admin,sessid)
if !flag
  errMsg("Unauthorized access!!")
  exit
end

user = c['user'].to_s
pass = c['pass'].to_s
off = c['off'].to_s
pcode = c['pcode'].to_s
fn = c['fn'].to_s
ln = c['ln'].to_s
tel = c['tel'].to_s
eml = c['eml'].to_s

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
# update member table
sql = "UPDATE member SET password='#{pass}',office='#{off}',provid='#{pcode}',"
sql += "fname='#{fn}',lname='#{ln}',telno='#{tel}',email='#{eml}' "
sql += "WHERE username='#{user}' "
res = con.exec(sql)

# update report1 table
sql = "UPDATE report1 SET reporter='#{fn} #{ln}',tel='#{tel}' "
sql += "WHERE provid='#{user}' "
res = con.exec(sql)

#errMsg("ajUpdateMem: #{sql}")
con.close

print <<EOF
Content-type: text/html

<font color='red'>1 record updated!</font>
EOF


