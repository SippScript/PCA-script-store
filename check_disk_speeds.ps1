# Ensure the C:\Temp directory exists
$testDir = "C:\Temp"
if (-not (Test-Path -Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir
}

# Function to create a test file of specified size in MB
function Create-TestFile {
    param (
        [string]$filePath,
        [int]$sizeInMB
    )
    $chunkSize = 1MB
    $chunkData = "This is a test file." * ($chunkSize / [System.Text.Encoding]::UTF8.GetByteCount("This is a test file.")) # 1 MB chunk
    $fileStream = [System.IO.File]::OpenWrite($filePath)
    for ($i = 0; $i -lt $sizeInMB; $i++) {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($chunkData)
        $fileStream.Write($bytes, 0, $bytes.Length)
    }
    $fileStream.Close()
}

# List all drives on the system
$drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }  # Only local disks

foreach ($drive in $drives) {
    Write-Host "Testing drive: $($drive.DeviceID)"
    
    # Perform write test
    $writeTestFile = "$testDir\writeTest.tmp"
    $writeStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    Create-TestFile -filePath $writeTestFile -sizeInMB 100  # 100 MB file
    $writeStopwatch.Stop()
    $writeSpeed = [math]::Round((100 / $writeStopwatch.Elapsed.TotalSeconds), 2)  # Speed in MB/s
    Write-Host "Write Speed: $writeSpeed MB/s"
    
    # Perform read test
    $readStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $readContent = [System.IO.File]::ReadAllText($writeTestFile)
    $readStopwatch.Stop()
    $readSpeed = [math]::Round((100 / $readStopwatch.Elapsed.TotalSeconds), 2)  # Speed in MB/s
    Write-Host "Read Speed: $readSpeed MB/s"
    
    # Clean up test file
    Remove-Item $writeTestFile
}
