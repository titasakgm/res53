#!/usr/bin/ruby

require 'postgres'

p2 = Array.new
p6 = Array.new

(1..79).each do |n|
  ord = sprintf("%02d", n)
  con = PGconn.connect("localhost",5432,nil,nil,"resource50")
  sql = "SELECT sum(int2(f2#{ord}001)+int2(f2#{ord}002)+int2(f2#{ord}003)+int2(f2#{ord}004)) "
  sql += "FROM form2"
  res1 = con.exec(sql)
  n1 = res1[0][0].to_s.to_i
  p2.push(n1)
  #puts p2.join('|')

  sql = "SELECT sum(int2(f6#{ord}001)+int2(f6#{ord}002)) "
  sql += "FROM form6"
  res2 = con.exec(sql)
  n2 = res2[0][0].to_s.to_i
  p6.push(n2)
  #puts p6.join('|')
  con.close
end

tot1 = 0
(0..p2.size-1).each {|n| tot1 += p2[n]}

tot2 = 0
(0..p6.size-1).each {|n| tot2 += p6[n]}

puts "public: #{tot1}"
puts "private: #{tot2}"

puts p2.join('|')
puts p6.join('|')
