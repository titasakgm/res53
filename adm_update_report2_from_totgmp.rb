#!/usr/bin/ruby

require 'postgres'

def updateReport2(pcode,acode,totg,totp)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  #sql = "UPDATE report2 SET totgovt=#{totg},totpriv=#{totp},govt=0,private=0"
  sql = "UPDATE report2 SET totgovt=#{totg},totpriv=#{totp} "
  sql += "WHERE provid='#{pcode}' "
  sql += "AND ampid='#{acode}' " if (pcode != '10')
  res = con.exec(sql)

  #sql = "UPDATE report2 SET total=totgovt+totpriv,balance=total "
  sql = "UPDATE report2 SET total=totgovt+totpriv,balance=total-govt-private "
  sql += "WHERE provid='#{pcode}' "
  sql += "AND ampid='#{acode}' " if (pcode != '10')
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT * "
sql += "FROM totgmp "
sql += "WHERE pcode <> '10' "
sql += "ORDER BY pcode,acode,otype"
res = con.exec(sql)
con.close

oldpc = oldac = nil
totg = totp = 0

res.each do |rec|
  pcode = rec[0]
  acode = rec[1]
  otype = rec[2]
  count = rec[3].to_i
  if (oldpc.nil?)
    oldpc = pcode
    oldac = acode
  end
  if (pcode == oldpc && acode == oldac)
    if (otype == 'G' || otype == 'M')
      totg += count
    elsif (otype == 'P')
      totp += count
    end
  elsif (pcode != oldpc || acode != oldac)
    updateReport2(oldpc,oldac,totg,totp)
    if (otype == 'G' || otype == 'M')
      totg = count
      totp = 0
    elsif (otype == 'P')
      totp = count
      totg = 0
    end
    oldpc = pcode
    oldac = acode
  end
end

updateReport2(oldpc,oldac,totg,totp)

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT otype,sum(total) "
sql += "FROM totgmp "
sql += "WHERE pcode='10' "
sql += "GROUP BY otype"
res = con.exec(sql)
con.close

totg = totp = 0
res.each do |rec|
  otype = rec[0]
  sum = rec[1].to_i
  if (otype == 'P')
    totp += sum
  else
    totg += sum
  end
end

updateReport2('10',0,totg,totp)
