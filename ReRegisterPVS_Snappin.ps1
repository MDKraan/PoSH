
###### PVS Powershell #######
#
# Version - 1.0 - Author - Mic Kraan
#
# DESCRIPTION:
# reregister all snappins after upgrading PVS 
#
# TO CHECK:
# PLEASE CHECK PATH NAMES TO SYSTEM FILES (.dll)
#
# Citrix.PVS.Snapin 
# Citrix.Broker.Admin.V2 
# Citrix.Configuration.Admin.V2 
# Citric.ConfigurationLogging.Admin.V1 
# Ctrix.DelegatedAdmin.Admin.V1 
# Citrix.Host.Admin.V2
#
#############################

# create Alias
Set-Alias installutil64 $env:windir\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe
Set-Alias installutil $env:windir\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe

# 
$PvsSnappins = "C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.Snapin.dll","C:\Program Files\Citrix\Broker\Snapin\v2\BrokerSnapin.dll","C:\Program Files\Citrix\Configuration\SnapIn\Citrix.Configuration.Admin.V2\Citrix.Configuration.PowerShellSnapIn.dll","C:\Program Files\Citrix\ConfigurationLogging\SnapIn\Citrix.ConfigurationLogging.Admin.V1\Citrix.ConfigurationLogging.PowerShellSnapIn.dll","C:\Program Files\Citrix\DelegatedAdmin\SnapIn\Citrix.DelegatedAdmin.Admin.V1\\Citrix.DelegatedAdmin.PowerShellSnapIn.dll","C:\Program Files\Citrix\Host\SnapIn\Citrix.Host.Admin.V2\\Citrix.Host.PowerShellSnapIn.dll"

ForEach ($PvsSnappin in $PvsSnappins){
    InstallUtil64 $PvsSnappin
    InstallUtil $PvsSnappin
}