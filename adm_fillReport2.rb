#!/usr/bin/ruby

require 'postgres'

def insert(provid,ampid,province,amphoe,reporter)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "INSERT INTO report2 (provid,ampid,province,amphoe,reporter) "
  sql += "VALUES ('#{provid}','#{ampid}','#{province}','#{amphoe}','#{reporter}') "
  res = con.exec(sql)
  con.close
end

def getProvince(pcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT province FROM report1 WHERE provid='#{pcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  province = 'NA'
  province = res[0][0].to_s if found > 0
  province
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT DISTINCT o_provid,o_ampid2,o_province,o_amphoe "
sql += "FROM office53 "
sql += "ORDER BY o_provid,o_ampid2"
puts sql
exit
res = con.exec(sql)
con.close

=begin
src.each do |l|
  f = l.chomp.split(/\t/)
  dho = f[0]
  amp = dho.split('.').last
  acode = f[1][2..3]
  pcode = f[1][0..1]
  province = getProvince(pcode)
  insert(pcode,acode,province,amp,dho)
end
=end
