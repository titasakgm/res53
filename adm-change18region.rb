#!/usr/bin/ruby

require 'postgres'

# resource53
# resinfo52
# r_pak   | character(1)
# r_khet  | character(2)
# r_prov  | character(2)
# r_pname | character varying
# r_2552  | integer

def updateRegion(pcode,pak,khet)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "UPDATE resinfo52 SET r_pak='#{pak}',r_khet='#{khet}' "
  sql += "WHERE r_prov='#{pcode}' "
  puts sql
  res = con.exec(sql)
  con.close
end

src = open("newregion.csv").readlines
src.each do |l|
  f = l.chomp.split(',')
  pcode = f[0]
  pak = f[1]
  khet = f[2]
  updateRegion(pcode, pak, khet)
end

