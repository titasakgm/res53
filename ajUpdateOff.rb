#!/usr/bin/ruby

require 'cgi'
require 'res_util.rb'
require 'hr_util.rb'

def getOldOffInfo(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "SELECT o_provid,o_type "
  sql += "FROM office53 WHERE o_code='#{hcode}' "
  res = con.exec(sql)
  con.close
  info = 'NA'
  res.each do |rec|
    info = rec.join('|')
  end
  info
end

def save(msg)
  log = open("/tmp/ic","a")
  log.write(msg)
  log.write("\n")
  log.close
end

c = CGI::new
#Admin's sessid
sessid = c['sessid']
flag = checkSession('admin',sessid)
if !flag
  print "Location:/res53\n\n"
  exit
end

ocode = c['ocode'].to_s.split('').join('')
oname = c['oname'].to_s.split('').join('')
oprovid = c['oprovid'].to_s.split('').join('')
oampid = c['oampid'].to_s.split('').join('')
oampid2 = c['oampid2'].to_s.split('').join('')
ooffice = c['ooffice'].to_s.split('').join('')
otype = c['otype'].to_s.split('').join('')
ominisid = c['ominisid'].to_s.split('').join('')

oprovince = getProvince(oprovid)
oamphoe = getAmphoe(oprovid,oampid)

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
sql = "SELECT o_code FROM office53 WHERE o_code='#{ocode}' "
res = con.exec(sql)
con.close
found = res.num_tuples
if (found == 0)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "INSERT INTO office53 (o_code) VALUES ('#{ocode}')"
  res = con.exec(sql)
  con.close

print <<EOF
Content-type: text/html

<font color='red'>เพิ่มรายการ hcode 1 รายการ กรุณา Search และ Update รายละเอียดอีกครั้งด้วยครับ</font>
EOF

else
  oldinfo = getOldOffInfo(ocode)
  i = oldinfo.split('|')
  oldpcode = i[0]
  oldtype = i[1]
  
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE office53 SET o_name='#{oname}',o_provid='#{oprovid}',"
  sql += "o_province='#{oprovince}',o_ampid='#{oampid}',o_amphoe='#{oamphoe}',"
  sql += "o_office='#{ooffice}',o_type='#{otype}',o_minisid='#{ominisid}',"
  sql += "o_ampid2='#{oampid2}' "
  sql += "WHERE o_code='#{ocode}' "
  save(sql)
  res = con.exec(sql)

  # Also update chkcomplete for display name in getOffByProv
  sql = "UPDATE chkcomplete SET hname='#{oname}',pcode='#{oprovid}',"
  sql += "acode='#{oampid2}',otype='#{otype}' WHERE hcode='#{ocode}' "
  res = con.exec(sql)
  save(sql)

  # Update office name in form1-form8
  sql = "UPDATE form1 SET f1hname='#{oname}' WHERE f1hcode='#{ocode}' "
  res = con.exec(sql)
  sql = "UPDATE form2 SET f2hname='#{oname}' WHERE f2hcode='#{ocode}' "
  res = con.exec(sql)
  sql = "UPDATE form3 SET f3hname='#{oname}' WHERE f3hcode='#{ocode}' "
  res = con.exec(sql)
  sql = "UPDATE form4 SET f4hname='#{oname}' WHERE f4hcode='#{ocode}' "
  res = con.exec(sql)
  sql = "UPDATE form5 SET f5hname='#{oname}' WHERE f5hcode='#{ocode}' "
  res = con.exec(sql)
  sql = "UPDATE form6 SET f6hname='#{oname}' WHERE f6hcode='#{ocode}' "
  res = con.exec(sql)
  sql = "UPDATE form7 SET f7hname='#{oname}' WHERE f7hcode='#{ocode}' "
  res = con.exec(sql)
  sql = "UPDATE form8 SET f8hname='#{oname}' WHERE f8hcode='#{ocode}' "
  res = con.exec(sql)

  con.close

  if (oprovid == '99') # Remove a record
    if (oldtype == 'P')
      #puts "deleteF58(ocode)"
      deleteF58(ocode)
    else
      #puts "deleteF14(ocode)"
      deleteF14(ocode)
    end
    #puts "deleteReportmon(ocode)"
    deleteReportmon(ocode)
    
    cmd = "/res53/adm_updateTotgmp.rb #{oldpcode}"
    #puts "cmd: #{cmd}"
    system(cmd)

    cmd = "/res53/adm_updateReport2GMP.rb #{oldpcode}"
    #puts "cmd: #{cmd}"
    system(cmd)

    cmd = "/res53/adm_updateReport2.rb #{oldpcode}"
    #puts "cmd: #{cmd}"
    system(cmd)

  else
    # check entry in reportmon if NOT exist --> add hcode
    updateReportmon(ocode,oprovid,oampid) 
  end

print <<EOF
Content-type: text/html

1 record updated!
EOF
end
