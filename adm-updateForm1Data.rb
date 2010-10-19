#!/usr/bin/ruby

require 'postgres'

def check(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT f1hcode FROM form1 WHERE f1hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
end

def update(hcode,f001,n1,f002,n2,f003,n3,f004,n4)
  chk = check(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  if (chk > 0)
    sql = "UPDATE form1 SET #{f001}=#{n1},#{f002}=#{n2},"
    sql += "#{f003}=#{n3},#{f004}=#{n4} "
    sql += "WHERE f1hcode='#{hcode}' "
  else
    sql = "INSERT INTO form1 (f1hcode,#{f001},#{f002},#{f003},#{f004}) "
    sql += "VALUES ('#{hcode}',#{n1},#{n2},#{n3},#{n4}) "
  end
  res = con.exec(sql)
  con.close
  puts sql
end

data = open("/tmp/form1data.txt").readlines
data.each do |l|
  f = l.chomp.split('|')
  hcode = f[0]
  f1n1 = f[1].split('=')
  f2n2 = f[2].split('=')
  f3n3 = f[3].split('=')
  f4n4 = f[4].split('=')
  f001 = f1n1[0]
  n1 = f1n1[1]
  f002 = f2n2[0]
  n2 = f2n2[1]
  f003 = f3n3[0]
  n3 = f3n3[1]
  f004 = f4n4[0]
  n4 = f4n4[1]
  update(hcode,f001,n1,f002,n2,f003,n3,f004,n4)
end


