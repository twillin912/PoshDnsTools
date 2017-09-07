function Update-DnsServerResourceRecord {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [string] $ZoneName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [string] $Name,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [ipaddress] $IPAddress,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [string] $DnsServer
    )

    begin {
        $GetParams = @{
            'ComputerName' = $DnsServer
            'ErrorAction'  = 'SilentlyContinue'
        }

        $SetParams = @{
            'ComputerName' = $DnsServer
            'ErrorAction'  = 'Stop'
            'Force'        = $true
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
                        Remove-DnsServerResourceRecord -ZoneName $ZoneName -InputObject $ForwardRecord @SetParams
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
                Add-DnsServerResourceRecord $DnsServer -ZoneName $ZoneName -A -Name $Name -IPv4Address $IPAddress @SetParams
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
                        if ( $PSCmdlet.ShouldProcess($ReverseRecordByIp.Hostname, 'Remove PTR record.') ) {
                            Remove-DnsServerResourceRecord -ZoneName $PtrZoneName -InputObject $ReverseRecordByIp  @SetParams
                        }
                    }
                    else {
                        Write-Verbose -Message "A 'PTR' record for '$($Record.HostName)' with address '$($Record.RecordData.PtrDomainName)' already exists."
                        $ReverseExists = $true
                    }
                } # foreach
            } # if ReverseRecordByIp

            $ReverseRecordByName = Get-DnsServerResourceRecord -ZoneName $PtrZoneName -RRType Ptr @GetParams | Where-Object { $_.RecordData.PtrDomainName -match "^$($Name)\."}
            if ( $ReverseRecordByName ) {
                foreach ( $Record in $ForwardRecords ) {
                    if ( $Record.RecordData.PtrDomainName -ne "$Name.$ZoneName." ) {
                        if ( $PSCmdlet.ShouldProcess($ReverseRecordByName.HostName, 'Remove PTR record.') ) {
                            Remove-DnsServerResourceRecord -ZoneName $PtrZoneName -InputObject $ReverseRecordByName  @SetParams
                        }
                    }
                    else {
                        Write-Verbose -Message "PTR record for '$($Record.HostName)' with address '$($Record.RecordData.PtrDomainName)' already exists."
                        $ReverseExists = $true
                    }
                } # foreach
            } # if ReverseRecordByName

            if ( !$ReverseExists -and $($IPAddress.GetAddressBytes()[0]) -in @('10', '172', '192') ) {
                if ( $PSCmdlet.ShouldProcess("Zone: $PtrZoneName, Name: $PtrRecordName, Address: $Name.$ZoneName.", 'Create PTR record.') ) {
                    Add-DnsServerResourceRecord -ZoneName $PtrZoneName -Name $PtrRecordName -Ptr -PtrDomainName "$Name.$ZoneName." @SetParams
                }
            } # if ReverseExists
        } # if DisablePtr
    } # process

    end {
    } # end
}
