$downloadScript = {
  param($url, $path)
  (New-Object Net.WebClient).DownloadFile($url, $path)
}

$desktopPath = [Environment]::GetFolderPath("Desktop")

$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

$username = Read-Host "Your username"
$uuid = [guid]::NewGuid().ToString() -creplace "-", ""

echo "[MAIN] Creating tasks to download required resources..."

echo "[TASK] Downloading JRE 21..."
$jre = [PowerShell]::Create().AddScript($downloadScript)
$jre.AddArgument("https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_windows_hotspot_21.0.2_13.msi")
$jre.AddArgument("$pwd\OpenJDK21.msi")
$jre.RunspacePool = $runspacePool
$jreRunner = $jre.BeginInvoke()

echo "[TASK] Downloading SKLauncher..."
$launcher = [PowerShell]::Create().AddScript($downloadScript)
$launcher.AddArgument("https://skmedix.pl/bin/skl/3.2.5/x64/SKlauncher-3.2.exe")
$launcher.AddArgument("$desktopPath\SKLauncher.exe")
$launcher.RunspacePool = $runspacePool
$launcherRunner = $launcher.BeginInvoke()

echo "[TASK] Downloading fast packages..."
$fastPack = [PowerShell]::Create().AddScript($downloadScript)
$fastPack.AddArgument("https://r2.ficky.click/fast-packages.zip")
$fastPack.AddArgument("$pwd\fast-pack.zip")
$fastPack.RunspacePool = $runspacePool
$fastPackRunner = $fastPack.BeginInvoke()

$jre.EndInvoke($jreRunner)
$launcher.EndInvoke($launcherRunner)
$fastPack.EndInvoke($fastPackRunner)

echo "[MAIN] All download tasks done!"

echo "[TASK] Installing JRE..."
$installJre = [PowerShell]::Create().AddScript('msiexec /i OpenJDK21.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome,FeatureOracleJavaSoft INSTALLDIR="{0}\jre" /quiet | Out-Null' -f $pwd)
$installJre.RunspacePool = $runspacePool
$installJreRunner = $installJre.BeginInvoke()

echo "[TASK] Extracting config..."
$applyPack = [PowerShell]::Create().AddScript('Expand-Archive "{0}\fast-pack.zip" -DestinationPath "$env:APPDATA\.minecraft"' -f $pwd)
$applyPack.RunspacePool = $runspacePool
$applyPackRunner = $applyPack.BeginInvoke()

$installJre.EndInvoke($installJreRunner)
$applyPack.EndInvoke($applyPackRunner)

$runspacePool.Close()
$runspacePool.Dispose()

echo "[MAIN] System configuration done!"

echo "[MAIN] Applying username profile..."

$accountContent = Get-Content -Path "$env:APPDATA\.minecraft\SKLauncher\accounts.json" -Raw

$accountContent = $accountContent -creplace "#USERNAME", $username
$accountContent = $accountContent -creplace "#UUID", $uuid
$accountContent = $accountContent -creplace "#REFRESH", ([guid]::NewGuid().ToString() -creplace "-", "")

Set-Content -Path "$env:APPDATA\.minecraft\SKLauncher\accounts.json" -Value $accountContent

echo "[MAIN] Launching SKLauncher..."
."$desktopPath\SKLauncher.exe"

echo "[MAIN] All tasks done!"
