$desktopPath = [Environment]::GetFolderPath("Desktop")

$username = Read-Host "Your username"
$uuid = [guid]::NewGuid().ToString() -creplace "-", ""

echo "Downloading required resources..."
(New-Object Net.WebClient).DownloadFile("https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_windows_hotspot_21.0.2_13.msi", "$pwd\OpenJDK21.msi")
(New-Object Net.WebClient).DownloadFile("https://skmedix.pl/bin/skl/3.2.5/x64/SKlauncher-3.2.exe", "$desktopPath\SKLauncher.exe")
(New-Object Net.WebClient).DownloadFile("https://github.com/Neurs12/fast-pack/releases/latest/download/fast-pack.zip", "$pwd\fast-pack.zip")

echo "Installing JRE..."
msiexec /i OpenJDK21.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome,FeatureOracleJavaSoft INSTALLDIR="$pwd\jre" /quiet | Out-Null

echo "Applying custom config..."

Expand-Archive "$pwd\fast-pack.zip" -DestinationPath "$env:APPDATA\.minecraft"

$accountContent = Get-Content -Path "$env:APPDATA\.minecraft\SKLauncher\accounts.json" -Raw

$accountContent = $accountContent -creplace "#USERNAME", $username
$accountContent = $accountContent -creplace "#UUID", $uuid
$accountContent = $accountContent -creplace "#REFRESH", ([guid]::NewGuid().ToString() -creplace "-", "")

Set-Content -Path "$env:APPDATA\.minecraft\SKLauncher\accounts.json" -Value $accountContent

echo "Launching SKLauncher..."
."$desktopPath\SKLauncher.exe"
