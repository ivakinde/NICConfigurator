#.1.0 subnet gw
$ip_gw_1_0_subnet="192.168.1.1"
#.2.0 subnet gw
$ip_gw_2_0_subnet="192.168.2.1"
 
#dns settings
$ip_dns_1="192.168.1.2"
$ip_dns_2="192.168.1.3"
$ip_DNS_Suffix = "adatum.local"
 
#function to compare IP address within the range
function IsIpAddressInRange {
param(
 [string] $ipaddress,
 [string] $begin_range,
 [string] $end_range
)
 
$ip = [system.net.ipaddress]::Parse($ipAddress).GetAddressBytes()
 [array]::Reverse($ip)
 $ip = [system.BitConverter]::ToUInt32($ip, 0)
 
$from = [system.net.ipaddress]::Parse($begin_range).GetAddressBytes()
 [array]::Reverse($from)
 $from = [system.BitConverter]::ToUInt32($from, 0)
 
$to = [system.net.ipaddress]::Parse($end_range).GetAddressBytes()
 [array]::Reverse($to)
 $to = [system.BitConverter]::ToUInt32($to, 0)
 
$from -le $ip -and $ip -le $to
 
}
 
Write-Host "Configuring network interface"
Write-Host ""
Write-Host "List all available interfaces"
$NIC = get-wmiobject win32_networkadapter -filter 'netconnectionstatus = 2'
$NIC | select name, InterfaceIndex | Out-host
 
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
 
#Configure IP address
if (IsIPAddressInRange $ip_addr "192.168.1.1" "192.168.1.254")
 {
 New-NetIPAddress -interfaceIndex $int_id -IPaddress $ip_addr -PrefixLength 24 -DefaultGateway $ip_gw_1_0_subnet &amp;gt; $null 
 }
 
#If you need to do more check, add "elseif"
 
elseif (IsIPAddressInRange $ip_addr "x.x.x.x" "x.x.x.x")
 {
 New-NetIPAddress -interfaceIndex $int_id -IPaddress $ip_addr -PrefixLength 24 -DefaultGateway $ip_gw_2_0_subnet &amp;gt; $null
 }
 
else 
 {
 Write-Host "You've entered IP address which is out of range. Please restart this script" -ForegroundColor Red
 exit
 }
  
#Configure DNS servers
Set-DnsClientServerAddress -interfaceIndex $int_id -ServerAddresses $ip_dns_1, $ip_dns_2
 
#set primary DNS suffix
Write-Host "Setting up DNS servers and primary DNS suffix to qualityserver.de"
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name Domain -Value $ip_dns_suffix
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name "NV Domain" -Value $ip_dns_suffix
