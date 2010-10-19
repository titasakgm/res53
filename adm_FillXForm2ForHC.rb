#!/usr/bin/ruby

# Fill X in reportmon for o_office = สอ

require 'postgres'

def fillXform2(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET form2='X' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

# get hcode with o_office = สอ
con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT o_code FROM office53 "
sql += "WHERE o_office LIKE 'สอ%' "
res = con.exec(sql)
con.close

n = 0
res.each do |rec|
  n += 1
  hcode = rec[0]
  fillXform2(hcode)
  print "\r#{n}"
end

