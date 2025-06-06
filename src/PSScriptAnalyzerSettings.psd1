#Documentation: https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/Cmdlets/Invoke-ScriptAnalyzer.md#-settings
@{
    #CustomRulePath='path\to\CustomRuleModule.psm1'
    #RecurseCustomRulePath='path\of\customrules'
    Severity = @('Error','Warning')
    #IncludeDefaultRules=${true}
    ExcludeRules = @(
        'PSMissingModuleManifestField',
        'PSAvoidUsingWriteHost',
        'PSAvoidUsingInvokeExpression',
        'PSUseToExportFieldsInManifest',
        'PSReviewUnusedParameter',
        'PSAvoidAssignmentToAutomaticVariable',
        'PSUseBOMForUnicodeEncodedFile'
    )
    #IncludeRules = @(
    #    'PSAvoidUsingWriteHost',
    #    'MyCustomRuleName'
    #)
}