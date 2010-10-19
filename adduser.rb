#!/usr/bin/ruby

users = open("user51").readlines

users.each do |l|
  u = l.chomp
  add = %x! createuser -D -A -e #{u} !
end



