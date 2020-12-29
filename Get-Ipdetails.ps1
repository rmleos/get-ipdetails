function Get-Ipdetails {
    param (
        [Parameter(
            Position=0,
            HelpMessage="Full Path to the CSV file that will be used.",
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$true)]
            [string[]]$CSVPath,
          [Parameter(
            Position=1,
            HelpMessage="The Column Name that contain the IPs for the detailed up.",
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$true)]
            [string[]]$IPColumnName,
        [Parameter(
            Position=2,
            HelpMessage="Full path to export IP details to.",
            ValueFromPipelineByPropertyName=$true)]
            [string]$CSVExportPath,
        [Parameter(
            Position=3,
            HelpMessage="Use to cobine ip details with the data of the CSV file.",
            ValueFromPipelineByPropertyName=$true)]
            [string[]]$SecondaryDNSLookupServer,
        [Parameter(
            Position=4,
            HelpMessage="Use to cobine ip details with the data of the CSV file.",
            ValueFromPipelineByPropertyName=$true)]
            [switch]$ADcomputerLookup,
        [Parameter(
            Position=5,
            HelpMessage="Use to cobine ip details with the data of the CSV file.",
            ValueFromPipelineByPropertyName=$true)]
            [string[]]$ADServer
    
    )
    $file = Import-Csv $CSVPath
    #Array to imput all IP data
    $collection = @()
    foreach ($lookupitem in $file) {
        #Get IP item for lookup
        $IP = $lookupitem.$IPColumnName
        #Start build of psobject for all data
        $filecolumns = $file | Get-Member -MemberType NoteProperty| Select-Object  Name
        $object = New-Object PSObject
        #Creates a new column for each column in original csv to object and add its data to it
        foreach ($column in $filecolumns)
        {
        $object | Add-Member -MemberType NoteProperty -Name $column.Name -Value $lookupitem.($column.Name)
        }

        #Preform DNS lookup
        $lookup = Resolve-DnsName $IP
        #Gets column names
        $lookupcolumns = $lookup | Select-Object Name,NameHost,Section,Type,TTL | Get-Member -MemberType NoteProperty | Select-Object Name
        #Adds columns and data to array
        foreach ($column in $lookupcolumns)
        {
            $object | Add-Member -MemberType NoteProperty -Name ("DNS"+($column.Name)) -Value $lookup.($column.Name)
        }

        #Checks for Secondary DNS Lookup
        if ($SecondaryDNSLookupServer) {
            $secondarylookup = Resolve-DnsName $IP -Server $SecondaryDNSLookupServer
            #Gets column names
            $secondarylookupcolumns = $secondarylookup | Select-Object Name,NameHost,Section,Type,TTL | Get-Member -MemberType NoteProperty | Select-Object Name
            #Adds columns and data to array
            foreach ($column in $secondarylookupcolumns)
            {
                $object | Add-Member -MemberType NoteProperty -Name ("SecondaryDNS"+($column.Name)) -Value $secondarylookup.($column.Name)
            }

        }

        #Check for AD computer lookup
        if ($ADcomputerLookup) {
            Import-Module ActiveDirectory
            #Get list of domains in forest
            $domains = (Get-ADForest).domains
            $pos = $lookup.NameHost.IndexOf(".")
            $domainpart = $lookup.NameHost.Substring($pos+1)
            if ($domains -contains $domainpart)
            {
                $adlookup = Get-ADComputer -Filter ("DNSHostName -like "+'"'+($lookup.NameHost)+'"') -Server $domainpart
                #Gets column names
                $adlookupcolumns = $adlookup | Select-Object DistinguishedName,DNSHostName,Enabled,IPv4Address,Name,ObjectGUID,SamAccountName,SID | Get-Member -MemberType NoteProperty | Select-Object Name
                #Adds columns and data to array
                foreach ($column in $adlookupcolumns)
                {
                    $object | Add-Member -MemberType NoteProperty -Name ("ADComputer"+($column.Name)) -Value $adlookup.($column.Name)
                }
            }
        }
        #Adds IP data to collection array
        $collection += $object
    }
    if ($CSVExportPath)
    {
        $collection | Export-Csv -Path $CSVExportPath
    }
    else
    {
        $collection
    }
}