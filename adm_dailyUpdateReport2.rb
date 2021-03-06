#!/usr/bin/ruby

require 'postgres'

def updateGovtReport2(pcode, acode, complete)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE report2 SET govt=#{complete},balance=total-govt-private "
  sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  res = con.exec(sql)
  con.close
end

def updatePrivateReport2(pcode, acode, complete)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE report2 SET private=#{complete},balance=total-govt-private "
  sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  res = con.exec(sql)
  con.close
end

# for Govt
con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT pcode,acode,count(*) "
sql += "FROM reportmon "
sql += "WHERE form1='X' AND form2='X' AND form3='X' AND form4='X' "
sql += "GROUP BY pcode,acode "
sql += "ORDER BY pcode,acode"
res = con.exec(sql)
con.close

res.each do |rec|
  pc = rec[0]
  ac = rec[1]
  complete = rec[2].to_i
  updateGovtReport2(pc,ac,complete)
end

# for Public
con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT pcode,acode,count(*) "
sql += "FROM reportmon "
sql += "WHERE form5='X' AND form6='X' AND form7='X' AND form8='X' "
sql += "GROUP BY pcode,acode "
sql += "ORDER BY pcode,acode "
res = con.exec(sql)
con.close
res.each do |rec|
  pc = rec[0]
  ac = rec[1]
  complete = rec[2].to_i
  updatePrivateReport2(pc,ac,complete)
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "UPDATE report2 SET balance=total-govt-private"
res = con.exec(sql)
con.close

