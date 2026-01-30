$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$servers = Get-Content "$base\\servers.txt"

$exePath = "C:\\Program Files\\windows_exporter\\windows_exporter.exe"
$targetVersion = "0.31.3"

$failed = $false

foreach ($server in $servers) {

    Write-Host "===== Verifying $server ====="

    $version = Invoke-Command -ComputerName $server -ScriptBlock {

        param ($exePath)

        if (Test-Path $exePath) {
            (Get-Item $exePath).VersionInfo.ProductVersion
        } else {
            "NOT_INSTALLED"
        }

    } -ArgumentList $exePath

    Write-Host "Version on ${server}: $version"

    if ($version -ne $targetVersion) {
        Write-Error "$server is NOT on expected version"
        $failed = $true
    }
}

if ($failed) {
    throw "One or more servers failed version verification."
}

Write-Host "All servers are running $targetVersion"
