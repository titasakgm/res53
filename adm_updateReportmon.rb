#!/usr/bin/ruby

require 'postgres'
require 'res_util.rb'

def updateReportmon(hcode,ampid)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET acode=#{ampid} "
  sql += "WHERE hcode='#{hcode}' "
  #log("updateReportmon: #{sql}")
  res = con.exec(sql)
  con.close
end  

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT o_code,o_ampid FROM office53 "
sql += "WHERE o_provid <> '10' "
res = con.exec(sql)
con.close

res.each do |rec|
  hcode= rec[0]
  acode = rec[1]
  updateReportmon(hcode,acode)
end

