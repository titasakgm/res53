#!/usr/bin/ruby

# Report reasons for not complete the forms

require 'postgres'
require 'cgi'
require 'res_util.rb'
require 'hr_util.rb'

c = CGI::new
hcode = c['hcode']
hname = getOfficeName(hcode)
reason = c['reason']
remark = c['remark']
msg = nil

if (reason.to_s.length > 0 || remark.to_s.length > 0)
  msg = addIncomplete(hcode,reason,remark)
end

flag = checkExist(hcode)
log("flag: #{flag}")
if (flag)
  info = getFailReport(hcode)
  log("info: #{info}")
  reason = info[0]
  remark = info[1]
end

print <<EOF
Content-type: text/html

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<head>
<script>
function clearForm()
{
  document.getElementById('reason_id').value = '';  
  document.getElementById('remark_id').value = '';  
}
</script>
</head>
<body bgcolor='#FFCCCC'>
<h4>บันทึกเหตุผลไม่ส่งรายงาน</h4>
<form name='f_form' action='res-06.rb' method='POST'>
<input type='hidden' name='hcode' value='#{hcode}' />
<table border='1' width='60%'>
<tr>
  <th align='right' width='20%'>รหัส:</th>
  <td>#{hcode}</td>
</tr>
<tr>
  <th align='right'>หน่วยงาน:</th>
  <td>#{hname}</td>
</tr>
<tr>
  <th align='right'>ระบุเหตุผล:</th>
  <td><textarea id='reason_id' name='reason' rows='3' 
      style='width:100%'>#{reason}</textarea></td>
</tr>
<tr>
  <th align='right'>หมายเหตุ:</th>
  <td><textarea id='remark_id' name='remark' rows='3' 
      style='width:100%'>#{remark}</textarea></td>
</tr>
<tr>
  <th>&nbsp;</th>
  <td><input type='submit' value='OK'/>
      <input type='button' value='Clear' onclick='clearForm()'/>
      <input type='button' value='Delete' style='background-color: red'
      onclick="document.location.href='adm_deleteFailReport.rb?hcode=#{hcode}'"
  </td>
</tr>
</table>
</form>
<p>
<font color='red'><b><i>#{msg}</i></b></font>
<p>
<input type='button' value='ปิดหน้าต่าง' onclick='window.close()' />
</body>
</html>
EOF


