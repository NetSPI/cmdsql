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
