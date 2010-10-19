#!/usr/bin/ruby

require 'postgres'

def insert(user,off)
  provid = user[0..1]
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "INSERT INTO member (username,password,office,provid) "
  sql += "VALUES ('#{user}','#{user}','#{off}','#{provid}') "
  res = con.exec(sql)
  con.close
end

users = open("dho.txt").readlines
users.each do |l|
  f = l.chomp.split(/\t/)
  off = f[0].to_s.strip
  user = f[1].to_s.strip
  insert(user,off)
end

