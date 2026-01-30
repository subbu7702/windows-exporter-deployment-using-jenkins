# Windows Exporter Automated Upgrade Pipeline

## Overview

This project automates the upgrade and installation of Prometheus Windows Exporter across multiple Windows servers using Jenkins and PowerShell.

The pipeline is designed to be safe to re-run, handle real-world edge cases, and avoid unnecessary reinstallations when servers are already compliant.

It was built to replace manual RDP-based upgrades with a repeatable, auditable, and scalable process

## Features

1.Detects existing Windows Exporter installations

2.Skips servers already running the target version

3.Removes older versions cleanly

4.Handles cases where Windows Installer service is stopped

5.Avoids re-copying MSI if already present

6.Performs fresh install on servers where exporter is missing

7.Verifies final version after installation

8.Jenkins pipeline orchestration with clear stage separation

## Target Version

The pipeline currently upgrades servers to: windows_exporter 0.31.3

## Project Structure

```text
windows-exporter-deployment-using-jenkins
├── Jenkinsfile
├── servers.txt
├── copy_windows_exporter.ps1
├── install_windows_exporter.ps1
├── verify_version.ps1
└── README.md
```

## File Descriptions

```text
servers.txt
```

List of Target Servers (One per line)

```text
copy_windows_exporter.ps1
```

1.Copies the MSI to remote servers
2.Skips copy if the file already exists in C:\Temp

```text
install_windows_exporter.ps1
```

Core logic of the project.

This script:

1.Checks if Windows Exporter is installed

2.Compares current version

3.Skips install if already compliant

4.Stops and deletes old services

5.Removes leftover binaries

6.Starts msiserver if stopped

7.Installs the new MSI silently

```text
verify_version.ps1
```

1.Connects to each server

2.Confirms installed version

3.Fails the pipeline if mismatch is detected

```text
Jenkinsfile
```

Defines pipeline stages:

1.Copy MSI

2.Install / Upgrade Windows Exporter

3.Verify Installed Version

---

## Execution Flow

Jenkins Pipeline
|
v
Copy MSI (if missing)
|
v
Install / Upgrade Script
|
v
Verify Version
|
v
SUCCESS / FAILURE

---

## Design Requirements

This project was built with:

1.Idempotency – safe to run multiple times

2.Defensive scripting – handles broken services & partial installs

3.Clear logging – each server prints status

4.Minimal manual intervention

5.Separation of concerns – Jenkins orchestrates, scripts execute logic

---

## Requirements

1.Jenkins agent running on Windows

2.WinRM enabled on target servers

3.Jenkins service account with admin rights

4.PowerShell remoting enabled

5.Network connectivity to all servers

6.MSI available in Jenkins workspace

---

## How to Run

1.Add servers to servers.txt

2.Update version and MSI name in scripts if needed

3.Commit all files to GitHub

4.Create Jenkins pipeline pointing to the repo

5.Run the pipeline

---

## Sample Output

```text
===== Processing SERVER01 =====
Current version: 0.30.2
Removing old Windows Exporter
Installing Windows Exporter 0.31.3

===== Processing SERVER02 =====
Windows Exporter already up to date. Skipping install.

===== Processing SERVER03 =====
Windows Exporter not installed
Installing Windows Exporter 0.31.3
```
