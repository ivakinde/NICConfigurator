# NICConfigurator
Network interface configuration script for Windows Server 2016, which doing the following tasks:
- checking the range of IP address and configuring gateway, mask accoring it’s range. If IP address out of range, the script will end.
- configure DNS suffix and DNS servers
- configure IP settings on selected network adapter

Main file Win2016 - NICConfigurator.ps1
AddOn for Win2012 - AddOnForWin2012.ps1
