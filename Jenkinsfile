pipeline {
    agent any

    stages {

        stage('Copy Windows Exporter') {
            steps {
                powershell '''
                powershell.exe -NoProfile -ExecutionPolicy Bypass `
                    -File ".\\copy_windows_exporter.ps1"
                '''
            }
        }

        stage('Install Windows Exporter') {
            steps {
                powershell '''
                powershell.exe -NoProfile -ExecutionPolicy Bypass `
                    -File ".\\install_windows_exporter.ps1"
                '''
            }
        }

        stage('Verify Windows Exporter Version') {
            steps {
                powershell '''
                powershell.exe -NoProfile -ExecutionPolicy Bypass `
                    -File ".\\verify_version.ps1"
                '''
            }
        }
    }
}
