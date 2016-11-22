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
        'Starting Enable WUA'
        if ($Session)
        {
            Invoke-NamedPipeCommand -Session $Session -Command 'Enable-WUA'
        }
        else 
        {
            $autoUpdate = New-Object -ComObject Microsoft.Update.AutoUpdate
            $autoUpdate.EnableService()
            $autoUpdate
        }
    }    
}