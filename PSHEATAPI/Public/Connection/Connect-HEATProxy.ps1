<#
    .SYNOPSIS
    Opens a connection to the HEAT service web proxy.
    .DESCRIPTION
    Creates a web service proxy from 'FRSHEATIntegration.asmx?wsdl' under the specified role. Returns $true if the
    connection is successfully established, otherwise throws an error.
    .PARAMETER TenantID
    The tenantId property of your HEAT instance.
    .PARAMETER Role
    The access role for which your service account will be connecting to HEAT. Should typically be an admin level
    role or something with granular defined access.
    .PARAMETER Credential
    If not using a 'cachedCredentials' file of type [pscredential] at $PSScriptRoot\data or a service account, you
    will need to provide your own credentials via Get-Credential. The username is just your network username (i.e.
    'jdoe') and your current network password. Ensure that you are passing an appropriate -Role attached to that
    account.
    .PARAMETER NoSSL
    Use this to connect to a HEAT server using http.
    .EXAMPLE
    PS C:\>Connect-HEATProxy -TenantID 'my.tenant.id' -Role 'Admin II'

    Opens a connection to 'my.tenant.id' as an 'Admin II' with the cached credentials if available, otherwrise
    prompts.
    .EXAMPLE
    PS C:\>Connect-HEATProxy -TenantID 'my.tenant.id' -Role 'Service Desk Analyst' -Credential (Get-Credential)

    Opens a connection to 'my.tenant.id', under the 'Service Desk Analyst' role using the credentials provided from
    the Get-Credential pop-up window.
    .EXAMPLE
    Connect-HEATProxy -TenantID "HDSRV01" -Role 'Admin' -Credential (Get-Credential) -NoSSL

    Opens a connection to HDSRV01, under the Admin role using the credentials provided and going to an http endpoint.
    .NOTES
    Please remember that cached credentials are only available to the user that cached them, from the device that
    they were cached on. Take this into account when setting up scheduled tasks or when testing in your own lab.
#>
function Connect-HEATProxy {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Position = 0)]
        [string]$TenantID,
        [Parameter(Position = 1)]
        [ValidateSet('Admin', 'Admin II', 'Inventory Manager', 'Report Manager', 'Self Service', 'Service Desk Analyst')]
        [string]$Role,
        [Parameter(Position = 2)]
        [pscredential]$Credential,
        [Parameter()]
        [switch]$NoSSL,
        [switch]$TrustSSL,
        [string]$OnPremUrl
    )

    # Validate all our parameters are either provided or cached
    if (-not $TenantID) {

        if ($script:HEATCONNECTION.tenantId) {

            $TenantID = $script:HEATCONNECTION.tenantId

        } else {

            throw 'TenantId was neither provided nor cached. please specify -TenantID'

        }

    }

    if (-not $Role) {

        if ($script:HEATCONNECTION.role) {

            $Role = $script:HEATCONNECTION.role

        } else {

            throw 'Role was neither provided nor cached. please specify -Role'

        }

    }

    if (-not $Credential) {

        if ($script:HEATCREDENTIALS) {

            $Credential = $script:HEATCREDENTIALS

        } else {

            throw 'Credential was neither provided nor cached. please specify -Credential'

        }

    }

    if (-not $NoSSL) {

        if ($script:HEATCONNECTION.NoSSL) {

            $NoSSL = $true

        } else {

            $NoSSL = $false

        }

    }

    if ($TrustSSL) {

        add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        # This allows to connect to HTTPS with self-signed (test environnement) or expired certificate
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    }

    if (-not $OnPremUrl) {
        
        if ($script:HEATCONNECTION.OnPremUrl) {

            $NoSSL = $script:HEATCONNECTION.OnPremUrl

        } else {

            $OnPremUrl = ''

        }
    }

    if ($OnPremUrl) {

        if (-not ( $script:HEATCONNECTION.OnPremUrl -match '/' -or $OnPremUrl -match '/' ) ) {

            $OnPremUrl = $OnPremUrl +'/'

        }

    }

    # Generate URL
    $webProxyUri = "$TenantID/$($OnPremUrl)ServiceAPI/FRSHEATIntegration.asmx?wsdl"

    if ($NoSSL) {

        $webProxyUri = "http://" + $webProxyUri

    } else {

        $webProxyUri = "https://" + $webProxyUri

    }

    # This just creates the proxy object we'll call, it does NOT connect to the service!
    Write-Verbose -Message "Set connection to $webProxyUri"
    $script:HEATPROXY = New-WebServiceProxy -Uri $webProxyUri -Namespace "WebServiceProxy" -Class "HEAT"

    # This is the piece that actually authenticates and connects to the service. we'll need to reference the
    # resultant sessionKey on all successive API calls

    $script:HEATCONNECTION = $script:HEATPROXY.Connect(
        $Credential.UserName,
        $Credential.GetNetworkCredential().Password,
        $TenantID,
        $Role
    )

    # Throw an error if anything other than 'Success'
    if ($script:HEATCONNECTION.connectionStatus -notlike 'Success') {

        throw "connectionStatus - $($script:HEATCONNECTION.connectionStatus): $($script:HEATCONNECTION.exceptionReason)"

    }

    # Store the provided credentials in the scope of the script
    $script:HEATCREDENTIALS = $Credential
    # Add the tenantID to the connection proxy so it's easy to reference in the rest of our API calls
    $script:HEATCONNECTION | Add-Member -NotePropertyName 'tenantId' -NotePropertyValue $TenantID
    # Add the role to the connection proxy so we can easily reference it to renew when session expires
    $script:HEATCONNECTION | Add-Member -NotePropertyName 'role'     -NotePropertyValue $Role
    # Add if NoSSL was used
    $script:HEATCONNECTION | Add-Member -NotePropertyName 'NoSSL' -NotePropertyValue $NoSSL
    # Add if OnPremUrl was used
    $script:HEATCONNECTION | Add-Member -NotePropertyName 'OnPremUrl' -NotePropertyValue $OnPremUrl

    Write-Verbose -Message "connection to $webProxyUri succeeded"

    return $true

}
