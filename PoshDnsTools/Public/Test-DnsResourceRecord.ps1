function Test-DnsResourceRecord {
    param (
        # Specifies the name of the resource record to query for
        [parameter(Mandatory=$true)]
        [string] $Name
    )

    begin {
        $DnsServers = @('ns1.voyagerlearning.com', 'ns2.voyagerlearning.com', 'ns3.voyagerlearning.com', 'ns4.voyagerlearning.com', 'google-public-dns-a.google.com')
    }

    process {
        foreach ($Server in $DnsServers) {
            $OutputObject = New-Object -TypeName PSObject
            $OutputObject.PSObject.TypeNames.Insert(0,'PoshDnsTools.DnsResourceRecord')
            $OutputObject | Add-Member -MemberType NoteProperty -Name 'Server' -Value $Server
            $OutputObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value $Name

            try {
                $Result = Resolve-DnsName -Name $Name -Server $Server -DnsOnly -ErrorAction Stop
                $Answer = $Result | Where-Object { $_.Section -match 'Answer'}
                $OutputObject | Add-Member -MemberType NoteProperty -Name 'IPAddress' -Value $Answer.IPAddress
                $OutputObject | Add-Member -MemberType NoteProperty -Name 'TTL' -Value $Answer.TTL
            }
            catch {
                $OutputObject | Add-Member -MemberType NoteProperty -Name 'IPAddress' -Value 'Not Found'
                $OutputObject | Add-Member -MemberType NoteProperty -Name 'TTL' -Value ''
            }

            $OutputObject
        }
    }

}

Test-DnsResourceRecord -Name vpn.cho
