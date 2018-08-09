Microsoft.PowerShell.Utility\Import-LocalizedData LocalizedData -FileName DnsServerHelper.Resources.psd1

if (!$PSScriptRoot) {
    $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
}

#region Load Public Functions
$PublicFunctions = @()
Get-ChildItem "$PSScriptRoot\Public" -Filter *.ps1 -Recurse | Select-Object -ExpandProperty FullName | ForEach-Object {
    $FunctionName = Split-Path -Path $_ -Leaf
    try {
        Write-Verbose -Message ("Importing public function {0}" -f $_.BaseName)
        . $_
    }
    catch {
        Write-Warning -Message ("{0}: {1}" -f $FunctionName, $_.Exception.Message)
    }
}
#endregion

#region Load Public Functions
Get-ChildItem "$PSScriptRoot\Private" -Filter *.ps1 -Recurse | Select-Object -ExpandProperty FullName | ForEach-Object {
    $FunctionName = Split-Path -Path $_ -Leaf
    try {
        Write-Verbose -Message ("Importing private function {0}" -f $_.BaseName)
        . $_
    }
    catch {
        Write-Warning -Message ("{0}: {1}" -f $FunctionName, $_.Exception.Message)
    }
}
#endregion
