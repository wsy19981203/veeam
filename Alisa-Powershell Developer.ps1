param(
    [string]$sourcePath,
    [string]$replicaPath,
    [string]$logFilePath
)

# Function to initialize logging
function Initialize-Logging {
    if (-not (Test-Path -Path $logFilePath)) {
        New-Item -ItemType File -Path $logFilePath -Force | Out-Null
    }
}

# Function to log messages to file and console
function Log-Message {
    param(
        [string]$message
    )
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $message"
    Add-Content -Path $logFilePath -Value $logMessage
    Write-Output $logMessage
}

# Function to synchronize folders
function Sync-Folders {
    param(
        [string]$source,
        [string]$replica
    )

    # Get all items in source folder
    $sourceItems = Get-ChildItem -Path $source -Recurse

    foreach ($item in $sourceItems) {
        $relativePath = $item.FullName.Substring($source.Length)

        # Construct full paths for replica
        $replicaItemPath = Join-Path -Path $replica -ChildPath $relativePath

        if ($item.PSIsContainer) {
            # If directory doesn't exist in replica, create it
            if (!(Test-Path -Path $replicaItemPath)) {
                New-Item -Path $replicaItemPath -ItemType Directory | Out-Null
                Log-Message "Created directory: $replicaItemPath"
            }
        } else {
            # If file doesn't exist in replica or is different, copy it
            if (!(Test-Path -Path $replicaItemPath) -or !(Compare-Object (Get-Item $item.FullName) (Get-Item $replicaItemPath) -Property Length, LastWriteTime)) {
                Copy-Item -Path $item.FullName -Destination $replicaItemPath -Force
                Log-Message "Copied file: $($item.FullName) to $replicaItemPath"
            }
        }
    }

    # Clean up items in replica that are not in source
    $replicaItems = Get-ChildItem -Path $replica -Recurse
    foreach ($item in $replicaItems) {
        $relativePath = $item.FullName.Substring($replica.Length)

        # Construct full paths for source
        $sourceItemPath = Join-Path -Path $source -ChildPath $relativePath

        if (!(Test-Path -Path $sourceItemPath)) {
            Remove-Item -Path $item.FullName -Force -Recurse
            Log-Message "Removed item: $($item.FullName)"
        }
    }
}

# Main script logic
try {
    Initialize-Logging

    Log-Message "Starting folder synchronization from $sourcePath to $replicaPath"

    Sync-Folders -source $sourcePath -replica $replicaPath

    Log-Message "Folder synchronization completed successfully"
}
catch {
    Log-Message "Error occurred: $_"
}
finally {
    Log-Message "Script execution completed"
}
