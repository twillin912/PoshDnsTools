function Update-DnsServerResourceRecord {
    <#
    .SYNOPSIS
    Updates a resource record in a DNS zone.

    .DESCRIPTION
    The Update-DnsServerResourceRecord cmdlet changes a resource record in a DNS zone, and removes any incorrect records matching the name and ipaddress parameters.

    .PARAMETER ZoneName
    Specifies the name of the DNS zone.

    .PARAMETER Name
    Specifies the name of a resource record object.

    .PARAMETER IPAddress
    Specifies the IPv4 address of a host.

    .PARAMETER ComputerName
    Specifies a DNS server. If you do not specify this parameter, the command runs on the local system. You can specify an IP address or any value that resolves to an IP address, such as a fully qualified domain name (FQDN), host name, or NETBIOS name.

    .EXAMPLE
    Update-DnsServerResourceRecord -ZoneName "Contoso.com" -Name "Host01" -IPAddress "10.10.10.10"
    This command will update / create the A record and PTR record for the host named Host01 with the specified IP address.

    .NOTES
    General notes
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory,
            Position = 1,
            ValueFromPipelineByPropertyName)]
        [string] $ZoneName,

        [Parameter(Mandatory,
            Position = 2,
            ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter(Mandatory,
            Position = 3,
            ValueFromPipelineByPropertyName)]
        [ipaddress] $IPAddress,

        [Parameter()]
        [string] $ComputerName,

        [Parameter()]
        [CimSession] $CimSession
    )

    begin {
        if ( !$CimSession ) {
            $CimSession = New-CimSession -ComputerName $ComputerName
        }

        $GetParams = @{
            #'ComputerName' = $ComputerName
            'CimSession'  = $CimSession
            'ErrorAction' = 'SilentlyContinue'
        }

        $SetParams = @{
            #'ComputerName' = $ComputerName
            'CimSession'  = $CimSession
            'ErrorAction' = 'Stop'
        }

    } # begin

    process {
        $AddressBtyes = $IPAddress.GetAddressBytes()
        $PtrZone = Get-DnsServerZone -Name "$($AddressBtyes[2]).$($AddressBtyes[1]).$($AddressBtyes[0]).in-addr.arpa" @GetParams
        $PtrRecordBtyes = 1
        if ( !$PtrZone ) {
            $PtrZone = Get-DnsServerZone -Name "$($AddressBtyes[1]).$($AddressBtyes[0]).in-addr.arpa" @GetParams
            $PtrRecordBtyes = 2
        }
        if ( !$PtrZone ) {
            $PtrZone = Get-DnsServerZone -Name "$($AddressBtyes[0]).in-addr.arpa" @GetParams
            $PtrRecordBtyes = 3
        }
        if ( !$PtrZone ) {
            Write-Warning -Message "No PTR zone found for address '$IPAddress'."
            $DisablePtr = $true
        }

        $ForwardRecord = Get-DnsServerResourceRecord -ZoneName $ZoneName -Name $Name -RRType A @GetParams | Where-Object { $_.HostName -eq $Name }
        if ( $ForwardRecord ) {
            foreach ( $Record in $ForwardRecord ) {
                if ( $Record.RecordData.IPv4Address -ne $IPAddress ) {
                    if ( $PSCmdlet.ShouldProcess("Name: $($Record.HostName), Address: $($Record.RecordData.IPv4Address)", 'Remove A record.') ) {
                        Remove-DnsServerResourceRecord -ZoneName $ZoneName -InputObject $Record @SetParams
                    }
                }
                else {
                    Write-Verbose -Message "An 'A' record for '$($Record.HostName)' with address '$($Record.RecordData.IPv4Address)' already exists."
                    $ForwardExists = $true
                }
            } # foreach
        } # if ForwardRecord

        if ( !$ForwardExists ) {
            if ( $PSCmdlet.ShouldProcess("Zone: $ZoneName, Name: $Name, Address: $IPAddress", 'Create A record.') ) {
                Add-DnsServerResourceRecord -ZoneName $ZoneName -A -Name $Name -IPv4Address $IPAddress @SetParams
            }
        } # if ForwardExists

        if ( !$DisablePtr ) {
            $PtrZoneName = $PtrZone.ZoneName
            Write-Debug -Message "PTR zone name: $PtrZoneName"
            $PtrRecord = @()
            for ( $i = 0; $i -lt $PtrRecordBtyes; $i ++ ) {
                $PtrRecord += $AddressBtyes[3 - $i]
            }
            $PtrRecordName = $PtrRecord -join '.'
            Write-Debug -Message "PTR record name: $PtrRecordName"
            $ReverseRecordByIp = Get-DnsServerResourceRecord -ZoneName $PtrZoneName -RRType Ptr -Name $PtrRecordName @GetParams
            if ( $ReverseRecordByIp ) {
                foreach ( $Record in $ReverseRecordByIp ) {
                    if ( $Record.RecordData.PtrDomainName -ne "$Name.$ZoneName." ) {
                        if ( $PSCmdlet.ShouldProcess("Zone: $PtrZoneName, Record: $($Record.HostName), PtrDomainName: $($Record.RecordData.PtrDomainName)", 'Remove PTR record.') ) {
                            Remove-DnsServerResourceRecord -ZoneName $PtrZoneName -InputObject $Record -Force @SetParams
                        }
                    }
                    else {
                        Write-Verbose -Message "A 'PTR' record for '$($Record.HostName)' with IP address '$($Record.RecordData.PtrDomainName)' already exists."
                        $ReverseExists = $true
                    }
                } # foreach
            } # if ReverseRecordByIp

            $ReverseRecordByName = Get-DnsServerResourceRecord -ZoneName $PtrZoneName -RRType Ptr @GetParams | Where-Object { $_.RecordData.PtrDomainName -match "^$($Name)\."}
            if ( $ReverseRecordByName ) {
                foreach ( $Record in $ForwardRecords ) {
                    if ( $Record.RecordData.PtrDomainName -ne "$Name.$ZoneName." ) {
                        if ( $PSCmdlet.ShouldProcess("Zone: $PtrZoneName, Record: $($Record.HostName), PtrDomainName: $($Record.RecordData.PtrDomainName)", 'Remove PTR record.') ) {
                            Remove-DnsServerResourceRecord -ZoneName $PtrZoneName -InputObject $Record -Force @SetParams
                        }
                    }
                    else {
                        Write-Verbose -Message "PTR record for '$($Record.HostName)' with record date '$($Record.RecordData.PtrDomainName)' already exists."
                        $ReverseExists = $true
                    }
                } # foreach
            } # if ReverseRecordByName

            if ( !$ReverseExists ) {
                if ( $PSCmdlet.ShouldProcess("Zone: $PtrZoneName, Name: $PtrRecordName, PtrDomain: $Name.$ZoneName.", 'Create PTR record.') ) {
                    Add-DnsServerResourceRecord -ZoneName "$PtrZoneName" -Name "$PtrRecordName" -Ptr -PtrDomainName "$Name.$ZoneName." @SetParams
                }
            } # if ReverseExists
        } # if DisablePtr
    } # process

    end {
    } # end
}
