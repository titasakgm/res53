#!/usr/bin/ruby

require 'postgres'

def update(provid, ampid, amphoe)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE office SET o_amphoe='#{amphoe}' "
  sql += "WHERE o_provid='#{provid}' AND o_ampid='#{ampid}' "
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT provid,ampid,amphoe FROM report2 "
res = con.exec(sql)
con.close

res.each do |rec|
  pcode = rec[0].to_s.strip
  acode = rec[1].to_s.strip
  aname = rec[2].to_s.strip
  update(pcode,acode,aname)
end

