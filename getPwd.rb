#!/usr/bin/ruby

require 'postgres'

def addPwd(u,p)
  sec = open("/tmp/passwd","a")
  sec.write("#{u}|#{p}\n")
  sec.close
end

con =PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT username,password FROM member "
sql += "WHERE length(username) = 2 "
res = con.exec(sql)
con.close

res.each do |rec|
  u = rec[0]
  p = rec[1]
  addPwd(u,p)
end

