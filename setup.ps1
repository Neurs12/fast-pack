echo "Downloading required resources..."
(New-Object Net.WebClient).DownloadFile("https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jre_x86-32_windows_hotspot_17.0.10_7.msi", "$pwd\OpenJDK17.msi")
(New-Object Net.WebClient).DownloadFile("https://skmedix.pl/bin/skl/3.2.5/SKlauncher-3.2.5.jar", "$pwd\SKLauncher.jar")
(New-Object Net.WebClient).DownloadFile("https://github.com/Neurs12/fast-pack/raw/main/fast-pack.zip", "$pwd\fast-pack.zip")

echo "Installing JRE..."
msiexec /i OpenJDK17.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome INSTALLDIR="$pwd\jre" /quiet | Out-Null

echo "Extracting + adding custom packages to \.minecraft..."

Expand-Archive "$pwd\fast-pack.zip" -DestinationPath "$pwd\fast-pack"
if (Test-Path -Path "$env:APPDATA\.minecraft") {
    Copy-Item -Path "$pwd\fast-pack\*" -Destination "$env:APPDATA\.minecraft" -Recurse -Force
} else {
    New-Item -Path "$env:APPDATA\.minecraft" -ItemType Directory -Force
    Copy-Item -Path "$pwd\fast-pack\*" -Destination "$env:APPDATA\.minecraft" -Recurse -Force
}

echo "Launching SKLauncher..."
.\$pwd\jre\bin\java.exe -jar "$pwd\SKLauncher.jar"
