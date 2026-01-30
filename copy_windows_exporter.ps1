$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$servers = Get-Content "$base\\servers.txt"

$msiName = "windows_exporter-0.31.3-amd64.msi"
$localMsi = "$base\\$msiName"
$remoteMsi = "C:\\Temp\\$msiName"

foreach ($server in $servers) {

    Write-Host "===== Copying to $server ====="

    Invoke-Command -ComputerName $server -ScriptBlock {
        param ($remoteMsi)

        if (!(Test-Path "C:\\Temp")) {
            New-Item C:\\Temp -ItemType Directory | Out-Null
        }

        if (Test-Path $remoteMsi) {
            Write-Host "MSI already exists. Skipping copy."
        }
    } -ArgumentList $remoteMsi

    if (-not (Invoke-Command -ComputerName $server -ScriptBlock {
        param ($remoteMsi)
        Test-Path $remoteMsi
    } -ArgumentList $remoteMsi)) {

        Copy-Item $localMsi "\\\\$server\\C$\\Temp\\" -Force
        Write-Host "Copied MSI to $server"
    }
}
