#!/usr/bin/ruby

require 'postgres'

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT * FROM prov "
res = con.exec(sql)
con.close

prov = open("sel-prov","w")
res.each do |rec|
  pn = rec[0]
  pc = rec[1]
  px = "<option id='#{pc}'>#{pn}</option>\n"
  prov.write(px)
end

prov.close

