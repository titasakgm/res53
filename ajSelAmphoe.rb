#!/usr/bin/ruby

require 'postgres'
require 'cgi'

c = CGI::new
pcode = c['pcode']

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT DISTINCT provid, ampid, amphoe "
sql += "FROM report2 "
sql += "WHERE provid='#{pcode}' AND ampid<>'00' "
sql += "ORDER BY ampid"
res = con.exec(sql)
con.close

sel = nil
if (pcode != '10')
  sel = "อำเภอที่ต้องการ (มีตั้งแต่ปี 2551) <select name='res-amp'>"
  res.each do |rec|
    provid = rec[0]
    ampid = rec[1]
    amphoe = rec[2]
    sel += "<option value='#{provid}#{ampid}'>อำเภอ#{amphoe}</option> "
  end
  sel += "</select>"
end

print <<EOF
Content-type: text/html

#{sel}
EOF
