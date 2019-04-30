$subscriptionIdProd = "8999dec3-0104-4a27-94ee-6588559729d1"
$AzureContext = Select-AzureRmSubscription -SubscriptionId $subscriptionIdProd

$hostArray = @()
$hostTable = @()
Get-AzureRmWebApp | % { 
    $hostName = ($_ | Select-Object Name, DefaultHostName, HostNames) | %{

        $slotObj = $null
        $slotObj = New-Object System.Object
        $slotObj | Add-Member -type NoteProperty -Name Name -Value $_.Name
        if($_.DefaultHostName -eq $null) {
            $_.DefaultHostName = 'N/A'
        }
        $slotObj | Add-Member -type NoteProperty -Name DefaultHostName -Value $_.DefaultHostName
        if($_.HostNames) { 
            $singleHost = @()
            foreach ($_ in $_.HostNames) {
            $singleHost += '&rsaquo;&nbsp;'+$_+'<br />'
            }
        }
        else {
            $singleHost = 'N/A'
        }
        $slotObj | Add-Member -type NoteProperty -Name HostNames -Value $singleHost
    $hostArray += $slotObj
    
    foreach ($_ in $hostArray) {
        $Name               = $_ | Select-Object -Expand Name
        $Default            = $_ | Select-Object -Expand DefaultHostName
        $HostNames          = $_ | Select-Object -Expand HostNames  
    }

    $hostItem ="<tr><td style='border-left: thin solid; border-top: thin solid; border-bottom: thin solid;'>$Name</td><td style='border-top: thin solid; border-bottom: thin solid;'>$Default</td><td style='border-top: thin solid; border-bottom: thin solid; border-right: thin solid;'>$HostNames</td></tr>"
    $hostTable += $hostItem
    }

[string]$tableHeader = '<table cellpadding="15" cellspacing="2"><tr><th bgcolor="#f2f2f2">App Name</th><th bgcolor="#f2f2f2">Default Host Name</th><th bgcolor="#f2f2f2">All Host Names</th></tr>'
[string]$tableFooter = '</table>'
[string]$table = $tableHeader + $hostTable + $tableFooter
}
$table
