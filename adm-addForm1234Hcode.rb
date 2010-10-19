#!/usr/bin/ruby

require 'postgres'

def checkDup(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT * FROM form1 "
  sql += "WHERE f1hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  dup = (found > 0) ? true : false
end

def insert(f1year,f1pname,f1pcode,f1hname,f1hcode)
  dup = checkDup(f1hcode)
  puts "dup: #{dup}"
  if !(dup)
    con = PGconn.connect("localhost",5432,nil,nil,"resource53")
    sql = "INSERT INTO form1 (f1year,f1pname,f1pcode,f1hname,f1hcode) "
    sql += "VALUES ('#{f1year}','#{f1pname}','#{f1pcode}','#{f1hname}','#{f1hcode}') "
    puts sql
    res = con.exec(sql)
    sql = "INSERT INTO form2 (f2year,f2pname,f2pcode,f2hname,f2hcode) "
    sql += "VALUES ('#{f1year}','#{f1pname}','#{f1pcode}','#{f1hname}','#{f1hcode}') "
    puts sql
    res = con.exec(sql)
    sql = "INSERT INTO form3 (f3year,f3pname,f3pcode,f3hname,f3hcode) "
    sql += "VALUES ('#{f1year}','#{f1pname}','#{f1pcode}','#{f1hname}','#{f1hcode}') "
    puts sql
    res = con.exec(sql)
    sql = "INSERT INTO form4 (f4year,f4pname,f4pcode,f4hname,f4hcode) "
    sql += "VALUES ('#{f1year}','#{f1pname}','#{f1pcode}','#{f1hname}','#{f1hcode}') "
    puts sql
    res = con.exec(sql)
    con.close
  end
end

hcode = ARGV[0]

if (hcode.nil?)
  puts "usage: ./adm-addForm1234Hcode.rb <hcode>\n"
  exit(0)
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT o_province,o_provid,o_name "
sql += "FROM office53 "
sql += "WHERE o_code='#{hcode}' "
res = con.exec(sql)
con.close

found = res.num_tuples
if (found > 0)
  res.each do |rec|
    pname = rec[0]
    pcode = rec[1]
    hname = rec[2]
    insert('2551',pname,pcode,hname,hcode)
  end
end

