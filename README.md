# veeam
for passing the test of veeam

How to use:
This script has three parameters in total:
    [string]$sourcePath,
    [string]$replicaPath,
    [string]$logFilePath
    
$sourcePath represents the source folder path,
$replicaPath represents the replica folder path,
$logFilePath represents the log path

Anyone can use the script with the following command:
.\Sync-Folders.ps1 -sourcePath $sourcePath -replicaPath $replicaPath -logFilePath $logFilePath
