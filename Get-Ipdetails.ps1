function Get-Ipdetails {
    param (
        [Parameter(
            Position=0,
            HelpMessage="Path to the CSV file that will be used.",
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
            HelpMessage="Use to cobine ip details with the data of the CSV file.",
            ValueFromPipelineByPropertyName=$true)]
            [switch]$CombineResults,
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
    $collection = @()
    foreach ($lookupitem in $file) {
        $IP = $lookupitem.$IPColumnName
        $lookup = Resolve-DnsName $IP
        if ($SecondaryDNSLookupServer) {
            $secondarylookup = Resolve-DnsName $lookupitem.$IPColumnName -Server $SecondaryDNSLookupServer
        }
        if ($ADcomputerLookup) {
            Import-Module ActiveDirectory
            $adlookup = Get-ADComputer -Properties IPv4Address -Filter {IPv4Address -eq $IP}
        }

    }

}
