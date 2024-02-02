$username = Read-Host "Your username"
$uuid = [guid]::NewGuid().ToString() -creplace "-", ""

echo "Downloading required resources..."
(New-Object Net.WebClient).DownloadFile("https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_windows_hotspot_21.0.2_13.msi", "$pwd\OpenJDK21.msi")
(New-Object Net.WebClient).DownloadFile("https://skmedix.pl/bin/skl/3.2.5/x64/SKlauncher-3.2.exe", "$pwd\SKLauncher.exe")
(New-Object Net.WebClient).DownloadFile("https://fpack.pages.dev/fast-pack.zip", "$pwd\fast-pack.zip")

echo "Installing JRE..."
msiexec /i OpenJDK21.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome,FeatureOracleJavaSoft INSTALLDIR="$pwd\jre" /quiet | Out-Null

echo "Extracting + adding custom config to \.minecraft..."

Expand-Archive "$pwd\fast-pack.zip" -DestinationPath "$pwd\fast-pack"

$accountContent = Get-Content -Path "$pwd\fast-pack\SKLauncher\accounts.json" -Raw

$accountContent = $accountContent -creplace "#USERNAME", $username
$accountContent = $accountContent -creplace "#UUID", $uuid
$accountContent = $accountContent -creplace "#REFRESH", ([guid]::NewGuid().ToString() -creplace "-", "")

Set-Content -Path "$pwd\fast-pack\SKLauncher\accounts.json" -Value $accountContent

if (Test-Path -Path "$env:APPDATA\.minecraft") {
    Copy-Item -Path "$pwd\fast-pack\*" -Destination "$env:APPDATA\.minecraft" -Recurse -Force
} else {
    New-Item -Path "$env:APPDATA\.minecraft" -ItemType Directory -Force
    Copy-Item -Path "$pwd\fast-pack\*" -Destination "$env:APPDATA\.minecraft" -Recurse -Force
}

echo "Launching SKLauncher..."
."$pwd\SKLauncher"
