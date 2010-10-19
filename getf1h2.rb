#!/usr/bin/ruby

s = ""
(6..321).each do |n|
  s = "#{s}\n    h2 += (f#{n} > 0) ? \"<th class='hili'>\#\{f#{n}\}</th>\" : \"<th>\#\{f#{n}\}</th>\""
end

File.open("/tmp/form1","w").write(s)

