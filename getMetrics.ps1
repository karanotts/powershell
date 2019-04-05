$storageAccount    = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName
$storageAccountKey = (Get-AzureRmStorageAccountKey -Name $storageAccountName -ResourceGroupName $resourceGroup).Value[0]
$storageContext    = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$container         = Get-AzureStorageShare -Name $containerName -Context $storageContext

$AzureContext      = Select-AzureRmSubscription -SubscriptionId $subscriptionIdProd
$serverFarms       = (Get-AzureRmResource -ResourceType "Microsoft.Web/serverFarms")

mkdir temp 
cd ./temp

foreach ($farm in $serverFarms) {

    $resId      = $farm.ResourceId
    $farmName   = $farm.Name
    $logFile    = "$farmName"+".log"

    $TIMESTAMP  = (Get-AzureRmMetric -ResourceId $resId -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date) | Select -ExpandProperty Data | Select -Property Timestamp).Timestamp
    $CPU        = (Get-AzureRmMetric -ResourceId $resId -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date) -MetricName "CpuPercentage" | Select -ExpandProperty Data | Select -Property Average).Average
    $MEMORY     = (Get-AzureRmMetric -ResourceId $resId -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date) -MetricName "MemoryPercentage" | Select -ExpandProperty Data | Select -Property Average).Average

    $metrics    = 0..($TIMESTAMP.Length-1) | Select @{n="Timestamp";e={$TIMESTAMP[$_]}}, @{n="AvgCPU";e={$CPU[$_]}}, @{n="AvgRAM";e={$MEMORY[$_]}}
    $file       = ($metrics | Out-File -FilePath .\$logFile)

}

$CurrentFolder = (Get-Item .).FullName

Get-ChildItem -Recurse | Where-Object { $_.GetType().Name -eq "FileInfo"} | ForEach-Object {
    $path=$_.FullName.Substring($Currentfolder.Length+1).Replace("\","/")
    Set-AzureStorageFileContent -Share $container -Source $_.FullName -Path $path -Force
}
