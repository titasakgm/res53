#!/usr/bin/ruby

require 'postgres'

def updateChkComplete(hcode,hname)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE chkcomplete SET hname='#{hname}' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT o_code,o_name FROM office53 "
sql += "ORDER BY o_code"
res = con.exec(sql)
con.close

res.each do |rec|
  hcode = rec[0]
  hname = rec[1]
  updateChkComplete(hcode,hname)
end

