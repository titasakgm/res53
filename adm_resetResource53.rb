#!/usr/bin/ruby

require 'postgres'

def setForm1(hcode)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET form1='X' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")

# reset-01
sql = "UPDATE chkcomplete SET stat='o' "
res = con.exec(sql)

# reset-02
sql = "DELETE FROM failreport"
res = con.exec(sql)

# reset-03
sql = "DELETE FROM form1"
res = con.exec(sql)
sql = "DELETE FROM form2"
res = con.exec(sql)
sql = "DELETE FROM form3"
res = con.exec(sql)
sql = "DELETE FROM form4"
res = con.exec(sql)
sql = "DELETE FROM form5"
res = con.exec(sql)
sql = "DELETE FROM form6"
res = con.exec(sql)
sql = "DELETE FROM form7"
res = con.exec(sql)
sql = "DELETE FROM form8"
res = con.exec(sql)

# reset-04
sql = "UPDATE report1 SET govt=0,private=0,balance=total "
res = con.exec(sql)

# reset-05
sql = "UPDATE report2 SET govt=0,private=0,balance=total "
res = con.exec(sql)

# reset-06
sql = "UPDATE reportmon SET hyear=null,form1=null,form2=null,"
sql += "form3=null,form4=null,form5=null,form6=null,form7=null,"
sql += "form8=null,repdate=null"
res = con.exec(sql)

# reset-07
#sql = "SELECT hcode FROM reportmon,office "
#sql += "WHERE hcode=o_code AND o_type='M' "
#res = con.exec(sql)
#con.close

#res.each do |rec|
#  hcode = rec[0]
#  setForm1(hcode)
#end

