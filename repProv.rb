#!/usr/bin/ruby

require 'postgres'

def zipToFtp(yr,pr)
  Dir.chdir("/res53/zip")
  cmd = "zip -r all-#{yr}-#{pr} *.txt"
  zip = %x! #{cmd} !
  cmd = "rm -rf *.txt"
  rm = %x! #{cmd} !
  cmd = "mv *.zip /home/res#{pr}/#{yr}"
  ftp = %x! #{cmd} !
end

def getFormYearProv(fo,yr,pr)
  t = Time.now
  cYr = 51
  db = "resource53"
  dst = open("/res53/zip/f#{fo}-#{yr}-#{pr}.txt","w")
  con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
  sql = "SELECT * FROM form#{fo} WHERE f#{fo}pcode='#{pr}' "
  #puts "sql: #{sql}"
  res = con.exec(sql)
  con.close
  res.each do |rec|
    data = nil
    rec.each do |fld|
      if data.nil?
        data = fld
      else
        data += "|#{fld}"
      end
    end
    dst.write(data)
    dst.write("\n")
  end
  dst.close
end

# Get provid from Table: prov
con = PGconn.connect("localhost",5432,nil,nil,"resource53","postgres")
sql = "SELECT o_provid FROM prov ORDER BY o_provid"
res = con.exec(sql)
con.close

res.each do |rec|
  provid = rec[0]
  getFormYearProv('1','51',provid)
  getFormYearProv('2','51',provid)
  getFormYearProv('3','51',provid)
  getFormYearProv('4','51',provid)
  getFormYearProv('5','51',provid)
  getFormYearProv('6','51',provid)
  getFormYearProv('7','51',provid)
  getFormYearProv('8','51',provid)
  zipToFtp('51',provid)
end
