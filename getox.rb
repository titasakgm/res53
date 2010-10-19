#!/usr/bin/ruby

require 'postgres'

def updateReport2(pc,ac,gok,pok)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE report2 "
  sql += "SET govt=#{gok},private=#{pok},balance=total-govt-private "
  sql += "WHERE pcode='#{pc}' "
  if (pc != '10')
    sql += "AND acode='#{ac}' "
  end
  puts sql
end

def getOK(pc,ac)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  gok = pok = 0
  sql = "SELECT otype,stat,count(*) "
  sql += "FROM chkcomplete "
  sql += "WHERE pcode='#{pc}' "
  if (pc != '10')
    sql += "AND acode='#{ac}' "
  end
  sql += "GROUP BY otype,stat"
  puts sql
  res = con.exec(sql)
  con.close
  res.each do |rec|
    otype = rec[0]
    stat = rec[1]
    count = rec[2].to_i
    next if (stat == 'o')
    if (otype == 'G' || otype == 'M')
      gok += count
    else
      pok += count
    end
  end
  updateReport2(pc,ac,gok,pok)
end
