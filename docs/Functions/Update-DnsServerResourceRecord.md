---
external help file: PoshDnsTools-help.xml
Module Name: PoshDnsTools
online version: 
schema: 2.0.0
---

# Update-DnsServerResourceRecord

## SYNOPSIS
Updates a resource record in a DNS zone.

## SYNTAX

```
Update-DnsServerResourceRecord [-ZoneName] <String> [-Name] <String> [-IPAddress] <IPAddress>
 [-ComputerName <String>] [-CimSession <CimSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Update-DnsServerResourceRecord cmdlet changes a resource record in a DNS zone, and removes any incorrect records matching the name and ipaddress parameters.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Update-DnsServerResourceRecord -ZoneName "Contoso.com" -Name "Host01" -IPAddress "10.10.10.10"
```

This command will update / create the A record and PTR record for the host named Host01 with the specified IP address.

## PARAMETERS

### -ZoneName
Specifies the name of the DNS zone.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the name of a resource record object.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IPAddress
Specifies the IPv4 address of a host.

```yaml
Type: IPAddress
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ComputerName
Specifies a DNS server.
If you do not specify this parameter, the command runs on the local system.
You can specify an IP address or any value that resolves to an IP address, such as a fully qualified domain name (FQDN), host name, or NETBIOS name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CimSession
{{Fill CimSession Description}}

```yaml
Type: CimSession
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS

