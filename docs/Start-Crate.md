---
external help file: Crate-help.xml
Module Name: Crate
online version: https://github.com/mchave3/Crate
schema: 2.0.0
---

# Start-Crate

## SYNOPSIS

Main entry point for the Crate Windows ISO provisioning tool.

## SYNTAX

```powershell
Start-Crate [[-WorkspacePath] <String>] [[-ConfigProfile] <String>] [-AutoMode]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Starts the Crate interactive CLI interface for mounting, provisioning, and dismounting
Windows ISO images with updates and language packs.
Provides a modern, intuitive
terminal-based experience for Windows system administrators.

## EXAMPLES

### EXAMPLE 1

```powershell
Start-Crate
Example of how to use this script/function
```

### EXAMPLE 2

```powershell
Start-Crate
Starts Crate with the interactive main menu.
```

### EXAMPLE 3

```powershell
Start-Crate -WorkspacePath "D:\CrateWorkspace"
Starts Crate with a custom workspace location.
```

### EXAMPLE 4

```powershell
Start-Crate -ConfigProfile "Windows11Updates" -AutoMode
Runs Crate in automated mode using the specified profile.
```

## PARAMETERS

### -WorkspacePath

Custom workspace path for Crate operations.
Defaults to C:\ProgramData\Crate.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\ProgramData\Crate
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigProfile

Name of the configuration profile to use.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoMode

Run in automated mode using the specified profile without interactive menus.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Name:        Start-Crate.ps1
Author:      Mickaël CHAVE
Created:     26/05/2025
Version:     25.5.26.1
Repository:  https://github.com/mchave3/Crate
License:     MIT License
Requires:    PowerShell 7.4+, Administrator privileges, Windows OS

## RELATED LINKS

[https://github.com/mchave3/Crate](https://github.com/mchave3/Crate)

[https://github.com/mchave3/Crate](https://github.com/mchave3/Crate)
