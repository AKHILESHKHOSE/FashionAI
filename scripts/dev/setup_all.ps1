<#
Setup all project dependencies (AI service Python deps + backend/frontend npm deps).

This script performs non-destructive install steps:
  - Verifies Python and Node are available
  - Runs download_ai_requirements.ps1 to prepare wheels and vendor
  - Installs Python requirements into project/ai_service/.venv from cached wheels
  - Runs npm install in project/backend and project/frontend

Usage:
  powershell -ExecutionPolicy Bypass -File .\scripts\dev\setup_all.ps1

Note: This script does not start the services. After completion you can start the services manually:
  - AI: .\project\ai_service\.venv\Scripts\python.exe app.py
  - Backend: cd project\backend; npm run dev
  - Frontend: cd project\frontend; npm run dev
#>

Set-StrictMode -Version Latest

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-ErrorAndExit($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }

$repoRoot = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\..")
Write-Info "Repository root: $repoRoot"

# Check Python
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) { Write-ErrorAndExit "Python not found in PATH. Install Python 3.12+ and re-run this script." }
Write-Info "Python found: $($pythonCmd.Path)"

# Check Node
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) { Write-Warn "Node.js not found in PATH. Backend/frontend npm installs will be skipped." }
else { Write-Info "Node found: $($nodeCmd.Path)" }

# Run download_ai_requirements.ps1
$downloadScript = Join-Path $repoRoot "scripts\dev\download_ai_requirements.ps1"
if (-not (Test-Path $downloadScript)) { Write-ErrorAndExit "Helper download script not found: $downloadScript" }

Write-Info "Running download_ai_requirements.ps1"
& powershell -NoProfile -ExecutionPolicy Bypass -File $downloadScript
if ($LASTEXITCODE -ne 0) { Write-Warn "download_ai_requirements.ps1 returned non-zero exit code. Check output above." }

# Install Python requirements into venv from wheels
$aiDir = Join-Path $repoRoot "project\ai_service"
$venvPython = Join-Path $aiDir ".venv\Scripts\python.exe"
if (Test-Path $venvPython) {
	Write-Info "Installing Python packages from cached wheels into venv"
	Push-Location $aiDir
	& $venvPython -m pip install --no-index --find-links=./wheels -r requirements.txt
	if ($LASTEXITCODE -ne 0) { Write-Warn "pip install returned non-zero exit code. Some packages may have failed to install." }
	Pop-Location
} else {
	Write-Warn "Virtualenv python not found at $venvPython. Skipping pip install."
}

# Install backend/frontend npm deps
if ($nodeCmd) {
	$backendDir = Join-Path $repoRoot "project\backend"
	if (Test-Path $backendDir) {
		Write-Info "Running npm install in project/backend"
		Push-Location $backendDir
		npm install
		if ($LASTEXITCODE -ne 0) { Write-Warn "npm install failed in backend" }
		Pop-Location
	}

	$frontendDir = Join-Path $repoRoot "project\frontend"
	if (Test-Path $frontendDir) {
		Write-Info "Running npm install in project/frontend"
		Push-Location $frontendDir
		npm install
		if ($LASTEXITCODE -ne 0) { Write-Warn "npm install failed in frontend" }
		Pop-Location
	}
} else {
	Write-Warn "Skipping npm installs because Node.js was not found." 
}

Write-Info "Setup complete. Start services manually as needed. See README for commands."
