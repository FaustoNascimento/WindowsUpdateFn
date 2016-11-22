function Invoke-WindowsUpdateListener
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Guid]
        $PipeName
    )

    Begin
    {
        function OutNamedPipe
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory, ValueFromPipeline)]
                [string] 
                $Message
            )

            Process
            {
                $pipeWriter.WriteLine($Message)
            }
        }
    }
    Process
    {
        try
        {
            # Kill the scheduled task, don't need it anymore...
            Unregister-ScheduledTask -TaskName "WindowsUpdateListener - $PipeName" -Confirm:$false
            
            # Create the pipe and connect
            $clientPipe = New-Object System.IO.Pipes.NamedPipeClientStream($PipeName)
            $clientPipe.Connect()

            # Create the streamWriter and streamReader objects
            $pipeReader = New-Object System.IO.StreamReader($clientPipe)
            $pipeWriter = New-Object System.IO.StreamWriter($clientPipe)
            $pipeWriter.AutoFlush = $true

            # Signal to the server that we're ready to work
            $pipeWriter.WriteLine('ReadyForWork')

            # Wait for the server to reply, telling us initiatization is also done on his side and he got our previous message
            $message = $pipeReader.ReadLine()
            
            if ($message -ne 'WaitInstructions')
            {
                # You were supposed to reply with WaitInstructions
                # You haven't, so I can't trust you, goodbye
                $clientPipe.Close()
                return
            }

            # We're now waiting for the server to send us further instructions. This could be a while...
            while ($true)
            {
                $message = $pipeReader.ReadLine()

                switch ($message)
                {
                    'CloseShop' 
                    {
                        $clientPipe.Close()
                        return 
                    }
                    'Enable-WUA' 
                    {
                        Enable-WUA | OutNamedPipe
                        OutNamedPipe -Message 'MessageComplete'
                    }
                    default
                    {
                        OutNamedPipe -Message 'UnknownCommand'
                        OutNamedPipe -Message 'MessageComplete'
                    }
                }
            }
        }
        catch
        {
            OutNamedPipe -Message $_
        }
    }
}