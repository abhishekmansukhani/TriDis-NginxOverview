<#
.SYNOPSIS
Invoke New-AzureRmVirtualNetworkGateway from Terraform local-exec provisioner
.DESCRIPTION
Terraform local-exec needs a wrapper for New-AzureRmVirtualNetworkGateway to make it easier to use from a Terraform local-exec provisioner. From https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-rm-ps
#>
function Invoke-AzureRmVirtualNetworkGatewayCreation
{
    [CmdletBinding()]
    Param 
    (
        # Path of the saved AzureRM profile access token to use.
        [string] $AzureRmProfilePath = "..\\.secrets\\AzureRmProfile.json",

        # Name of the resource group for the virtual network gateway.
        [string] $ResourceGroupName = "Example.Nginx",

        # Name of the virtual network for the virtual network gateway.
        [string] $VirtualNetworkName = "VirtualNetwork",

        # Name of the virtual network's gateway subnet for the virtual network gateway.
        [string] $VirtualNetworkGatewaySubnetName = "GatewaySubnet",

        # Name of the public ip for the virtual network gateway.
        [string] $VirtualNetworkGatewayPublicIpName = "VirtualNetworkGatewayPublicIp",

        # Name of the virtual network gateway.
        [string] $VirtualNetworkGatewayName = "VirtualNetworkGateway",

        # Location of the virtual network gateway.
        [string] $Location = "East US",

        # Name of the IP configuration for the virtual network gateway.
        [string] $VirtualNetworkGatewayIpConfigName = "gwipconfig1",

        # Client address pool for the virtual network gateway (in CIDR notation).
        [string] $VirtualNetworkGatewayClientAddressPoolCidr = "10.0.1.0/24",

        # Name of a CA certificate that will sign VPN client certificates.
        [string] $VpnClientRootCertificateName = "NGINX-Example-VPN-CA",

        # Path of the CA certificate that will sign VPN client certificates.
        [string] $VpnClientRootCertificatePath = "..\\.secrets\\NGINX-Example-VPN-CA.crt"
    )
    Begin
    {
        $ErrorActionPreference = "Stop"

        $UseDebugOrVerboseOutput = $true
        if ($PSBoundParameters.ContainsKey("Debug") -or $PSBoundParameters.ContainsKey("Verbose") -or ($DebugPreference -ne "SilentlyContinue") -or ($VerbosePreference -ne "SilentlyContinue"))
        {
            $UseDebugOrVerboseOutput = $true
        }

        [Environment]::CurrentDirectory = get-location
  }

  Process {

        Select-AzureRmProfile -Path $AzureRmProfilePath

        $VirtualNetwork = Get-AzureRmVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

        $VirtualNetworkGatewaySubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $VirtualNetworkGatewaySubnetName -VirtualNetwork $VirtualNetwork

        $VirtualNetworkGatewayPublicIp = Get-AzureRmPublicIpAddress -Name $VirtualNetworkGatewayPublicIpName -ResourceGroupName $ResourceGroupName

        $VirtualNetworkGatewayIpConfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name $VirtualNetworkGatewayIpConfigName -Subnet $VirtualNetworkGatewaySubnet -PublicIpAddress $VirtualNetworkGatewayPublicIp

        $VpnClientRootCertificateX509Certificate2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($VpnClientRootCertificatePath)

        $VpnClientRootCertificateBase64 = [System.Convert]::ToBase64String($VpnClientRootCertificateX509Certificate2.RawData)

        $VpnClientRootCertificate = New-AzureRmVpnClientRootCertificate -Name $VpnClientRootCertificateName -PublicCertData $VpnClientRootCertificateBase64

        New-AzureRmVirtualNetworkGateway -Name $VirtualNetworkGatewayName -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations $VirtualNetworkGatewayIpConfig -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard -VpnClientAddressPool $VirtualNetworkGatewayClientAddressPoolCidr -VpnClientRootCertificates $VpnClientRootCertificate
  }
}