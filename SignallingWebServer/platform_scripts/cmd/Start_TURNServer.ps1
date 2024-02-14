# Copyright Epic Games, Inc. All Rights Reserved.

. "$PSScriptRoot\Start_Common.ps1" $args

set_start_default_values "y" "n" # Set both TURN and STUN server defaults
use_args($args)
print_parameters
#$LocalIp = Invoke-WebRequest -Uri "http://169.254.169.254/latest/meta-data/local-ipv4"
#$LocalIP = (Test-Connection -ComputerName (hostname) -Count 1  | Select IPV4Address).IPV4Address.IPAddressToString

# LocalIP Alternative: Get network adapter based on name.
$targetAdapter = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' -and $_.Name -like 'Ethernet' } | Select -First 1
$localIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $targetAdapter.IfIndex).IPAddress

# LocalIP Alternative: get Ip by matching expected range 192.168.1.*
#$LocalIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '192.168.1.*' } | Select -First 1).IPAddress

Write-Output "Private IP: $LocalIP"

$TurnPort="19303"
$Pos = $global:TurnServer.LastIndexOf(":")
if ($Pos -ne -1) {
 $TurnPort = $global:TurnServer.Substring($Pos+ 1)
}
echo "TURN port: ${turnport}"
echo ""

Push-Location $PSScriptRoot

$TurnUsername = "PixelStreamingUser"
$TurnPassword = "AnotherTURNintheroad"
$Realm = "PixelStreaming"
$ProcessExe = ".\turnserver.exe"
$Arguments = "-c ..\..\..\turnserver.conf --allowed-peer-ip=$LocalIP -p $TurnPort -r $Realm -X $PublicIP -E $LocalIP -L $LocalIP --no-cli --no-tls --no-dtls --pidfile `"C:\coturn.pid`" -f -a -v -u $TurnUsername`:$TurnPassword"

# Add arguments passed to script to Arguments for executable
$Arguments += $args

Push-Location $PSScriptRoot\coturn\
Write-Output "Running: $ProcessExe $Arguments"
# pause
Start-Process -FilePath $ProcessExe -ArgumentList $Arguments -NoNewWindow
Pop-Location

Pop-Location