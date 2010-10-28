function repStatus()
{
  document.getElementById("d_repstatus").style.display = "block";
  document.getElementById("d_addmember").style.display = "none";
  document.getElementById("d_editmember").style.display = "none";
  document.getElementById("d_editoffice").style.didplay = "none";
}
function addMember()
{
  document.getElementById("d_repstatus").style.display = "none";
  document.getElementById("d_addmember").style.display = "block";
  document.getElementById("d_editmember").style.display = "none";
  document.getElementById("d_editoffice").style.didplay = "none";
}
function editMember()
{
  document.getElementById("d_repstatus").style.display = "none";
  document.getElementById("d_addmember").style.display = "none";
  document.getElementById("d_editmember").style.display = "block";
  document.getElementById("d_editoffice").style.display = "none";
}
function editOffice()
{
  document.getElementById("d_repstatus").style.display = "none";
  document.getElementById("d_addmember").style.display = "none";
  document.getElementById("d_editmember").style.display = "none";
  document.getElementById("d_editoffice").style.display = "block";
}

function createRequest()
{
  var req = null;
  try {
    req = new XMLHttpRequest();
  } catch (microsoft) {
    try {
      req = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (othermicrosoft) {
      try {
        req = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (failed) {
        req = null;
      }
    }
  }
  if (req == null)
    alert("Error: cannot crate request!");
  return req;
}

function ajSearchMem()
{
  var userid = document.getElementById("userid").value;
  var sessid = document.getElementById("sessid").value;
  var keymem = document.getElementById("keymem").value;

  if (keymem.length > 0)
  {
    if (userid.length == 2 && userid != keymem.substring(0,2))
    {
      alert("ไม่สามารถแก้ไขข้อมูลของจังหวัดอื่นได้");
      return;
    }
  }
  var req = createRequest();
  var url = "ajSearchMem.rb?keymem=" + encodeURI(keymem);
  req.open("GET", url, true);
  req.onreadystatechange = function () {
    if (req.readyState == 4)
    {
      if (req.status == 200 || req.status == 304)
      {
        var d_editmember = document.getElementById('d_editmember');
        var detail = req.responseText;
        var i = detail.split('|');
        var  h = "<h4>Edit Member</h4>";
        h += "Search: <input id='keymem' type='text' name='keymem' />";
        h += "<input type='hidden' id='userid' name='userid' value='" + userid + "' />"; 
        h += "<input type='hidden' id='sessid' name='sessid' value='" + sessid + "' />"; 
        h += "<input type='button' value=' OK ' onclick='ajSearchMem()' />";
        h += "<hr>";

        h += "<table border='1' width='80%'>";
        h += "<tr>";
        h += "  <th align='right' width='30%'>Username:</th>";
        h += "  <td><input class='ipc100' id='user' type='text' name='username' value='" + i[0] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Password:</th>";
        h += "  <td><input class='ipc100' id='pass' type='text' name='password' value='" + i[1] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Office:</th>";
        h += "  <td><input class='ipc100' id='off' type='text' name='office' value='" + i[2] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Province Code:</th>";
        h += "  <td><input class='ipc100' id='pcode' type='text' name='provid' value='" + i[3] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>First Name:</th>";
        h += "  <td><input class='ipc100' id='fn' type='text' name='fname' value='" + i[4] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Last Name:</th>";
        h += "  <td><input class='ipc100' id='ln' type='text' name='lname' value='" + i[5] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Telephone:</th>";
        h += "  <td><input class='ipc100' id='tel' type='text' name='telno' value='" + i[6] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Email:</th>";
        h += "  <td><input class='ipc100' id='eml' type='text' name='email' value='" + i[7] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>&nbsp;</th>";
        h += "  <td><input type='button' value='Update' onclick='ajUpdateMem()' /></td>";
        h += "</tr>";
        h += "</table>";
        d_editmember.innerHTML = h;
      }
    }
  }
  req.send(null);
}

function ajSearchOff()
{
  var sessid = document.getElementById("sessid").value;
  var keyoff = document.getElementById("keyoff").value;
  var req = createRequest();
  var url = "ajSearchOff.rb?keyoff=" + encodeURI(keyoff);
  req.open("GET", url, true);
  req.onreadystatechange = function () {
    if (req.readyState == 4)
    {
      if (req.status == 200 || req.status == 304)
      {
        var d_editoffice = document.getElementById('d_editoffice');
        var detail = req.responseText;
        var i = detail.split('|');
        var  h = "<h4>Edit Office</h4>";
        h += "Search: <input id='keyoff' type='text' name='keyoff' />";
        h += "<input type='hidden' id='sessid' name='sessid' value='" + sessid + "' />"; 
        h += "<input type='button' value=' OK ' onclick='ajSearchOff()' />";
        h += "<hr>";
     
        h += "<table border='1' width='80%'>";
        h += "<tr>";
        h += "  <th align='right' width='30%'>Off Code:</th>"; 
        h += "  <td><input class='ipc100' id='ocode' type='text' name='ocode' value='" + i[0] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Name:</th>";
        h += "  <td><input class='ipc100' id='oname' type='text' name='oname' value='" + i[1] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Provid:</th>";
        h += "  <td><input class='ipc100' id='oprovid' type='text' name='oprovid' value='" + i[2] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Province:</th>";
        h += "  <td bgcolor='gray'><input class='ipc100' id='oprovince' type='text' name='oprovince' value='" + i[3] + "' DISABLED/></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Ampid:</th>";
        h += "  <td><input class='ipc100' id='oampid' type='text' name='oampid' value='" + i[4] + "' /></td>";
        h += "</tr>";

        if (parseInt(i[9]) == 0)
        { 
          h += "<tr>";
          h += "  <th align='right'>[For Ampid=01]:</th>";
          h += "  <td><select id='oampid2' name='oampid2'/>";
          h += "      <option value='00' SELECTED>00 - สสจ.</option>";
          h += "      <option value='01'>01 - สสอ.เมือง</option>";
          h += "      </select>";
          h += "  </td>";
          h += "</tr>";
        }
        else if (parseInt(i[9]) == 1)
        {
          h += "<tr>";
          h += "  <th align='right'>[For Ampid=01]:</th>";
          h += "  <td><select id='oampid2' name='oampid2'/>";
          h += "      <option value='00'>00 - สสจ.</option>";
          h += "      <option value='01' SELECTED>01 - สสอ.เมือง</option>";
          h += "      </select>";
          h += "  </td>";
          h += "</tr>";
        }

        h += "<tr>";
        h += "  <th align='right'>Off Amphoe:</th>";
        h += "  <td bgcolor='gray'><input class='ipc100' id='oamphoe' type='text' name='oamphoe' value='" + i[5] + "' DISABLED/></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Prefix:</th>";
        h += "  <td><input class='ipc100' id='ooffice' type='text' name='ooffice' value='" + i[6] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Type:</th>";
        h += "  <td><input class='ipc100' id='otype' type='text' name='otype' value='" + i[7] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Minisid:</th>";
        h += "  <td><input class='ipc100' id='ominisid' type='text' name='ominisid' value='" + i[8] + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>&nbsp;</th>";
        h += "  <td><input type='button' value='Update' onclick='ajUpdateOff()' /></td>";
        h += "</tr>";
        h += "</table>";
        d_editoffice.innerHTML = h;
      }
    }
  }
  req.send(null);
}

function ajUpdateMem()
{
  var sessid = document.getElementById("sessid").value;
  var userid = document.getElementById("userid").value;
  var user = document.getElementById("user").value;
  var pass = document.getElementById("pass").value;
  var off = document.getElementById("off").value;
  var pcode = document.getElementById("pcode").value;
  var fn = document.getElementById("fn").value;
  var ln = document.getElementById("ln").value;
  var tel = document.getElementById("tel").value;
  var eml = document.getElementById("eml").value;
  var req = createRequest();

  //user = encodeURIComponent(user);

  var url = "ajUpdateMem.rb?admin=" + userid + "&user=" + user;
  url += "&pass=" + pass + "&off=" + encodeURI(off) + "&pcode=" + pcode;
  url += "&fn=" + encodeURI(fn) + "&ln=" + encodeURI(ln);
  url += "&tel=" + tel + "&eml=" + encodeURI(eml) + "&sessid=" + sessid;
  req.open("GET", url, true);
  req.onreadystatechange = function () {
    if (req.readyState == 4)
    {
      if (req.status == 200 || req.status == 304)
      {
        var resp = req.responseText;
        var  h = "<h4>Edit Member</h4>";
        h += "Search: <input id='keymem' type='text' name='keymem' />";
        h += "<input type='hidden' id='sessid' name='sessid' value='" + sessid + "' />";
        h += "<input type='button' value=' OK ' onclick='ajSearchMem()' />";
        h += "<hr>";

        h += "<table border='1' width='80%'>";
        h += "<tr>";
        h += "  <th align='right' width='30%'>Username:</th>";
        h += "  <td><input class='ipc100' id='user' type='text' name='username' value='" + user + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Password:</th>";
        h += "  <td><input class='ipc100' id='pass' type='text' name='password' value='" + pass + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Office:</th>";
        h += "  <td><input class='ipc100' id='off' type='text' name='office' value='" + off + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Province Code:</th>";
        h += "  <td><input class='ipc100' id='pcode' type='text' name='provid' value='" + pcode + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>First Name:</th>";
        h += "  <td><input class='ipc100' id='fn' type='text' name='fname' value='" + fn + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Last Name:</th>";
        h += "  <td><input class='ipc100' id='ln' type='text' name='lname' value='" + ln + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Telephone:</th>";
        h += "  <td><input class='ipc100' id='tel' type='text' name='telno' value='" + tel + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Email:</th>";
        h += "  <td><input class='ipc100' id='eml' type='text' name='email' value='" + eml + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>&nbsp;</th>";
        h += "  <td><input type='button' value='Update' onclick='ajUpdateMem()' /></td>";
        h += "</tr>";
        h += "</table>";
        h += "<p><table border='0' width='80%'><tr><th>" + resp + "</th></tr></table>";
        document.getElementById("d_editmember").innerHTML = h;
      }
    }
  }
  req.send(null);
}

function ajUpdateOff()
{
  var sessid = document.getElementById("sessid").value;
  var ocode = document.getElementById("ocode").value;
  var oname = document.getElementById("oname").value;
  var oprovid = document.getElementById("oprovid").value;
  var oprovince = document.getElementById("oprovince").value;
  var oampid = document.getElementById("oampid").value;
  var oamphoe = document.getElementById("oamphoe").value;
  var ooffice = document.getElementById("ooffice").value;
  var otype = document.getElementById("otype").value;
  var ominisid = document.getElementById("ominisid").value;

  var sel = document.getElementById("oampid2");
  var oampid2 = sel.options[sel.selectedIndex].value;

  var url = "ajUpdateOff.rb?ocode=" + ocode + "&oname=" + encodeURI(oname);
  url += "&oprovid=" + oprovid + "&oprovince=" + encodeURI(oprovince);
  url += "&oampid=" + oampid + "&oampid2=" + oampid2 + "&oamphoe=" + encodeURI(oamphoe);
  url += "&ooffice=" + encodeURI(ooffice) + "&otype=" + otype;
  url += "&ominisid=" + ominisid + "&sessid=" + sessid;
  alert("ajUpdateOff: " + url);
  var req = createRequest();
  req.open("GET", url, true);
  req.onreadystatechange = function () {
    if (req.readyState == 4)
    {
      if (req.status == 200 || req.status == 304)
      {
        var resp = req.responseText;
        alert('resp:' + resp);
        var  h = "<h4>Edit Office</h4>";
        h += "Search: <input id='keyoff' type='text' name='keyoff' />";
        h += "<input type='hidden' id='sessid' name='sessid' value='" + sessid + "' />";
        h += "<input type='button' value=' OK ' onclick='ajSearchOff()' />";
        h += "<hr>";
        h += "<table border='1' width='80%'>";
        h += "<tr>";
        h += "  <th align='right' width='30%'>Off Code:</th>";
        h += "  <td><input class='ipc100' id='ocode' type='text' name='ocode' value='" + ocode + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Name:</th>";
        h += "  <td><input class='ipc100' id='oname' type='text' name='oname' value='" + oname + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Provid:</th>";
        h += "  <td><input class='ipc100' id='oprovid' type='text' name='oprovid' value='" + oprovid + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Province:</th>";
        h += "  <td><input class='ipc100' id='oprovince' type='text' name='oprovince' value='" + oprovince + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Ampid:</th>";
        h += "  <td><input class='ipc100' id='oampid' type='text' name='oampid' value='" + oampid + "' /></td>";
        h += "</tr>";
        if (oampid2 == '00')
        {
          h += "<tr>";
          h += "  <th align='right'>[For Ampid=01]:</th>";
          h += "  <td><select id='oampid2' name='oampid2'/>";
          h += "      <option value='00' SELECTED>00 - สสจ.</option>";
          h += "      <option value='01'>01 - สสอ.เมือง</option>";
          h += "      </select>";
          h += "  </td>";
          h += "</tr>";        
        }
        else
        {
          h += "<tr>";
          h += "  <th align='right'>[For Ampid=01]:</th>";
          h += "  <td><select id='oampid2' name='oampid2'/>";
          h += "      <option value='00'>00 - สสจ.</option>";
          h += "      <option value='01' SELECTED>01 - สสอ.เมือง</option>";
          h += "      </select>";
          h += "  </td>";
          h += "</tr>";        
        }

        h += "<tr>";
        h += "  <th align='right'>Off Amphoe:</th>";
        h += "  <td><input class='ipc100' id='oamphoe' type='text' name='oamphoe' value='" + oamphoe + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Prefix:</th>";
        h += "  <td><input class='ipc100' id='ooffice' type='text' name='ooffice' value='" + ooffice + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Type:</th>";
        h += "  <td><input class='ipc100' id='otype' type='text' name='otype' value='" + otype + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>Off Minisid:</th>";
        h += "  <td><input class='ipc100' id='ominisid' type='text' name='ominisid' value='" + ominisid + "' /></td>";
        h += "</tr>";
        h += "<tr>";
        h += "  <th align='right'>&nbsp;</th>";
        h += "  <td><input type='button' value='Update' onclick='ajUpdateOff()' /></td>";
        h += "</tr>";
        h += "</table>";
        h += "<p><table border='0' width='80%'><tr><th>" + resp + "</th></tr></table>";
        document.getElementById("d_editoffice").innerHTML = h;
      }
    }
  }
  req.send(null);
}

function addMember()
{
  document.getElementById("d_addmember").style.display = "block";
  document.getElementById("d_editmember").style.display = "none";
  document.getElementById("d_editoffice").style.display = "none";
}

function editMember()
{
  document.getElementById("d_editmember").style.display = "block";
  document.getElementById("d_addmember").style.display = "none";
  document.getElementById("d_editoffice").style.display = "none";
}

function editOffice()
{
  document.getElementById("d_editoffice").style.display = "block";
  document.getElementById("d_editmember").style.display = "none";
  document.getElementById("d_addmember").style.display = "none";
}


