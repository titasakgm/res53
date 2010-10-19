#!/usr/bin/ruby

# Fill X in reportmon for o_type = M

require 'postgres'

def fillXform1(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET form1='X' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

# get hcode with o_type = M
con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT o_code FROM office53 "
sql += "WHERE o_type='M' "
res = con.exec(sql)
con.close

n = 0
res.each do |rec|
  n += 1
  hcode = rec[0]
  fillXform1(hcode)
  print "\r#{n}"
end

