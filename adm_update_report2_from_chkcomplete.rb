#!/usr/bin/ruby

require 'postgres'

def updateReport2(pcode,acode,otype,count) 
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "UPDATE report2 "
  if (otype == 'M')
    sql += "SET govt=#{count} "
  elsif (otype == 'G')
    sql += "SET govt = govt+#{count} "
  elsif (otype == 'P')
    sql += "SET private=#{count}"
  end
  sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  re = con.exec(sql)
  sql = "UPDATE report2 SET balance=total-govt-private "
  sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  res = con.exec(sql)
  con.close
end

def updateReport2BKK(pcode,otype,count)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "UPDATE report2 "
  if (otype == 'M')
    sql += "SET govt=#{count} "
  elsif (otype == 'G')
    sql += "SET govt = govt+#{count} "
  elsif (otype == 'P')
    sql += "SET private=#{count}"
  end
  sql += "WHERE provid='#{pcode}' "
  re = con.exec(sql)
  sql = "UPDATE report2 SET balance=total-govt-private "
  sql += "WHERE provid='#{pcode}' "
  res = con.exec(sql)
  con.close
end

pcode = ARGV[0]

if (pcode.nil?)
  puts "usage: ./adm_update_report2_from_chkcomplete.rb <pcode>"
  exit(0)
end

if (pcode != '10')
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT distinct acode,otype,count(*) "
  sql += "FROM chkcomplete "
  sql += "WHERE pcode='#{pcode}' AND stat='x' "
  sql += "GROUP BY acode,otype "
  sql += "ORDER BY acode,otype DESC "
  res = con.exec(sql)
  con.close

  res.each do |rec|
    acode = rec[0]
    otype = rec[1]
    count = rec[2].to_i
    updateReport2(pcode,acode,otype,count)
  end
else # pcode = '10'
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT otype,count(*) "
  sql += "FROM chkcomplete "
  sql += "WHERE pcode='#{pcode}' AND stat='x' "
  sql += "GROUP BY otype "
  sql += "ORDER BY otype DESC "
  res = con.exec(sql)
  con.close

  res.each do |rec|
    otype = rec[0]
    count = rec[1].to_i
    updateReport2BKK(pcode,otype,count)
  end
end
