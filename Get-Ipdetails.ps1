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
    $collection=@([pscustomobject]@{IP='';Port='';Protocol='';Status='';DNSName='';DNSNameHost='';DNSSection='';DNSTTL='';DNSType='';SecondaryDNSName='';SecondaryDNSNameHost='';SecondaryDNSSection='';SecondaryDNSTTL='';SecondaryDNSType='';ADComputerDistinguishedName='';ADComputerDNSHostName='';ADComputerEnabled='';ADComputerIPv4Address='';ADComputerName='';ADComputerObjectGUID='';ADComputerSamAccountName='';ADComputerSID=''})
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
        $lookup = Resolve-DnsName $IP -ErrorAction SilentlyContinue
        #Check if DNS lookup returned data
        if (!!$lookup)
        {
            #Gets column names
            $lookupcolumns = $lookup[0] | Select-Object Name,NameHost,Section,Type,TTL | Get-Member -MemberType NoteProperty | Select-Object Name
            #Adds columns and data to array
            foreach ($column in $lookupcolumns)
            {
                $object | Add-Member -MemberType NoteProperty -Name ("DNS"+($column.Name)) -Value $lookup[0].($column.Name)
            }
        }
        #Checks for Secondary DNS Lookup
        if ($SecondaryDNSLookupServer) {
            $secondarylookup = Resolve-DnsName $IP -Server $SecondaryDNSLookupServer -ErrorAction SilentlyContinue
                #Check if Secondary DNS lookup returned data
                if (!!$secondarylookup)
                {
                    #Gets column names
                    $secondarylookupcolumns = $secondarylookup[0] | Select-Object Name,NameHost,Section,Type,TTL | Get-Member -MemberType NoteProperty | Select-Object Name
                    #Adds columns and data to array
                    foreach ($column in $secondarylookupcolumns)
                    {
                        $object | Add-Member -MemberType NoteProperty -Name ("SecondaryDNS"+($column.Name)) -Value $secondarylookup[0].($column.Name)
                    }
                }
        }
        #Check for AD computer if DNS lookup returned data
        if ($ADcomputerLookup) {
            Import-Module ActiveDirectory
            #Get list of domains in forest
            $domains = (Get-ADForest).domains
            if (!!$lookup)
            {
            $pos = $lookup[0].NameHost.IndexOf(".")
            $domainpart = $lookup[0].NameHost.Substring($pos+1)
            }
            #Check client host part against AD domains and will do direct domain lookup 
            if ($domains -contains $domainpart)
            {
                $adlookup = Get-ADComputer -Filter {IPv4Address -eq $IP} -Server $domainpart
                #Gets column names
                $adlookupcolumns = $adlookup | Select-Object DistinguishedName,DNSHostName,Enabled,IPv4Address,Name,ObjectGUID,SamAccountName,SID | Get-Member -MemberType NoteProperty | Select-Object Name
                #Adds columns and data to array
                foreach ($column in $adlookupcolumns)
                {
                    $object | Add-Member -MemberType NoteProperty -Name ("ADComputer"+($column.Name)) -Value $adlookup.($column.Name)
                }
            }
            else
            {
               #Will try looking up IP in each AD domain
               foreach ($domain in $domains)
               {
                   $adlookup = Get-ADComputer -Filter {IPv4Address -eq $IP} -Server $domain -ErrorAction SilentlyContinue
                   #Adds columns and data to array
                    if (!!$adlookup)
                    {                   
                       #Gets column names
                       $adlookupcolumns = $adlookup | Select-Object DistinguishedName,DNSHostName,Enabled,IPv4Address,Name,ObjectGUID,SamAccountName,SID | Get-Member -MemberType NoteProperty | Select-Object Name
                       foreach ($column in $adlookupcolumns)
                       {
                           $object | Add-Member -MemberType NoteProperty -Name ("ADComputer"+($column.Name)) -Value $adlookup.($column.Name)
                       }
                    }
               } 
            }
        }
        #Adds IP data to collection array
        $collection += $object
    }
    
    #Export results 
    if ($CSVExportPath)
    {
        $collection | Export-Csv -Path $CSVExportPath -NoTypeInformation
    }
    else
    {
        $collection
    }
}