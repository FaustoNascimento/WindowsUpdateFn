function Invoke-NamedPipeCommand
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.Runspaces.PSSession]
        $Session,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        $Command,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Switch]
        $KeepAlive
    )

    Process
    {
        try
        {
            #Invoke-Command -ScriptBlock `
            #{
                if (-not $serverPipe)
                {
                    Import-Module WindowsUpdateFn
                    $serverPipe = Start-NamedPipe
                }

                $serverPipe.StreamWriter.WriteLine($Command)
                
                while ($true)
                {
                    $message = $serverPipe.StreamReader.ReadLine()

                    if ($message -eq 'MessageComplete')
                    {
                        break
                    }

                    $message
                }

                if (-not $KeepAlive)
                {
                    # Tell the client to close down
                    $serverPipe.StreamWriter.WriteLine('CloseShop')
                    $serverPipe = $null
                }
            #} -Session $Session
        }
        catch [System.ObjectDisposedException]
        {
            throw "Pipe was already closed"
        }
    }
}