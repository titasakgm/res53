#!/usr/bin/ruby

require 'postgres'

def addReport2(pc,ac,prov,amp)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "INSERT INTO report2 (provid,ampid,province,amphoe) "
  sql += "VALUES ('#{pc}','#{ac}','#{prov}','#{amp}') "
  puts sql
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT DISTINCT o_provid,o_ampid2,o_province,o_amphoe "
sql += "FROM office53 "
sql += "WHERE o_amphoe NOT LIKE 'เขต%' "
sql += "ORDER BY o_provid,o_ampid2 "
res = con.exec(sql)
con.close

res.each do |rec|
  pc = rec[0]
  ac = rec[1]
  prov = rec[2]
  amp = rec[3]
  addReport2(pc,ac,prov,amp)
end
  
