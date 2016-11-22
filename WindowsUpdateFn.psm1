# Get public and private function definition files.
$Public  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($file in @($Public + $Private))
{
	Try
	{
		. $file.fullname
	}
	Catch
	{
		Write-Error -Message "Failed to import function $($file.FullName): $_"
	}
}

# Get private .cs files.
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.cs -ErrorAction SilentlyContinue)

foreach ($file in $Private) 
{
	Try
	{
		Add-Type -Path $file.FullName
	}
	Catch
	{
		Write-Error -Message "Failed to import .cs file $($file.FullName): $_"
	}
}

Export-ModuleMember -Function $Public.Basename