---
external help file: Crate-help.xml
Module Name: Crate
online version: https://github.com/mchave3/Crate
schema: 2.0.0
---

# Start-Crate

## SYNOPSIS

Starts the Crate provisioning tool in a new PowerShell window.

## SYNTAX

```powershell
Start-Crate [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This script launches the Crate provisioning tool in a new PowerShell window with
a specified console mode for better visibility.
It imports the Crate module and
starts the interactive CLI interface.
The function performs several validation checks:
- Administrator privileges verification
- PowerShell version compatibility (7+)
- Console size optimization (100x50)

## EXAMPLES

### EXAMPLE 1

```powershell
Start-Crate
Starts the Crate provisioning tool with automatic environment optimization.
```

## PARAMETERS

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Name:        Start-Crate.ps1
Author:      Mickaël CHAVE
Created:     26/05/2025
Version:     25.5.28.1
Repository:  https://github.com/mchave3/Crate
License:     MIT License

## RELATED LINKS

[https://github.com/mchave3/Crate](https://github.com/mchave3/Crate)
