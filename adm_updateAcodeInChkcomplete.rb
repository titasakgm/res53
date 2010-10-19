#!/usr/bin/ruby

require 'postgres'

def updateChkcomplete(hcode,acode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE chkcomplete SET acode='#{acode}' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT o_code,o_ampid2 "
sql += "FROM office53 "
sql += "ORDER BY o_code "
res = con.exec(sql)
con.close

res.each do |rec|
  hcode = rec[0]
  acode = rec[1]
  updateChkcomplete(hcode,acode)
end


