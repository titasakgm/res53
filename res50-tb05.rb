#!/usr/bin/ruby

#TABLE 05 �ӹǹ þ�. þ�. þ�. ��Шӹǹ��§ ����Ҥ �� 2550

require 'postgres'

#Get BEDS from form4
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb05"
res = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 05</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>���ҧ 05 �ӹǹ þ�. þ�. þ�. ��Шӹǹ��§ ����Ҥ �� 2550</h4>"
html += "<pre>\n"
html += "<pre>\n"
html += "�Ҥ|�������ѧ�Ѵ|�ӹǹ���|�ӹǹ��§\n"

res.each do |rec|
  html += rec.join('|')
  html += "\n"
end

html += "</pre>\n"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb05.html","w").write(html)
