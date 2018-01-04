---
external help file: PoshDnsTools-help.xml
Module Name: PoshDnsTools
online version:
schema: 2.0.0
---

# Set-CiscoDnsResourceRecord

## SYNOPSIS
Updates a resource record for Cisco device in a DNS zone.

## SYNTAX

```
Set-CiscoDnsResourceRecord [-ZoneName] <String> [-ConnectionString] <String> [-Name <String>]
 [-ComputerName <String>] [-CimSession <CimSession>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-CiscoDnsResourceRecord cmdlet changes resource records in a DNS zone associated with the interfaces for the specified Cisco device.

## EXAMPLES

### EXAMPLE 1
```
Example 1
```

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

### -ConnectionString
Specifies the connection string to use with the SSH command.

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

### -Name
Specifies the hostname of the device.

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

\[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess")\]

## RELATED LINKS
