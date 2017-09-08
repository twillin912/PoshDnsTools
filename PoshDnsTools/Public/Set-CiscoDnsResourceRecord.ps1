function Set-CiscoDnsResourceRecord {
    <#
    .SYNOPSIS
    Updates a resource record for Cisco device in a DNS zone.

    .DESCRIPTION
    The Set-CiscoDnsResourceRecord cmdlet changes resource records in a DNS zone associated with the interfaces for the specified Cisco device.

    .PARAMETER ZoneName
    Specifies the name of the DNS zone.

    .PARAMETER ConnectionString
    Specifies the connection string to use with the SSH command.

    .PARAMETER Name
    Specifies the hostname of the device.

    .PARAMETER ComputerName
    Specifies a DNS server. If you do not specify this parameter, the command runs on the local system. You can specify an IP address or any value that resolves to an IP address, such as a fully qualified domain name (FQDN), host name, or NETBIOS name.

    .EXAMPLE
    Example 1

    .NOTES
    General notes
    #>
    #[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory,
            Position = 1,
            ValueFromPipelineByPropertyName)]
        [string] $ZoneName,

        [Parameter(Mandatory,
            Position = 2,
            ValueFromPipelineByPropertyName)]
        [string] $ConnectionString,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [string] $ComputerName,

        [Parameter()]
        [CimSession] $CimSession
    )

    begin {
        $StringReplacement = @{
            'FastEthernet'       = 'fa'
            'GigabitEthernet'    = 'gi'
            'Loopback'           = 'lo'
            'TenGigabitEthernet' = 'te'
            'Tunnel'             = 'tun'
            'Vlan'               = 'vl'
            '/'                  = '-'
        }

        if ( $ConnectionString -contains '@' -and !$Name ) {
            Write-Error -Message "Name must be specified when including username in the connection string."

        }

        $CimSessionParam = @{}
        if ( $DnsServer ) {
            $DnsServerCimSession = New-CimSession -ComputerName $ComputerName
            $CimSessionParam.Add('CimSession', $DnsServerCimSession)
        }
    }

    process {
        $RouterConfig = $(ssh $ConnectionString "show ip interface brief")
        $RouterConfig = $RouterConfig -split "`r`n"
        foreach ( $Line in $RouterConfig ) {
            $Line = $Line.ToLower().Split(' ', [StringSplitOptions]'RemoveEmptyEntries')
            if ( $Line[1] -ne 'unassigned' -and $Line[3] -match 'nvram|manual' ) {
                $InterfaceName = $($Line[0])
                [ipaddress]$IPAddress = $($Line[1])
                foreach ( $Value in $StringReplacement.GetEnumerator() ) {
                    $InterfaceName = $InterfaceName -replace $Value.Key, $Value.Value
                }
                $InterfaceName = $InterfaceName.Split('.')
                [array]::Reverse($InterfaceName)

                if ( $InterfaceName[0] -eq 'lo0' ) {
                    $InterfaceDns = "$($HostName)"
                }
                elseif ( ( $InterfaceName[0] -eq 'fa0' -or $InterfaceName[0] -eq 'gi0' -or $InterfaceName[0] -eq 'gi0-0' ) -and !$MgmtInterface ) {
                    $InterfaceDns = "$($HostName).oob"
                    $MgmtInterface = $true
                }
                elseif ( $InterfaceName[0] -match '^[0-9]+$' ) {
                    $InterfaceDns = "vl$($InterfaceName -join '.').$($HostName)"
                }
                else {
                    $InterfaceDns = "$($InterfaceName -join '.').$($HostName)"
                }

                Update-DnsServerResourceRecord -ZoneName $ZoneName -Name $InterfaceDns -IPAddress $IPAddress @CimSessionParam -Verbose:$VerbosePreference -WhatIf:$WhatIfPreference
            }
        }
    }

    end {
    }
}
