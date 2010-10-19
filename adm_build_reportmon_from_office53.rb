#!/usr/bin/ruby

require 'postgres'

def insertReportmon(hcode,pcode,acode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "INSERT INTO reportmon (hcode,pcode,acode) "
  sql += "VALUES ('#{hcode}','#{pcode}','#{acode}') "
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
# Clear reportmon table
sql = "DELETE FROM reportmon"
res = con.exec(sql)

# Get info --> 13159 records
sql = "SELECT o_code,o_provid,o_ampid "
sql += "FROM office53 "
sql += "ORDER BY o_provid,o_ampid,o_code"
res = con.exec(sql)
con.close

res.each do |rec|
  hc = rec[0]
  pc = rec[1]
  ac = rec[2]
  insertReportmon(hc,pc,ac)
end

