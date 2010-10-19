#!/usr/bin/ruby

require 'postgres'

def updateRepdate(hcode,date)
  con = PGconn.connect("localhost",5432,nil,nil,"resource53")
  sql = "UPDATE reportmon SET repdate='#{date}' "
  sql += "WHERE hcode='#{hcode}' "
  res = con.exec(sql)
  con.close
end

# /tmp/xx came from grep offReport /var/log/httpd/access_log* | grep POST > /tmp/xx

log = open("/tmp/xx").readlines

log.each do |l|
  f = l.chomp.split('offReport=')
  date = f[0].split('[')[1].split(':').first
  d = date.split('/')
  m = '5' if d[1] == 'May'
  m = '6' if d[1] == 'Jun'
  date = "#{d[0].to_i}/#{m}/2552"
  hcode = f[1][0..4]
  updateRepdate(hcode,date)
end
