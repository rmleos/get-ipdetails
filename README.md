# get-ipdetails

|Parameter                  |Description                                                                                                                 
|---------------------------|--------------------------------------------------------------------------------------------------------------------|
|-CSVPath                   |Full file path of the CSV file to import.
|-IPColumnName              |The column name that contains the IP that will be used to preform the lookups in the detailed report.
|-SecondaryDNSLookupServer  |The IP of a secondary DNS server to preform DNS lookup that is not using local DNS.
|-CSVExportPath             |The full path to export the IP detial results.
|-ADcomputerLookup          |Select to preform lookup of IP in Active Directory. Local computer must be domain joined and have Active Directory 
module installed.

## Command Example:

Get-Ipdetails -CSVPath C:\Users\username\Documents\AllOpenIPs.csv -IPColumnName IP -ADcomputerLookup -SecondaryDNSLookupServer 1.1.1.1  -CSVExportPath C:\Users\username\Documents\AllOpenIP_DetailedReport.csv