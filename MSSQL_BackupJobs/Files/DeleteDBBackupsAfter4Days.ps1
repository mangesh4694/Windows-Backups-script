#Old script
#Get-ChildItem -Recurse -Path "D:\MSSQL_Backups" | Where-Object { ! $_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-4)} | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue


# Define the path of the folder where the files and folders are located
$folderPath = "D:\MSSQL_Backups"

# Get the files and folders in the folder that are older than 5 days
$oldItems = Get-ChildItem $folderPath -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-4) }

# Loop through the old items and delete them
foreach ($item in $oldItems) {
    if ($item.PSIsContainer) {
        Remove-Item $item.FullName -Recurse -Force
    } else {
        Remove-Item $item.FullName -Force
    }
}