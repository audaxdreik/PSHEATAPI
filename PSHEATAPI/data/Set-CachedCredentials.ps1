# do not prefix domain, login should be 'jdoe' and your current network password
Write-Host -Object "do not prefix domain (i.e. 'jdoe'), login should be and your current network username and password"

Get-Credential -Message 'HEAT Login' | Export-Clixml -Path $PSScriptRoot\cachedCredentials