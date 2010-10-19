#!/usr/bin/ruby

require 'postgres'

def updateReport2(pcode,acode,totg,totp)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "UPDATE report2 SET totgovt=#{totg},totpriv=#{totp} "
  sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  puts sql
  res = con.exec(sql)
  # Then update total and balance
  sql = "UPDATE report2 SET total=totgovt+totpriv,balance=#{totg}+#{totp}-govt-private "
  sql += "WHERE provid='#{pcode}' AND ampid='#{acode}' "
  puts sql
  res = con.exec(sql)
  con.close
end

pcode = ARGV[0]

if (pcode.nil?)
  puts "usage: ./adm_updateReport2GMP.rb <pcode>"
  puts "<pcode> => 0 to process ALL"
  exit(0)
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT * "
sql += "FROM totgmp "
if (pcode.to_i > 0)
  sql += "WHERE pcode='#{pcode}' "
end
sql += "ORDER BY pcode,acode,otype"
puts sql
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
