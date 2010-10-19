#!/usr/bin/ruby

require 'postgres'

def updateReport1(pcode,total)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "UPDATE report1 SET total=#{total},govt=0,private=0,balance=#{total} "
  sql += "WHERE provid='#{pcode}' "
  puts sql
  res = con.exec(sql)
  # Then update total and balance
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "select pcode,sum(total) "
sql += "FROM totgmp "
sql += "GROUP BY pcode "
sql += "ORDER BY pcode "
puts sql
res = con.exec(sql)
con.close

oldpc = nil
totg = totp = 0

res.each do |rec|
  pcode = rec[0]
  total = rec[1]
  updateReport1(pcode, total)
end
