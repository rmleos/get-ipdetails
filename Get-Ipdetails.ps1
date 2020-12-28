function Get-Ipdetails {
    param (
        [Parameter(
            Position=0,
            HelpMessage="Path to the CSV file that will be used.",
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$true)]
            [string[]]$CSVPath,
          [Parameter(
            Position=0,
            HelpMessage="The Column Name that contain the IPs for the detailed up.",
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$true)]
            [string[]]$IPColumnName,
        [Parameter(
            Position=0,
            HelpMessage="Use to cobine ip details with the data of the CSV file.",
            ValueFromPipelineByPropertyName=$true)]
            [switch[]]$CombineResults,
        [Parameter(
            Position=0,
            HelpMessage="Use to cobine ip details with the data of the CSV file.",
            ValueFromPipelineByPropertyName=$true)]
            [string[]]$SecondaryDNSLookupServer,
        [Parameter(
            Position=0,
            HelpMessage="Use to cobine ip details with the data of the CSV file.",
            ValueFromPipelineByPropertyName=$true)]
            [switch[]]$ADcomputerLookup
    )
    $file = Import-Csv $CSVPath


}

Get-Ipdetails
Import-Csv