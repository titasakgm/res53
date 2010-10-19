#!/usr/bin/ruby

require 'cgi'

c = CGI::new
hcode = c['hcode']
hcode = '0' if hcode.to_s.length == 0

puts "hcode: #{hcode}"

