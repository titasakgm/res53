#!/usr/bin/ruby

#TABLE 24 �ӹǹʶҹ��Һ�ŷ������§�Ѻ����������ҧ�׹ ��Шӹǹ��§ ��ṡ����ѧ�Ѵ ��¨ѧ��Ѵ �� 2550

require 'postgres'

#Get BEDS from form4
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb24_f4 order by khet,pcode"
res1 = con.exec(sql)

#Get BEDS from form8
sql = "select * from v_tb24_f8 order by khet,pcode"
res2 = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 24</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>���ҧ 24  �ӹǹʶҹ��Һ�ŷ������§�Ѻ����������ҧ�׹ ��Шӹǹ��§ "
html += "��ṡ����ѧ�Ѵ ��¨ѧ��Ѵ �� 2550</h4>"
html += "<pre>\n"
html += "�Ҥ|ࢵ|���ʨѧ��Ѵ|�ѧ��Ѵ|�ѧ�Ѵ|�ӹǹ���|�ӹǹ��§\n"

res1.each do |rec|
  html += rec.join('|')
  html += "\n"
end

html += "<hr>\n"
html += "�Ҥ|ࢵ|���ʨѧ��Ѵ|�ѧ��Ѵ|�ѧ�Ѵ|�ӹǹ���|�ӹǹ��§\n"

res2.each do |rec|
  html += rec.join('|')
  html += "\n"
end

html += "</pre>\n"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb24.html","w").write(html)
