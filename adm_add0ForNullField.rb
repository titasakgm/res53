#!/usr/bin/ruby

if ARGV[1] == nil
  puts "usage: adm_add0ForNullField.rb <src> <dst>"
  exit(0)
end

src = open(ARGV[0]).readlines
dst = open(ARGV[1],"w")

src.each do |l|
  fld = l.split(' ').first
  code = "#{fld} = '0' if (#{fld}.to_s.length == 0)\n"
  dst.write(l)
  dst.write(code)
end

dst.close
