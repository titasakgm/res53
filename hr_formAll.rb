#!/usr/bin/ruby

require 'cgi'
require 'res_util.rb'

c = CGI::new
user = c['user'].to_s.split('').join('')
sessid = c['sessid']
year = c['year'].to_s.split('').join('')
offReport = c['offReport'].to_s.split('').join('')
otype = getOtype(offReport)

owner = checkOwner(user,offReport)
if !(owner)
  print "Location:/res53/res-02.rb?user=#{user}&sessid=#{sessid}&msg=NOTOWNER\n\n"  
end

if (otype == 'M')
  print "Location:hr_form2.rb?user=#{user}&sessid=#{sessid}&year=#{year}&offReport=#{offReport}\n\n"
elsif (otype == 'G')
  print "Location:hr_form1.rb?user=#{user}&sessid=#{sessid}&year=#{year}&offReport=#{offReport}\n\n"
elsif (otype == 'P')
  print "Location:hr_form5.rb?user=#{user}&sessid=#{sessid}&year=#{year}&offReport=#{offReport}\n\n"
elsif (otype == 'NA')
  print "Location:/res53/res-02.rb?user=#{user}&sessid=#{sessid}\n\n"
else
  print "Location:/res53\n\n"
end
