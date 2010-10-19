#!/usr/bin/ruby

require 'postgres'

def addData(dat)
  report = open("res-wh01-50.csv","a")
  report.write(dat)
  report.close
end

def getResInfo(pcode,year)
  yr = "r_#{year}"
  con = PGconn.connect("localhost",5432,nil,nil,"resource#{year[-2..-1]}")
  sql = "SELECT r_pak,r_khet,r_pname,#{yr} FROM resinfo "
  sql += "WHERE r_prov='#{pcode}' "
  puts sql
  exit
  res = con.exec(sql)
  con.close
  info = nil
  res.each do |rec|
    pak = rec[0]
    khet = rec[1]
    pn = rec[2]
    pop = rec[3]
    pak = "ภาคกลาง" if pak == '1'
    pak = "ภาคตะวันออกเฉียงเหนือ" if pak == '2'
    pak = "ภาคเหนือ" if pak == '3'
    pak = "ภาคใต้" if pak == '4'
    pak = "กทม." if pak == '0'
    info = "#{pak}|#{khet}|#{pn}|#{pop}|"
  end
  info
end

def getOffInfo(hcode,year)
  db = "resource#{year[-2..-1]}"
  con = PGconn.connect("localhost",5432,nil,nil,"#{db}")
  sql = "SELECT o_name,o_minisid,m_desc,o_provid,o_province FROM office,minisid "
  sql += "WHERE o_code='#{hcode}' AND o_minisid=m_code"
  res = con.exec(sql)
  con.close
  hn = mn = md = pc = pn = nil
  res.each do |rec|
    hn = rec[0].to_s.split(',').first.strip
    mn = rec[1].to_s.chomp.tr('*','')
    md = rec[2].to_s # ministry descr
    pc = rec[3].to_s
    pn = rec[4].to_s
  end
  md2 = md
  md2 = 'กระทรวงอื่นๆ' if (mn =~ /000$/ && mn !~ /21000/)
  info = "#{hn}|#{mn}|#{md}|#{md2}|#{pc}|#{pn}|"
end

def getHospInfo(hcode,year) # From form4
  db = "resource#{year[-2..-1]}"
  con = PGconn.connect("localhost",5432,nil,nil,"#{db}")
  sql = "SELECT f402010,f402070,f402080,f402110,f402120 "
  sql += "FROM form4 WHERE f4hcode='#{hcode}' "
  #puts sql
  res = con.exec(sql)
  con.close
  bed = opd1 = opd2 = ipd = los = nil
  res.each do |rec|
    bed = rec[0]
    opd1 = rec[1]
    opd2 = rec[2]
    ipd = rec[3]
    los = rec[4]
  end
  bed = 0 if bed.nil?
  opd1 = 0 if opd1.nil?
  opd2 = 0 if opd2.nil?
  ipd = 0 if ipd.nil?
  los = 0 if los.nil?
  info = "#{bed}|#{opd1}|#{opd2}|#{ipd}|#{los}|"
end

year = '2548'

#1 get hcode,pcode from reportmon
con = PGconn.connect("localhost",5432,nil,nil,"resource48")
sql = "SELECT pcode,hcode FROM reportmon ORDER BY pcode,hcode"
res = con.exec(sql)
con.close

res.each do |rec|
  pc = rec[0]
  hc = rec[1]

  #1 get pak khet pname pop2550 from resinfo
  resinfo = getResInfo(pc, year)
  #puts "resinfo: #{resinfo}\n\n"

  #2 get o_name o_minisid from office
  offinfo = getOffInfo(hc,year)
  #puts "offinfo: #{offinfo}\n\n"

  #3 get Num beds, OPD1, OPD2, IPD, Length of Stay
  hospinfo = getHospInfo(hc,year)
  #puts "hospinfo: #{hospinfo}\n\n"

  data = "#{resinfo}#{offinfo}#{hospinfo}\n"
  addData(data)
end

