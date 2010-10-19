#!/usr/bin/ruby

require 'postgres'
require 'res_util.rb'

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT o_code FROM office53"
res = con.exec(sql)
con.close

res.each do |rec|
  hcode = rec[0]
  checkComplete(hcode)
end

