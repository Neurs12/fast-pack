$downloadScript = {
  param($message, $url, $path)
  (New-Object Net.WebClient).DownloadFile($url, $path)
  echo $message
}

$desktopPath = [Environment]::GetFolderPath("Desktop")

$username = Read-Host "Your username"
$uuid = [guid]::NewGuid().ToString() -creplace "-", ""

echo "[MAIN] Creating tasks to download required resources..."

$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

echo "[TASK] Downloading JRE 21..."
$jre = [PowerShell]::Create().AddScript($downloadScript)
$jre.AddArgument("[TASK] JRE 21 Downloaded.")
$jre.AddArgument("https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_windows_hotspot_21.0.2_13.msi")
$jre.AddArgument("$pwd\OpenJDK21.msi")
$jre.RunspacePool = $runspacePool
$jre.Streams.Error.Clear()
$jre.Streams.Warning.Clear()
$jre.Streams.Information.Clear()
$jre.Streams.Verbose.Clear()
$jre.Streams.Debug.Clear()
$jreRunner = $jre.BeginInvoke()

echo "[TASK] Downloading SKLauncher..."
$launcher = [PowerShell]::Create().AddScript($downloadScript)
$launcher.AddArgument("[TASK] SKLauncher Downloaded.")
$launcher.AddArgument("https://skmedix.pl/bin/skl/3.2.5/x64/SKlauncher-3.2.exe")
$launcher.AddArgument("$desktopPath\SKLauncher.exe")
$launcher.RunspacePool = $runspacePool
$launcher.Streams.Error.Clear()
$launcher.Streams.Warning.Clear()
$launcher.Streams.Information.Clear()
$launcher.Streams.Verbose.Clear()
$launcher.Streams.Debug.Clear()
$launcherRunner = $launcher.BeginInvoke()

echo "[TASK] Downloading fast packages..."
$fastPack = [PowerShell]::Create().AddScript($downloadScript)
$fastPack.AddArgument("[TASK] Fast packages downloaded.")
$fastPack.AddArgument("https://github.com/Neurs12/fast-pack/releases/latest/download/fast-pack.zip")
$fastPack.AddArgument("$pwd\fast-pack.zip")
$fastPack.RunspacePool = $runspacePool
$fastPack.Streams.Error.Clear()
$fastPack.Streams.Warning.Clear()
$fastPack.Streams.Information.Clear()
$fastPack.Streams.Verbose.Clear()
$fastPack.Streams.Debug.Clear()
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
