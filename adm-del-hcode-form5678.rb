#!/usr/bin/ruby

require 'postgres'

hc = ARGV[0]

if (hc.nil?)
  puts "usage: adm-del-hcode-form5678.rb <hcode>"
  exit(0)
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "DELETE FROM form5 WHERE f5hcode='#{hc}' "
res = con.exec(sql)
sql = "DELETE FROM form6 WHERE f6hcode='#{hc}' "
res = con.exec(sql)
sql = "DELETE FROM form7 WHERE f7hcode='#{hc}' "
res = con.exec(sql)
sql = "DELETE FROM form8 WHERE f8hcode='#{hc}' "
res = con.exec(sql)
con.close
