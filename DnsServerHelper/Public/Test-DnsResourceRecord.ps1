function Test-DnsResourceRecord {
    param (
        # Specifies the name of the resource record to query for
        [parameter(Mandatory = $true)]
        [string] $Name,

        [switch] $New
    )

    begin {
        if ($New) {
            $DnsServers = @('txnsm01.clg.local', 'minsm01.clg.local', 'txnss01.clg.local', 'txlaznss01.clg.local', 'minss01.clg.local', 'milaznss01.clg.local', 'google-public-dns-a.google.com')
        }
        else {
            $DnsServers = @('ns1.voyagerlearning.com', 'ns2.voyagerlearning.com', 'ns3.voyagerlearning.com', 'ns4.voyagerlearning.com', 'google-public-dns-a.google.com')
        }
    }

    process {
        foreach ($Server in $DnsServers) {
            $OutputObject = [pscustomobject] @{
                'Server' = $Server
                'Name'   = $Name
                'Answer' = ''
                'TTL'    = ''
            }

            if (!(Test-Connection -ComputerName $Server -Count 1 -Quiet)) {
                $OutputObject.Answer = 'DNS Server Unreachable'
            }

            try {
                $Result = Resolve-DnsName -Name $Name -Server $Server -DnsOnly -ErrorAction Stop
                $Answer = $Result | Where-Object { $_.Section -match 'Answer'}
                switch ($Answer.Type) {
                    CNAME {
                        $OutputObject.Answer = $Answer.NameHost
                    }
                    Default {
                        $OutputObject.Answer = $Answer.IPAddress
                    }
                }
                $OutputObject.TTL = $Answer.TTL
            }
            catch [System.Net.Sockets.SocketException], [System.ComponentModel.Win32Exception] {
                $OutputObject.Answer = 'Not Found'
                $OutputObject.TTL = ''
            }
            catch {
                Write-Error -Message $_.Exception.GetType()
            }

            $OutputObject.PSObject.TypeNames.Insert(0, 'DnsServerHelper.DnsResourceRecord')
            Write-Output -InputObject $OutputObject
        }
    }

}
