#!/usr/bin/ruby

require 'postgres'

def insert(pcode,pname)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "INSERT INTO report2 (provid,ampid,province,amphoe,reporter) "
  sql += "VALUES ('#{pcode}','00','#{pname}','เมือง#{pname}','สสจ.#{pname}') "
  res = con.exec(sql)
  puts sql
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT * FROM ssj"
res = con.exec(sql)
con.close

res.each do |rec|
  pcode = rec[0]
  pname = rec[1]
  insert(pcode,pname)
end

