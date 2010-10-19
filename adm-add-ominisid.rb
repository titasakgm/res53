#!/usr/bin/ruby

require 'postgres'

def getMinisid(hcode)
  src = open("minisid.csv").readlines
  minis = 'NA'
  src.each do |l|
    f = l.chomp.split(',')
    if (f[0] == hcode)
      minis = f[1]
      break
    end
  end
  minis
end

def updateMinisid(hc,min)
  con = PGconn.connect("localhost",5432,nil,nil,"resource48")
  sql = "UPDATE office SET o_minisid='#{min}' "
  sql += "WHERE o_code='#{hc}' "
  #puts sql
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource48")
sql = "SELECT o_code FROM office53 "
res = con.exec(sql)
con.close

res.each do |rec|
  hc = rec[0]
  min = getMinisid(hc)
  puts "#{hc} ==> #{min}"
  updateMinisid(hc,min)
end

