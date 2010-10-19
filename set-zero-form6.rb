#!/usr/bin/ruby

require 'postgres'

def update(fld)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE form6 SET #{fld}=0 "
  sql += "WHERE #{fld} = '' OR #{fld} IS NULL OR #{fld} = '0-' "
  puts sql
  res = con.exec(sql)
  con.close
end

(1..79).each do |n|
  ord = sprintf("%02d", n)
  fld = "f6#{ord}001"
  update(fld)
  fld = "f6#{ord}002"
  update(fld)
  fld = "f6#{ord}003"
  update(fld)
  fld = "f6#{ord}004"
  update(fld)
end

