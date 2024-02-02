echo "Downloading required resources..."
(New-Object Net.WebClient).DownloadFile("https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jre_x86-32_windows_hotspot_17.0.10_7.msi", "$pwd\OpenJDK17.exe")
(New-Object Net.WebClient).DownloadFile("https://skmedix.pl/bin/skl/3.2.5/x64/SKlauncher-3.2.exe", "$pwd\SKLauncher.exe")
(New-Object Net.WebClient).DownloadFile("https://github.com/Neurs12/fast-pack/raw/main/fast-pack.zip", "$pwd\fast-pack.zip")

echo "Installing JRE..."
msiexec /i OpenJDK17.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet

echo "Extracting + adding custom packages to \.minecraft..."

Expand-Archive "$pwd\fast-pack.zip" -DestinationPath "$pwd\fast-pack"
if (Test-Path -Path "%appdata%\.minecraft") {
    Copy-Item -Path "$pwd\fast-pack\*" -Destination "%appdata%\.minecraft" -Recurse -Force
} else {
    New-Item -Path "%appdata%\.minecraft" -ItemType Directory -Force
    Copy-Item -Path "$pwd\fast-pack\*" -Destination "%appdata%\.minecraft" -Recurse -Force
}