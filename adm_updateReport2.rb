#!/usr/bin/ruby

require 'postgres'
require 'res_util.rb'

pcode = ARGV[0]

if (pcode.nil?)
  puts "usage: ./adm_updateReport2.rb <pcode>"
  puts "<pcode> => 0 to process ALL"
  exit(0)
end

def updateReport2(provid,ampid,count)
  total = count
  govt = 0
  private = 0
  balance = total
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "UPDATE report2 SET total=#{total},govt=#{govt},"
  sql += "private=#{private},balance=#{balance} "
  sql += "WHERE provid='#{provid}' AND ampid='#{ampid}' "
  res = con.exec(sql)
  con.close
end  

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT pcode,acode,count(*) FROM reportmon "
if (pcode.to_i > 0)
  sql += "WHERE pcode='#{pcode}' "
end
sql += "GROUP BY pcode,acode "
sql += "ORDER BY pcode,acode"
res = con.exec(sql)
con.close

res.each do |rec|
  provid= rec[0]
  ampid = rec[1]
  count = rec[2]
  updateReport2(provid,ampid,count)
end

if (pcode.to_i == 0)
  # for Bangkok pcode='10' acode = 'any'
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT count(*) FROM reportmon "
  sql += "WHERE pcode='10' "
  res = con.exec(sql)
  total = res[0][0]
  sql = "UPDATE report2 SET total=#{total},govt=0,"
  sql += "private=0,balance=#{total} "
  sql += "WHERE provid='10' "
  res = con.exec(sql)
  con.close
end

