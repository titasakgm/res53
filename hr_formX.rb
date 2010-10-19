#!/usr/bin/ruby
    
require 'cgi'
require 'postgres'
require 'hr_util.rb'

c = CGI::new

user = c['user']
sessid = c['sessid']
year = c['year']
repId = c['offReport']

oType = getOfficeType(repId.to_s)

if oType.to_s == 'M'
  print "Location:hr_form2.rb?user=#{user}&sessid=#{sessid}&year=#{year}&offReport=#{repId}&otype=M\n\n"
elsif oType.to_s == 'G'
  print "Location:hr_form1.rb?user=#{user}&sessid=#{sessid}&year=#{year}&offReport=#{repId}\n\n"
else
  print "Location:hr_form5.rb?user=#{user}&sessid=#{sessid}&year=#{year}&offReport=#{repId}\n\n"
end
