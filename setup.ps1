echo "Downloading required resources..."
(New-Object Net.WebClient).DownloadFile("https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_windows_hotspot_21.0.2_13.msi", "$pwd\OpenJDK21.msi")
(New-Object Net.WebClient).DownloadFile("https://skmedix.pl/bin/skl/3.2.5/x64/SKlauncher-3.2.exe", "$pwd\SKLauncher.exe")
(New-Object Net.WebClient).DownloadFile("https://github.com/Neurs12/fast-pack/raw/main/fast-pack.zip", "$pwd\fast-pack.zip")

echo "Installing JRE..."
msiexec /i OpenJDK21.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome,FeatureOracleJavaSoft INSTALLDIR="$pwd\jre" /quiet | Out-Null

echo "Extracting + adding custom packages to \.minecraft..."

Expand-Archive "$pwd\fast-pack.zip" -DestinationPath "$pwd\fast-pack"
if (Test-Path -Path "$env:APPDATA\.minecraft") {
    Copy-Item -Path "$pwd\fast-pack\*" -Destination "$env:APPDATA\.minecraft" -Recurse -Force
} else {
    New-Item -Path "$env:APPDATA\.minecraft" -ItemType Directory -Force
    Copy-Item -Path "$pwd\fast-pack\*" -Destination "$env:APPDATA\.minecraft" -Recurse -Force
}

$env:EXE4J_JAVA_HOME += ";$pwd\jre\bin"

echo "Launching SKLauncher..."
."$pwd\SKLauncher"
