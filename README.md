### Scripting Information
* Name: cmdsql.aspx
* Author: Antti Rantasaari, NetSPI - 2013
* Stylesheets: Scott Sutherland (@nullbind)
* Blog: https://blog.netspi.com/adding-powershell-to-web-shells-to-get-database-access/

### Description

cmdsql.aspx is a webshell that can be used for the following tasks:
* Execute operating system commands
* Parse web.config files for connection strings (based on root directory)
* Execute MSSQL queries using connection strings recovered from web.config files

### IP Address Filter
The webshell reads the IP address of the remote host for each incoming request and compares it to a hardcoded list of allowed IPs in order to determine whether or not the request should be processed. By default, all IP addresses are allowed access to the webshell. To restrict access, modify the appropriate line in cmdsql.aspx before deployment by referring to the examples below:
* Allow all IP addresses:  
`Dim strAllowedIPs As String = "*"`
* Only allow a specific IP address:  
`Dim strAllowedIPs As String = "10.1.1.100"`
* Only allow a specific set of IP addresses (use a comma-separated list when entering multiple IPs):  
`Dim strAllowedIPs As String = "127.0.0.1,192.168.1.100,10.1.1.100"`

### Notes
* The command execution code is based on the old cmd.aspx from fuzzdb - http://code.google.com/p/fuzzdb/

### Screen Shots
* Operating system command execution.  
![alt tag](https://blog.netspi.com/wp-content/uploads/2013/04/Antti_Powershell_Web_Config_Parsing.png)
* Parse web.config files.  
![alt tag](https://blog.netspi.com/wp-content/uploads/2013/04/Antti_Powershell_SQL_Query_Execution.png)
* Execute MSSQL queries using recovered connection strings.  
![alt tag](https://blog.netspi.com/wp-content/uploads/2013/04/Antti_Powershell_The_Code.png)



