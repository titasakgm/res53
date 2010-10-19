#!/usr/bin/ruby

#TABLE 04 �ӹǹʶҹ��Һ�ŷ������§�Ѻ����������ҧ�׹ ��§ �ѵ����ǹᾷ������§
# �����§��ͻ�Ъҡ�����Ҥ �� 2550

require 'postgres'

#Get BEDS and DOCS from form4
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb04_f4"
res1 = con.exec(sql)

#Get BEDS and DOCS from form8
con = PGconn.connect("localhost",5432,nil,nil,"resource50")
sql = "select * from v_tb04_f8"
res2 = con.exec(sql)

#Get pop 2550 from resinfo
sql = "select distinct p_name as pak,sum(int4(r_2550)) "
sql += "from resinfo,pak "
sql += "where r_pak=p_code "
sql += "group by p_name"
res3 = con.exec(sql)
con.close

html = "<html>\n"
html += "<head>\n"
html += "<title>TABLE 04</title>\n"
html += "</head>\n"
html += "<body>\n"
html += "<h4>���ҧ 04 �ӹǹʶҹ��Һ�ŷ������§�Ѻ����������ҧ�׹ ��§ �ѵ����ǹᾷ������§"
html += "�����§��ͻ�Ъҡ�����Ҥ �� 2550</h4>"
html += "<pre>\n"
html += "�Ҥ�Ѱ\n"
html += "�Ҥ|�ӹǹ���|�ӹǹ��§|�ӹǹᾷ��\n"

res1.each do |rec|
  html += rec.join('|')
  html += "\n"
end

html += "<hr>\n"
html += "�Ҥ�͡��\n"
html += "�Ҥ|�ӹǹ���|�ӹǹ��§|�ӹǹᾷ��\n"

res2.each do |rec|
  html += rec.join('|')
  html += "\n"
end

html += "<hr>\n"
html += "�Ҥ|�ӹǹ��Ъҡ�����Ҥ 2550\n"
res3.each do |rec|
  html += rec.join('|')
  html += "\n"
end

html += "</pre>\n"
html += "</body>\n"
html += "</html>\n"

puts html

File.open("/res53/res50-tb04.html","w").write(html)
