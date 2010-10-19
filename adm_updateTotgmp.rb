#!/usr/bin/ruby

require 'postgres'

def updateTotgmp(pcode,acode,otype,total)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "UPDATE totgmp SET total=#{total} "
  sql += "WHERE pcode='#{pcode}' AND acode='#{acode}' AND otype='#{otype}' "
  res = con.exec(sql)
  con.close
end

pcode = ARGV[0]

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT o_provid,o_ampid2,o_type,count(*) "
sql += "FROM office53 "
if (pcode =~ /\d\d/)
  sql += "WHERE o_provid='#{pcode}' "
end
sql += "GROUP BY o_provid,o_ampid2,o_type "
sql += "ORDER BY o_provid,o_ampid2,o_type "
res = con.exec(sql)
con.close

res.each do |rec|
  pcode = rec[0]
  acode = rec[1]
  otype = rec[2]
  total = rec[3]
  updateTotgmp(pcode,acode,otype,total)
end

