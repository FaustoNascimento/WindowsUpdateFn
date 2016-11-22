function Start-NamedPipe
{
    [CmdletBinding()]
    param
    (        
    )

    Process
    {
        # Named pipe name
        $pipeName = [System.Guid]::NewGuid()
        
        # Create the scheduled task 
        $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass Invoke-WindowsUpdateListener -PipeName $pipeName"
        $settings = New-ScheduledTaskSettingsSet -Hidden
        Register-ScheduledTask -Action $action -Settings $settings -TaskName "WindowsUpdateListener - $pipeName" -RunLevel Highest | Start-ScheduledTask

        # Create the named pipe and wait for the client to connect
        $pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream($pipeName, [System.IO.Pipes.PipeDirection]::InOut)
        $pipeServer.WaitForConnection()

        # Client is now connected, let's wait for him to tell us he's ready...
        $streamWriter = New-Object System.IO.StreamWriter($pipeServer)
        $streamReader = New-Object System.IO.StreamReader($pipeServer)
        $streamWriter.AutoFlush = $true

        $connectMessage = $streamReader.ReadLine()

        if ($connectMessage -ne 'ReadyForWork')
        {
            # Uhm... I don't know you! Help, rogue client!
            $pipeServer.Disconnect()
            return
        }

        # Tell the client we got his message and that he should wait for instructions
        # This is useful because we're now returning the pipe to the caller and have no idea what the caller will do with it (or when, or if)
        # So this tells the client that as far as we're concerned all setup and startup tasks have been completed on both sides and its now at the mercy of the caller
        $streamWriter.WriteLine('WaitInstructions')

        # We return all of this to the caller now so they can start issuing instructions
        $object = @{}
        $object.PipeServer = $pipeServer
        $object.StreamWriter = $streamWriter
        $object.StreamReader = $streamReader
        $object.PipeName = $pipeName

        $psObject = [PSCustomObject] $object
        $psObject.PSTypeNames.Insert(0, 'FNNamedPipe')
        $psObject
    }
}