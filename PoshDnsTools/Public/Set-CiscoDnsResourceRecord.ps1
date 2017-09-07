function Set-CiscoDnsResourceRecord {
    #[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory)]
        [string[]] $Identity,

        [Parameter(Mandatory)]
        [string] $ZoneName,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [string] $DnsServer
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

        if ( $Identity.Length -eq 1 -and $Name ) {
            Write-Warning -Message ''
            break
        }

        $DnsServerParam = @{}
        if ( $DnsServer ) { $DnsServerParam.Add('DnsServer', $DnsServer) }
    }

    process {
        foreach ( $Device in $Identity ) {
            if ( !$Name ) { $HostName = $Device } else { $HostName = $Name }
            $RouterConfig = $(ssh $Device "show ip interface brief")
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
                    elseif ( $InterfaceName[0] -eq 'gi0-0' -or $InterfaceName[0] -eq 'fa0' ) {
                        $InterfaceDns = "$($HostName).oob"
                    }
                    elseif ( $InterfaceName[0] -match '^[0-9]+$' ) {
                        $InterfaceDns = "vl$($InterfaceName -join '.').$($HostName)"
                    }
                    else {
                        $InterfaceDns = "$($InterfaceName -join '.').$($HostName)"
                    }

                    Update-DnsServerResourceRecord -ZoneName $ZoneName -Name $InterfaceDns -IPAddress $IPAddress @DnsServerParam -WhatIf:$WhatIfPreference
                }
            }
        }
    }

    end {
    }
}
