#!/usr/bin/ruby

require 'postgres'
require '/res53/res_util.rb'

def insertChkcomplete(pcode,hcode,hname,otype,stat,acode)
  dup = checkDupChkcomplete(hcode)
  if !(dup)
    con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
    sql = "INSERT INTO chkcomplete (pcode,hcode,hname,otype,stat,acode) "
    sql += "VALUES ('#{pcode}','#{hcode}',"
    sql += "'#{hname}','#{otype}','#{stat}','#{acode}')"
    puts sql
    res = con.exec(sql)
    con.close
  else
    puts "#{hcode} already exists in chkcomplete"
  end
end

def insertReportmon(hcode,pcode,acode)
  dup = checkDupReportmon(hcode)
  if !(dup)
    con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
    sql = "INSERT INTO reportmon (hcode,pcode,acode) "
    sql += "VALUES ('#{hcode}','#{pcode}','#{acode}')"
    res = con.exec(sql)
    con.close
  else
    puts "#{hcode} already exists in reportmon"
  end
end

hcode = ARGV[0]

if (hcode.nil?)
  puts "usage: adm_addCheckcomplete.rb <hcode>"
  #exit(0)
end

def checkDupChkcomplete(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT hcode FROM chkcomplete WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  dup = (found == 0) ? false : true
end

def checkDupReportmon(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT hcode FROM reportmon WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  dup = (found == 0) ? false : true
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT o_code,o_provid,o_name,o_type,o_ampid2 "
sql += "FROM office53 "
if !(hcode.nil?)
  sql += "WHERE o_code='#{hcode}' "
end
sql += "ORDER BY o_provid,o_ampid,o_code"
puts sql
res = con.exec(sql)

res.each do |rec|
  hcode = rec[0]
  pcode = rec[1]
  hname = rec[2]
  otype = rec[3]
  stat = 'o'
  acode = rec[4]
  insertChkcomplete(pcode,hcode,hname,otype,stat,acode)
  #insertReportmon(hcode,pcode,acode)
end
