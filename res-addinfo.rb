#!/usr/bin/ruby

require 'postgres'

def insert(sql)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  res = con.exec(sql)
  con.close
end

src = open('res-info.csv').readlines
src.each do |l|
  f = l.chomp.split(',')
  next if f[0] !~ /\d/
  pn = f[1]
  pak = f[2]
  khet = f[3]
  pc = f[4]
  y50 = f[5]
  y49 = f[6]
  y48 = f[7]
  y47 = f[8]
  sql = "INSERT INTO resinfo (r_pak,r_khet,r_prov,r_pname,r_2547,r_2548,"
  sql += "r_2549,r_2550) VALUES ('#{pak}','#{khet}','#{pc}','#{pn}',"
  sql += "'#{y47}','#{y48}','#{y49}','#{y50}')"
  insert(sql)
end

