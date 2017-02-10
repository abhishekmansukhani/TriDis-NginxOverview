# ToDo: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-rm-ps

function Invoke-AzureRmVirtualNetworkGatewayCreation {
  <#
  .SYNOPSIS
  Describe the function here
  .DESCRIPTION
  Describe the function in more detail
  .EXAMPLE
  Give an example of how to use it
  .EXAMPLE
  Give another example of how to use it
  .PARAMETER computername
  The computer name to query. Just one.
  .PARAMETER logname
  The name of a file to write failed computer names to. Defaults to errors.txt.
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='What computer name would you like to target?')]
    [Alias('host')]
    [ValidateLength(3,30)]
    [string[]]$computername,
		
    [string]$logname = 'errors.txt'
  )

  begin {
  write-verbose "Deleting $logname"
    del $logname -ErrorActionSilentlyContinue
  }

  process {
       Login-AzureRmAccount
       Get-AzureRmSubscription
       Select-AzureRmSubscription -SubscriptionName "Name of subscription"
 $VNetName  = "VNet1"
 $FESubName = "FrontEnd"
 $BESubName = "Backend"
 $GWSubName = "GatewaySubnet"
 $VNetPrefix1 = "192.168.0.0/16"
 $VNetPrefix2 = "10.254.0.0/16"
 $FESubPrefix = "192.168.1.0/24"
 $BESubPrefix = "10.254.1.0/24"
 $GWSubPrefix = "192.168.200.0/26"
 $VPNClientAddressPool = "172.16.201.0/24"
 $RG = "TestRG"
 $Location = "East US"
 $DNS = "8.8.8.8"
 $GWName = "VNet1GW"
 $GWIPName = "VNet1GWPIP"
 $GWIPconfName = "gwipconf"
 New-AzureRmResourceGroup -Name $RG -Location $Location
 $fesub = New-AzureRmVirtualNetworkSubnetConfig -Name $FESubName -AddressPrefix $FESubPrefix
 $besub = New-AzureRmVirtualNetworkSubnetConfig -Name $BESubName -AddressPrefix $BESubPrefix
 $gwsub = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName -AddressPrefix $GWSubPrefix
 New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG -Location $Location -AddressPrefix $VNetPrefix1,$VNetPrefix2 -Subnet $fesub, $besub, $gwsub -DnsServer $DNS
 $vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG
 $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet
 $pip = New-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $RG -Location $Location -AllocationMethod Dynamic
 $ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip
    $P2SRootCertName = "Mycertificatename.cer"
    $filePathForCert = "C:\cert\Mycertificatename.cer"
    $cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathForCert)
    $CertBase64 = [system.convert]::ToBase64String($cert.RawData)
    $p2srootcert = New-AzureRmVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $CertBase64
    New-AzureRmVirtualNetworkGateway -Name $GWName -ResourceGroupName $RG `
    -Location $Location -IpConfigurations $ipconf -GatewayType Vpn `
    -VpnType RouteBased -EnableBgp $false -GatewaySku Standard `
    -VpnClientAddressPool $VPNClientAddressPool -VpnClientRootCertificates $p2srootcert


  }
}