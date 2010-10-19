#!/usr/bin/ruby

require 'postgres'

hc = ARGV[0]

if (hc.nil?)
  puts "usage: adm-del-hcode-form1234.rb <hcode>"
  exit(0)
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "DELETE FROM form1 WHERE f1hcode='#{hc}' "
res = con.exec(sql)
sql = "DELETE FROM form2 WHERE f2hcode='#{hc}' "
res = con.exec(sql)
sql = "DELETE FROM form3 WHERE f3hcode='#{hc}' "
res = con.exec(sql)
sql = "DELETE FROM form4 WHERE f4hcode='#{hc}' "
res = con.exec(sql)
con.close
