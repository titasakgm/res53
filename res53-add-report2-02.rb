#!/usr/bin/ruby

require 'postgres'

def checkReport2(pc,ac)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT provid,ampid,totgovt,totpriv "
  sql += "FROM report2 "
  sql += "WHERE provid='#{pc}' AND ampid='#{ac}' "
  res = con.exec(sql)
  con.close
  res.each do |rec|
    puts rec.join('|')
  end
  if (res.num_tuples == 0)
    exit
  end
end

def updateReport2G(pc,ac,govt)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE report2 SET totgovt='#{govt}' "
  sql += "WHERE provid='#{pc}' AND ampid='#{ac}' "
  puts sql
  res = con.exec(sql)
  con.close
end

def updateReport2P(pc,ac,priv)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE report2 SET totpriv='#{priv}' "
  sql += "WHERE provid='#{pc}' AND ampid='#{ac}' "
  puts sql
  res = con.exec(sql)
  con.close
end

oldpc = nil
gx = px = 0

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT otype,sum(total) FROM totgmp2 "
sql += "WHERE pcode='10' "
sql += "GROUP BY otype "
res = con.exec(sql)
con.close

res.each do |rec|
  otype = rec[0]
  total = rec[1].to_i
  if (otype == 'G')
    gx = total
  else
    px = total
  end
end

updateReport2G('10','00',gx)
updateReport2P('10','00',px)
    
con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT pcode,acode,otype,sum(total) FROM totgmp2 "
sql += "WHERE pcode <> '10' "
sql += "GROUP BY pcode,acode,otype "
sql += "ORDER BY pcode,acode,otype "
res = con.exec(sql)
con.close

res.each do |rec|
  pc = rec[0]
  ac = rec[1]
  otype = rec[2]
  total = rec[3].to_i

  if (otype == 'G')
    updateReport2G(pc,ac,total)
  elsif (otype == 'P')
    updateReport2P(pc,ac,total)
  end
end
