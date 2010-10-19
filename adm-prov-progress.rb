#!/usr/bin/ruby

require 'postgres'
require 'cgi'

c = CGI::new
pcode = c['user']

con = PGconn.connect("localhost",5432,nil,nil,"resource53")
# get sum(total) and sum(bal)
sql = "SELECT sum(total) as totalx,sum(balance) as balancex FROM report2 "
sql += "WHERE provid='#{pcode}' "
res1 = con.exec(sql)
sql = "SELECT ampid,amphoe,sum(total),sum(balance) FROM report2 "
sql += "WHERE provid='#{pcode}' "
sql += "GROUP BY ampid,amphoe "
sql += "ORDER BY ampid "
res2 = con.exec(sql)
con.close

totx = res1[0][0].to_i
balx = res1[0][1].to_i
finx = totx - balx
ptot = "100.00"
pfin = (finx * 100) / (totx * 1.0)
pfin = sprintf("%.2f",pfin)
pbal = (balx * 100) / (totx * 1.0)
pbal = sprintf("%.2f",pbal)

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<head>
<style>
.left {
  position: relative;
  width: 600;
  float: left;
}
.right {
  position: relative;
  width: 300;
  float: right;
  text-align: right;
}
</style>
<script type="text/javascript" src="js/prototype/prototype.js"></script>
<script type="text/javascript" src="js/bramus/jsProgressBarHandler.js"></script>
</head>
<body bgcolor='#FFCCCC'>
<h4>สรุปความก้าวหน้าการบันทึกรายงาน</h4>
<span class='right'><input type='button' value='Back' onclick='history.back()' /></span>
<table border='0' width='35%'>
<tr>
  <th align='left'>รวมทั้งจังหวัด</th>
  <th align='right'>#{totx}</th>
  <th align='right'>(#{ptot})</th>
</tr>
<tr>
  <th align='left'>บันทึกรายงานแล้ว</th>
  <th align='right'>#{finx}</th>
  <th align='right'>(#{pfin})</th>
</tr>
<tr>
  <th align='left'>ยังไม่บันทึกรายงาน</th>
  <th align='right'>#{balx}</th>
  <th align='right'>(#{pbal})</th>
</tr>
</table>
<hr>
<table width='100%' border='0'>
EOF

n = 0

res2.each do |rec|
  n += 1
  ac = rec[0]
  an = rec[1]
  tot = rec[2].to_i
  bal = rec[3].to_i
  progress = (tot-bal)*100 / (tot*1.0)
  pct = "#{progress.to_i}%"
  pct = '100%' if bal == 0
  pct = '0%' if tot == bal
  if (n%3 == 1)
    print "<tr><td>#{an}</td><th><span class='progressBar' id='#{ac}'>#{pct}</span></th>"
  elsif (n%3 == 2)
    print "<td>#{an}</td><th><span class='progressBar' id='#{ac}'>#{pct}</span></th>"
  elsif (n%3 == 0)
    print "<td>#{an}</td><th><span class='progressBar' id='#{ac}'>#{pct}</span></th></tr>\n"
  end
end

print "<td>&nbsp;</td></tr>"
print "</table>\n"
print "</body>\n"
print "</html>\n"
