#!/usr/bin/ruby

require 'postgres'

def insertTotgmp(pcode,acode,otype,total)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "INSERT INTO totgmp "
  sql += "VALUES ('#{pcode}','#{acode}','#{otype}',#{total}) "
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
# Clear table totgmp
sql = "DELETE FROM totgmp"
res = con.exec(sql)

# Get info --> 1360 records
sql = "SELECT o_provid,o_ampid2,o_type,count(*) "
sql += "FROM office53 "
sql += "GROUP BY o_provid,o_ampid2,o_type "
sql += "ORDER BY o_provid,o_ampid2,o_type "
res = con.exec(sql)
con.close

res.each do |rec|
  pcode = rec[0]
  acode = rec[1]
  otype = rec[2]
  total = rec[3]
  insertTotgmp(pcode,acode,otype,total)
end

