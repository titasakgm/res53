#!/usr/bin/ruby

require 'cgi'
require 'postgres'

c = CGI::new
keyoff = c['keyoff']

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT o_code,o_name,o_provid,o_province,o_ampid,o_amphoe,"
sql += "o_office,o_type,o_minisid,o_ampid2 "
sql += "FROM office53 WHERE o_code='#{keyoff}' "
res = con.exec(sql)
con.close
found = res.num_tuples
offInfo = (found == 1) ? res[0].join('|') : 'NA|NA|NA|NA|NA|NA|NA|NA|NA|NA'

print <<EOF
Content-type: text/html

#{offInfo}
EOF

