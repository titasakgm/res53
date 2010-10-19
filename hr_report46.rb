#!/usr/bin/ruby

print <<EOF
Content-type: text/html

<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<body text='green'>
<center>
<h3>สรุปรายงานปีงบประมาณ 2546</h3>
<h4><font 
color='red'>(ข้อมูลเบื้องต้น เฉพาะที่มีรายงานเข้ามาเท่านั้น 
อยู่ระหว่างการตรวจสอบ)</font></h4> <table border='0' width='35%'>
<tr>
<th><input type='button' value='รายงานบุคลากร รายจังหวัด' style='width:100%' 
onClick="document.location.href='/resource46/person.rb'">
</th>
</tr>

<tr>
<th><input type='button' value='จำนวนแพทย์ รายจังหวัด' style='width:100%' 
onClick="document.location.href='/student/doctor.rb?yr=46'">
</th>
</tr>
<tr>
<th><input type='button' value='จำนวนทันตแพทย์ รายจังหวัด' style='width:100%' 
onClick="document.location.href='/student/dentist.rb?yr=46'">
</th>
</tr>
<tr>
<th><input type='button' value='จำนวนเภสัชกร รายจังหวัด' style='width:100%' 
onClick="document.location.href='/student/pharmacist.rb?yr=46'">
</th>
</tr>
<tr>
<th><input type='button' value='จำนวนพยาบาล รายจังหวัด' style='width:100%' 
onClick="document.location.href='/student/nurse1.rb?yr=46'">
</th>
</tr>

<tr>
<th><input type='button' value='รายงานเครื่องมือแพทย์ราคาแพง' style='width:100%' 
onClick="document.location.href='/resource46/equipt.rb?yr=46'">
</th>
</tr>
<tr>
<th><input type='button' value='รายงานจำนวนสถานพยาบาลและจำนวนเตียง' style='width:100%' 
onClick="document.location.href='/student/mebed1.rb?yr=46'">
</th>
</tr>
</table>
</center>
</body>
</html>
EOF
