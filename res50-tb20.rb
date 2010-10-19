#!/usr/bin/ruby

#TABLE 20 DOCTORS|DENTISTS|PHARMACISTS|PN|TN þ�. By Pak

require 'postgres'

#Get info
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb20_f1 order by pak"
res = con.exec(sql)

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 20</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>���ҧ 20 �ӹǹ�ؤ�ҡ÷ҧ���ᾷ�� þ�./þ�. ����Ҥ �� 2550</h4>\n"
html += "<table width='75%' border='1'>\n"
html += "<tr><th>�Ҥ</th><th>ᾷ��</th><th>�ѹ�ᾷ��</th>"
html += "<th>���Ѫ��</th><th>��Һ���ԪҪվ</th><th>��Һ��෤�Ԥ</th></tr>\n"

md = dt = ph = pn = tn = 0

res.each do |rec|
  pak = rec[0].to_s
  doctor = rec[1].to_s.to_i
  dentist = rec[2].to_s.to_i
  pharmacist = rec[3].to_s.to_i
  profnurse = rec[4].to_s.to_i
  technurse = rec[5].to_s.to_i
  md += doctor
  dt += dentist
  ph += pharmacist
  pn += profnurse
  tn += technurse

  html += "<tr><th align='left'>#{pak}</th><th>#{doctor}</th>"
  html += "<th>#{dentist}</th><th>#{pharmacist}</th><th>#{profnurse}</th>"
  html += "<th>#{technurse}</th></tr>\n"
end

html += "<tr><th align='right'>TOTAL</th><th>#{md}</th><th>#{dt}</th>"
html += "<th>#{ph}</th><th>#{pn}</th><th>#{tn}</th></tr>\n"
html += "</table>\n"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb20.html","w").write(html)
