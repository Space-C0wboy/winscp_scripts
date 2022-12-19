param (
    $localPath = "C:\Example_Path_Here\*",
    $remotePath = "/Remote_Path_Here/",
    $backupPath = "D:\Example_Backup_Path_Here\"
)
 
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = "ftp.serverpath.here"
        UserName = "Username"
        Password = "Password"
        SshHostKeyFingerprint = "SSH Key"
    }
 
    $session = New-Object WinSCP.Session
    $session.SessionLogPath = "C:\FTP\winscp_script.log"
 
    try
    {
        # Connect
        $session.Open($sessionOptions)
 
        # Upload files, collect results
        $transferResult = $session.PutFiles($localPath, $remotePath)
 
        # Iterate over every transfer
        foreach ($transfer in $transferResult.Transfers)
        {
            # Success or error?
            if ($transfer.Error -eq $Null)
            {
                Write-Host "Upload of $($transfer.FileName) succeeded, moving to backup"
                # Upload succeeded, move source file to backup
                $file = $transfer.filename -split '\\' | select -last 1
                $parentpath = $transfer.filename -replace "C:\\Example_Path_Here\\Upload\\(.+)$file",'$1'
                $destinationpath = Join-Path $backupPath $parentpath
                Move-Item $transfer.FileName $destinationpath -Verbose
            }
            else
            {
                Write-Host "Upload of $($transfer.FileName) failed: $($transfer.Error.Message)"
            }
        }
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
