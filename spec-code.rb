#!/usr/bin/ruby

spec = open("profcode.txt","w")

sp = open("hr_form1.rb").readlines
sp.each do |l|
  s = l.gsub(/\<\/th\>/,'|').gsub(/<.+?>/,'').strip
  next if s !~ /^[0-9]/
  f = s.split("|")
  f[0] = "0#{f[0]}" if f[0].to_i < 10
  spec.write("#{f[0]},#{f[1]}\n")  
end
spec.close

