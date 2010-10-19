#!/usr/bin/ruby

require 'postgres'

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT distinct pcode "
sql += "FROM chkcomplete "
sql += "WHERE pcode < '99' "
sql += "ORDER BY pcode "
res = con.exec(sql)
con.close

res.each do |rec|
  pcode = rec[0]
  cmd = "./adm_update_report2_from_chkcomplete.rb #{pcode}"
  system(cmd)
end

