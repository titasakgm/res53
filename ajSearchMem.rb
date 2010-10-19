#!/usr/bin/ruby

require 'cgi'
require 'postgres'

c = CGI::new
keymem = c['keymem']

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT * FROM member WHERE username='#{keymem}' "
res = con.exec(sql)
con.close
userInfo = res[0].join('|')

print <<EOF
Content-type: text/html

#{userInfo}
EOF
