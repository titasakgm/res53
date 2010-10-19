#!/usr/bin/ruby

spec = open("spec-50.txt","w")

sp = open("f2").readlines
sp.each do |l|
  s = l.gsub(/\<\/th\>/,'|').gsub(/<.+?>/,'').strip
  next if s !~ /^[0-9]/
  f = s.split("|")
  f[0] = "0#{f[0]}" if f[0].to_i < 10
  spec.write("#{f[0]},#{f[1]}\n")  
end
spec.close

