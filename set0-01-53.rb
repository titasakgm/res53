#!/usr/bin/ruby

require 'postgres'

def update(form,ord)
  f001 = "f#{form}#{ord}001"
  f002 = "f#{form}#{ord}002"
  f003 = "f#{form}#{ord}003"
  f004 = "f#{form}#{ord}004"
  con = PGconn.connect("localhost",5432,nil,nil,"resource50")
  sql = "UPDATE form#{form} SET #{f001}='0' WHERE #{f001}='' "
  puts sql
  res = con.exec(sql)
  sql = "UPDATE form#{form} SET #{f001}='0' WHERE #{f001} IS NULL "
  puts sql
  res = con.exec(sql)
  sql = "UPDATE form#{form} SET #{f002}='0' WHERE #{f002}='' "
  puts sql
  res = con.exec(sql)
  sql = "UPDATE form#{form} SET #{f002}='0' WHERE #{f002} IS NULL "
  puts sql
  res = con.exec(sql)
  sql = "UPDATE form#{form} SET #{f003}='0' WHERE #{f003}='' "
  puts sql
  res = con.exec(sql)
  sql = "UPDATE form#{form} SET #{f003}='0' WHERE #{f003} IS NULL "
  puts sql
  res = con.exec(sql)
  sql = "UPDATE form#{form} SET #{f004}='0' WHERE #{f004}='' "
  puts sql
  res = con.exec(sql)
  sql = "UPDATE form#{form} SET #{f004}='0' WHERE #{f004} IS NULL "
  puts sql
  res = con.exec(sql)
  con.close
end

(16..53).each do |n|
  ord = sprintf("%02d", n)
  update("2", ord)
  update("6", ord)
end  
