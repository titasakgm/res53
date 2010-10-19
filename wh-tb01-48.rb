#!/usr/bin/ruby

require 'postgres'

con = PGconn.connect("localhost",5432,nil,nil,"resource48")
sql1 = "SELECT * FROM tb01_f4_48"
res1 = con.exec(sql1)
sql2 = "SELECT * FROM tb01_f8_48"
res2 = con.exec(sql2)
con.close

dat = open("/tmp/wh-tb01-48.csv","w")
dat.write("hcode,hname,mincode,ประเภทสังกัด,ประเภทบริการ,จำนวนเตียง\n")

res1.each do |rec|
  hc = rec[0]
  hn = rec[1]
  mc = rec[2]
  md = rec[3]
  srv = rec[4]
  bed = rec[5]

  # สำนักการแพทย์กทม (00025) -> เทศบาล (00023)
  md = 'เทศบาล' if mc == '00025'
  mc = '00023' if mc == '00025'
  
  # โรงงานยาสูบ กระทรวงการคลัง (03000) -> รัฐวิสาหกิจ (00022)
  md = 'รัฐวิสาหกิจ' if hc == '11532'
  mc = '00022' if hc == '11532'

  srv = '1' if srv != '0'
  srv = "ทั่วไป" if srv == '0'
  srv = "เฉพาะโรค" if srv == '1'
  dat.write("#{hc},#{hn},#{mc},#{md},#{srv},#{bed}\n")
end

res2.each do |rec|
  hc = rec[0]
  hn = rec[1]
  mc = rec[2]
  md = rec[3]
  srv = rec[4]
  bed = rec[5]

  # สำนักการแพทย์กทม (00025) -> เทศบาล (00023)
  md = 'เทศบาล' if mc == '00025'
  mc = '00023' if mc == '00025'
  
  # โรงงานยาสูบ กระทรวงการคลัง (03000) -> รัฐวิสาหกิจ (00022)
  md = 'รัฐวิสาหกิจ' if hc == '11532'
  mc = '00022' if hc == '11532'

  srv = '1' if srv != '0'
  srv = "ทั่วไป" if srv == '0'
  srv = "เฉพาะโรค" if srv == '1'
  dat.write("#{hc},#{hn},#{mc},#{md},#{srv},#{bed}\n")
end

dat.close


