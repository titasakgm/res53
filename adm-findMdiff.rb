#!/usr/bin/ruby

require 'postgres'

def getCountM(pcode,acode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT o_code FROM office53 "
  sql += "WHERE o_provid='#{pcode}' AND o_ampid2='#{acode}' "
  sql += "AND o_type='M' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT pcode,acode,sum(total) "
sql += "FROM totgmp "
sql += "WHERE otype='M' "
sql += "GROUP BY pcode,acode "
sql += "ORDER BY pcode,acode"
res = con.exec(sql)
con.close

gtotal = 0
xtotal = 0
res.each do |rec|
  pcode = rec[0]
  acode = rec[1]
  total = rec[2].to_i
  gtotal += total
  totalx = getCountM(pcode,acode)
  xtotal += totalx
  puts "#{pcode} #{acode} #{total} #{totalx}" if (total != totalx)
end

puts "M total: #{gtotal}"
puts "X total: #{xtotal}"

