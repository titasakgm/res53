#!/usr/bin/ruby

require 'postgres'
require '/res53/res_util.rb'

def update(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE chkcomplete SET stat='x' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

# for Govt
con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT hcode "
sql += "FROM reportmon "
sql += "WHERE form1='X' AND form2='X' AND form3='X' AND form4='X' "
res = con.exec(sql)
con.close

res.each do |rec|
  hcode = rec[0]
  update(hcode)
end

# for Public
con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT hcode "
sql += "FROM reportmon "
sql += "WHERE form5='X' AND form6='X' AND form7='X' AND form8='X' "
res = con.exec(sql)
con.close

res.each do |rec|
  hcode = rec[0]
  update(hcode)
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "UPDATE report2 SET balance=total-govt-private"
res = con.exec(sql)
con.close
