#!/usr/bin/ruby

require 'postgres'

def updateAmp(hcode,ampcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE chkcomplete SET acode='#{ampcode}' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

src = open("offamp.txt").readlines
src.each do |l|
  f = l.chomp.split('|')
  hcode = f[0]
  pcode = f[1]
  acode = f[2]
  updateAmp(hcode,acode)
end

