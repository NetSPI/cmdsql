###Scripting Information###
* Name: cmdsql.aspx
* Author: Antti Rantasaari, NetSPI - 2013
* Stylesheets: Scott Sutherland (@nullbind)
* Blog: https://blog.netspi.com/adding-powershell-to-web-shells-to-get-database-access/

###Description###

The cmdsql.aspx shell can be used for the following tasks.
* Execute operating system commands
* Parse web.config files for connection strings (based on root directory)
* Execute MSSQL queries using connection strings recovered from web.config files

###Notes###
* The command execution code is based on the old cmd.aspx from fuzzdb - http://code.google.com/p/fuzzdb/

###Screen Shots###
* Operating system command execution.   
![alt tag](https://blog.netspi.com/images/Antti_Powershell_Web_Config_Parsing.png)
* Parse web.config files.   
![alt tag](https://blog.netspi.com/images/Antti_Powershell_SQL_Query_Execution.png)
* Execute MSSQL queries using recovered connection strings.   
![alt tag](https://blog.netspi.com/images/Antti_Powershell_The_Code.png)



