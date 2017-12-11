Write-Host "Configuring network interface"
Write-Host ""
Write-Host "List all available interfaces"
get-wmiobject win32_networkadapter -filter "netconnectionstatus = 2" | select netconnectionid, name, InterfaceIndex, netconnectionstatus
 
#get response from user to select NIC index
$int_id=read-host "Enter interface index to configure: "
#Current IP configuration
Write-Host "Current IP address " (Get-NetIPAddress -InterfaceIndex $int_id -AddressFamily IPv4)
$ip_addr=read-host "Enter IP address: "
 
#remove old IP address and gw if they already exist
Remove-NetIPAddress((Get-NetIPAddress -InterfaceIndex $int_id).IPAddress) -Confirm:$false
 
if (Get-NetIPConfiguration | where {$_.IPv4DefaultGateway -ne $null})
{
Remove-NetRoute -InterfaceIndex $int_id -Confirm:$false
}
