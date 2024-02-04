$downloadScript = {
  param($message, $url, $path)
  echo $message
  (New-Object Net.WebClient).DownloadFile($url, $path)
}

$desktopPath = [Environment]::GetFolderPath("Desktop")

$username = Read-Host "Your username"
$uuid = [guid]::NewGuid().ToString() -creplace "-", ""

echo "[MAIN] Creating tasks to download required resources..."

$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

$jre = [PowerShell]::Create().AddScript($downloadScript)
              .AddArgument("[TASK] Downloading JRE 21...")
              .AddArgument("https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_windows_hotspot_21.0.2_13.msi")
              .AddArgument("$pwd\OpenJDK21.msi")
$jre.RunspacePool = $runspacePool
$jreRunner = $jre.BeginInvoke()

$launcher = [PowerShell]::Create().AddScript($downloadScript)
              .AddArgument("[TASK] Downloading SKLauncher...")
              .AddArgument("https://skmedix.pl/bin/skl/3.2.5/x64/SKlauncher-3.2.exe")
              .AddArgument("$desktopPath\SKLauncher.exe")
$launcher.RunspacePool = $runspacePool
$launcherRunner = $launcher.BeginInvoke()

$fastPack = [PowerShell]::Create().AddScript($downloadScript)
              .AddArgument("[TASK] Downloading fast packages...")
              .AddArgument("https://github.com/Neurs12/fast-pack/releases/latest/download/fast-pack.zip")
              .AddArgument("$pwd\fast-pack.zip")
$fastPack.RunspacePool = $runspacePool
$fastPackRunner = $fastPack.BeginInvoke()

$jre.EndInvoke($jreRunner)
$launcher.EndInvoke($launcherRunner)
$fastPack.EndInvoke($fastPackRunner)

echo "[MAIN] All tasks done!"
$runspacePool.Close()
$runspacePool.Dispose()

echo "[MAIN] Installing JRE..."
msiexec /i OpenJDK21.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome,FeatureOracleJavaSoft INSTALLDIR="$pwd\jre" /quiet | Out-Null

echo "[MAIN] Applying custom config..."

Expand-Archive "$pwd\fast-pack.zip" -DestinationPath "$env:APPDATA\.minecraft"

$accountContent = Get-Content -Path "$env:APPDATA\.minecraft\SKLauncher\accounts.json" -Raw

$accountContent = $accountContent -creplace "#USERNAME", $username
$accountContent = $accountContent -creplace "#UUID", $uuid
$accountContent = $accountContent -creplace "#REFRESH", ([guid]::NewGuid().ToString() -creplace "-", "")

Set-Content -Path "$env:APPDATA\.minecraft\SKLauncher\accounts.json" -Value $accountContent

echo "[MAIN] Launching SKLauncher..."
."$desktopPath\SKLauncher.exe"
