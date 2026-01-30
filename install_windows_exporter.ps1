$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$servers = Get-Content "$base\\servers.txt"

$targetVersion = "0.31.3"
$msiName = "windows_exporter-0.31.3-amd64.msi"

$remoteMsiPath = "C:\\Temp\\$msiName"
$exePath = "C:\\Program Files\\windows_exporter\\windows_exporter.exe"

foreach ($server in $servers) {

    Write-Host "===== Processing $server ====="

    Invoke-Command -ComputerName $server -ScriptBlock {

        param (
            $exePath,
            $remoteMsiPath,
            $targetVersion
        )

        # ----------------------------
        # Check existing version
        # ----------------------------

        if (Test-Path $exePath) {

            $currentVersion = (Get-Item $exePath).VersionInfo.ProductVersion
            Write-Host "Current version: $currentVersion"

            if ($currentVersion -eq $targetVersion) {
                Write-Host "Already on target version. Exiting install."
                return
            }

            Write-Host "Removing old Windows Exporter..."

            Stop-Service windows_exporter -ErrorAction SilentlyContinue
            sc.exe delete windows_exporter | Out-Null
            Start-Sleep 3

        } else {
            Write-Host "Windows Exporter not installed."
        }

        # ----------------------------
        # Ensure Windows Installer running
        # ----------------------------

        $msiSvc = Get-Service msiserver -ErrorAction SilentlyContinue

        if ($msiSvc.Status -ne "Running") {
            Write-Host "Starting Windows Installer service..."
            Start-Service msiserver
            Start-Sleep 3
        }

        # ----------------------------
        # Cleanup remnants
        # ----------------------------

        Get-Process windows_exporter -ErrorAction SilentlyContinue | Stop-Process -Force

        sc.exe delete windows_exporter | Out-Null

        Remove-Item "C:\\Program Files\\windows_exporter" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "C:\\Program Files (x86)\\windows_exporter" -Recurse -Force -ErrorAction SilentlyContinue

        if (!(Test-Path C:\\Temp)) {
            New-Item C:\\Temp -ItemType Directory | Out-Null
        }

        # ----------------------------
        # Install
        # ----------------------------

        Write-Host "Installing Windows Exporter $targetVersion..."

        $proc = Start-Process msiexec.exe `
            -ArgumentList "/i `"$remoteMsiPath`" /quiet /norestart" `
            -Wait `
            -PassThru

        if ($proc.ExitCode -ne 0) {
            throw "MSI installation failed with exit code $($proc.ExitCode)"
        }

    } -ArgumentList $exePath, $remoteMsiPath, $targetVersion
}
