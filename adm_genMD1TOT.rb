#!/usr/bin/ruby

f1 = Array.new
f2 = Array.new
f3 = Array.new
f4 = Array.new
fp1 = open("/tmp/fp1","w")
fp2 = open("/tmp/fp2","w")
fp3 = open("/tmp/fp3","w")
fp4 = open("/tmp/fp4","w")

(1..79).each do |n|
  m = sprintf("%02d",n)
  fld1 = "f6#{m}001.to_i"
  f1.push(fld1)
  fld2 = "f6#{m}002.to_i"
  f2.push(fld2)
  fld3 = "f6#{m}003.to_i"
  f3.push(fld3)
  fld4 = "f6#{m}004.to_i"
  f4.push(fld4)
end

md1tot = "#{f1.join('+')}"
md2tot = "#{f2.join('+')}"
md3tot = "#{f3.join('+')}"
md4tot = "#{f4.join('+')}"

fp1.write(md1tot)
fp2.write(md2tot)
fp3.write(md3tot)
fp4.write(md4tot)

fp1.close
fp2.close
fp3.close
fp4.close

