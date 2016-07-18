function Enable-WUA
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [System.Management.Automation.Runspaces.PSSession]
        $Session
    )
    Process
    {

    }    
}

function Test-IsAdmin
{
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

function New-ErrorRecord
{
    [CmdletBinding(DefaultParameterSetName = 'ErrorMessageSet')]
    param
    (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'ErrorMessageSet')]
        [String]$ErrorMessage,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'ExceptionSet')]
        [System.Exception]$Exception,

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 1)]
        [System.Management.Automation.ErrorCategory]$ErrorCategory = [System.Management.Automation.ErrorCategory]::NotSpecified,

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 2)]
        [String]$ErrorId,

        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 3)]
        [Object]$TargetObject
    )
    
    Process
    {
        if (!$Exception)
        {
            $Exception = New-Object System.Exception $ErrorMessage
        }
    
        New-Object System.Management.Automation.ErrorRecord $Exception, $ErrorId, $ErrorCategory, $TargetObject
    }
}