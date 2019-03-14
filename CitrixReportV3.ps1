<#
.SYNOPSIS
	Running Citrix report on total connected users on each delivery group.
.DESCRIPTION
    This script collects data on current connected Citrix sessions on a per delivery group basis. 
    These are  written to a HTML file for monitoring with a warning in place if a shortage on servers is detected.
.EXAMPLE
	Example of how to use script/function.
.NOTES
	Version - 1.0 - Author - Mic Kraan - simple get all counts off delivery groups seperate with nice html
    Version - 2.0 - Author - Thomas Churchill - Created foreach looping to generate HTML based on a central customer matrix.Added capacity planning. 
    Version - 3.0 - Author - Mic Kraan - Used different Citrix powershell cmd added disconnected sessions & re-amended html
#>

# Load citrix snap-ins
if ((gsnp "Citrix.*" -EA silentlycontinue) -eq $null) {
try { asnp Citrix.* -ErrorAction Stop }
catch { write-error "Error Get Citrix.* Powershell snapin"; Return }
}

#Variables
    #Reporting Dates
        $ReportDate = (Get-Date -UFormat "%A, %d %B %Y %R")
    #HTML Output Path
        $resultsHTM = "C:\Scripts\Citrix_AnotherTotal.html"              
    #HTML File Name
        $fileName = "Citrix_AnotherTotal.html"
    #HTML Title
        $title ="We make c IT rix Work"
    #Get all Data from DC
        $DeliveryGroup = Get-BrokerDesktopGroup -AdminAddress (!YOUR DC HERE!) | Select-Object "Name","Uid","Sessions","DesktopsDisconnected","TotalDesktops","DesktopsInUse"
    #Get Totals of users & server
        $UsersTotal = 0
        $DisconnectTotal = 0
        $ServersTotal = 0
        Foreach ($Total in $DeliveryGroup){
            $usercount = $Total.Sessions
            $disonncount = $Total.DesktopsDisconnected
            $servercount = $Total.TotalDesktops
            $UsersTotal += $usercount
            $DisconnectTotal += $disonncount
            $ServersTotal += $servercount
        }
      

#HTML Generation
    $Header = @"
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>
<meta http-equiv='refresh' content='300'>
<title>$title</title>
<STYLE TYPE='text/css'>
<!--
body {margin-left: 5px;margin-top: 5px;margin-right: 0px;margin-bottom: 10px;}
table{table-layout:fixed;}
td.main{border-width: 1px; padding: 0px; border-style: double; border-color: #999; background: #000000 ; overflow: hidden;}
td.title{font-family: Tahoma;font-size: 34px; text-shadow: 2px 2px #000; border-width: 1px; padding: 0px; border-style: solid; border-color: #999; border-radius: 50px 50px; background: #595F5F ; overflow: hidden;}
td.top{font-family: Tahoma;font-size: 24px; text-shadow: 2px 2px #000; border-width: 1px; padding: 0px; border-style: solid; border-color: #999; border-radius: 50px 50px 0px 0px; background: #595F5F ;overflow: hidden;}
td.bot{font-family: Tahoma;font-size: 18px; text-shadow: 2px 2px #000; border-width: 1px; padding: 0px; border-style: solid; border-color: #999; background-color: #595F5F;overflow: hidden;}
td.Red{font-family: Tahoma;font-size: 18px; text-shadow: 2px 2px #000; border-width: 1px; padding: 0px; border-style: solid; border-color: #999; background-color: #ff3300;overflow: hidden;}
td.Blue{font-family: Tahoma;font-size: 18px; text-shadow: 2px 2px #000; border-width: 1px; padding: 0px; border-style: solid; border-color: #999; background-color: #595F5F;overflow: hidden;}
td.Green{font-family: Tahoma;font-size: 18px; text-shadow: 2px 2px #000; border-width: 1px; padding: 0px; border-style: solid; border-color: #999; background-color: #33cc33;overflow: hidden;}
td.TotalTop{font-family: Tahoma;font-size: 24px; text-shadow: 2px 2px #000; border-width: 1px; padding: 0px; border-style: solid; border-color: #999; background-color: #0FB6DA;overflow: hidden;}
td.Total{font-family: Tahoma;font-size: 18px; text-shadow: 2px 2px #000; border-width: 1px; padding: 0px; border-style: solid; border-color: #999; background-color: #0FB6DA;overflow: hidden;}
-->
</style>
</head>
"@
$Body = @"
    <table height=100% align=center valign=top>
    <tr>
    <td class='main'> 
    <table width=90% align=center>
	    <tr>
		    <td height='54' align='center' valign='middle' class='title'><font color='#e1e1ea'><strong>$title - $ReportDate</strong></font></td>
	    </tr>
    </table>
    <br>
    <table width=90% align=center>
	    <tr>
"@
    ForEach ($DG1 in $DeliveryGroup ){
        $name2 = $DG1.Name
        $Body += "<td align=center colspan='2' class='top'><font color='#e1e1ea'><strong> $name2 </strong></font></td>"  
    }
$Body += "<td align=center colspan='2' class='TotalTop'><font color='#e1e1ea'><strong> Total </strong></font></td></tr><tr>"
    foreach ($DG2 in $DeliveryGroup ){
        $TotalUsers2 = $DG2.Sessions
        $Disconnected2 = $DG2.DesktopsDisconnected
        $TotalServ2 = $DG2.TotalDesktops
        $Body += "<td align=center class='bot'><font color='#e1e1ea'><strong>Users: <br> $TotalUsers2 </strong> </font><font color='#CED1D1'>($Disconnected2)</font></td>"
#Get capacity planning (don't want more then 25 users on a box + a spare for maintenance else-if make my cell red :)
        $projectedservers2 = (($TotalUsers2 / 25)+1)
        if ($DG2.TotalServ2 -lt $DG2.projectedservers2){$Body += "<td align=center class='red'><font color='#e1e1ea'><strong>Servers: <br> $TotalServ2 </strong></font></td>"}
        elseif ($DG2.TotalServ2 -eq $DG2.projectedservers2){$Body += "<td align=center class='bot'><font color='#e1e1ea'><strong>Servers: <br> $TotalServ2 </strong></font></td>"}
        elseif ($DG2.TotalServ2 -gt $DG2.projectedservers2){$Body += "<td align=center class='green'><font color='#e1e1ea'><strong>Servers: <br> $TotalServ2 </strong></font></td>"}
    }
$Body += "
        <td align=center class='Total'><font color='#e1e1ea'><strong>Users: <br> $UsersTotal </strong> </font><font color='#CED1D1'>($DisconnectTotal)</font></td>
        <td align=center class='Total'><font color='#e1e1ea'><strong>Servers: <br> $ServersTotal </strong></font></td>

                </tr>
            </table>
    </td>
    </tr>
</table>
</body>
</html>"
    $Header + $Body | Out-File -FilePath $resultsHTM