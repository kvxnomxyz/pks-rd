# PackScript & Ducky One-Command Installer
# Run with: irm https://github.com/kvxnomxyz/pks-rd/releases/download/alpha1.0.1/install.ps1 | iex

$ErrorActionPreference = 'Stop'

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Checking Python 3.8+..." -ForegroundColor Cyan
try {
    $pythonVer = python --version 2>&1
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Found: $pythonVer" -ForegroundColor Green
} catch {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ERROR: Python not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Python 3.8+ from: https://www.python.org" -ForegroundColor Yellow
    Write-Host "Enable 'Add Python to PATH' during installation" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Downloading PackScript distribution..." -ForegroundColor Cyan

$tempDir = Join-Path $env:TEMP "packscript-install-$(Get-Random)"
$zipFile = Join-Path $tempDir "preipackscript.zip"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    $url = "https://raw.githubusercontent.com/kvxnomxyz/pks-rd/packages/preipackscript_latest.zip.acpg"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $zipFile -ErrorAction Stop
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ERROR: Failed to download from $url" -ForegroundColor Red
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Details: $($_.Exception.Message)" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Extracting and running installer..." -ForegroundColor Cyan

try {
    $extractPath = Join-Path $tempDir "psk2"
    Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force -ErrorAction Stop
    
    $installerScript = Join-Path $extractPath "psk2" "installer" "aio_installer.py"
    if (-not (Test-Path $installerScript)) {
        $installerScript = Join-Path $extractPath "installer" "aio_installer.py"
    }
    
    & python $installerScript --cli
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Installation complete!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Installation failed" -ForegroundColor Red
        pause
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ERROR: $_" -ForegroundColor Red
    pause
    exit 1
} finally {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
