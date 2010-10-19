#!/usr/bin/ruby

sql = "CREATE VIEW v_tb22_f2 AS SELECT p_name as pak"
(1..79).each do |n|
  ord = sprintf("%02d",n)
  sql += ",sum(int2(f2#{ord}001)+int2(f2#{ord}002)"
  sql += "+int2(f2#{ord}003)+int2(f2#{ord}004)) as p#{ord} "
end
sql += "FROM form2,office,resinfo,pak "
sql += "WHERE f2hcode=o_code AND f2pcode=r_prov "
sql += "AND r_pak=p_code "
sql += "GROUP BY p_name"

puts sql
puts "\n"

sql = "CREATE VIEW v_tb22_f6 AS SELECT p_name as pak"
(1..79).each do |n|
  ord = sprintf("%02d",n)
  sql += ",sum(int2(f6#{ord}001)+int2(f6#{ord}002)) as p#{ord} "
end
sql += "FROM form6,office,resinfo,pak "
sql += "WHERE f6hcode=o_code AND f6pcode=r_prov "
sql += "AND r_pak=p_code "
sql += "GROUP BY p_name"

puts sql

