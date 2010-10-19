#!/usr/bin/ruby

s = ""
(0..79).each do |n|
  num = sprintf("%02d", n+1)
  s = "#{s}\n  h1 += \"S#{num}-1M,S#{num}-1F,S#{num}-2M,S#{num}-2F,\""
end

File.open("/tmp/form1title","w").write(s)

