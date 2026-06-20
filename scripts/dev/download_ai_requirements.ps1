<#
.SYNOPSIS
Download Python dependencies for the AI service into a local "wheels" folder and clone any git-based deps.

.DESCRIPTION
This helper script prepares an offline cache of Python packages required by project/ai_service.
It will:
  - verify Python is available
  - create a virtual environment at project/ai_service/.venv
  - upgrade pip/setuptools/wheel inside the venv
  - download PyPI packages listed in requirements.txt into project/ai_service/wheels
  - clone git+ URLs listed in requirements.txt into project/ai_service/vendor

USAGE
  powershell -ExecutionPolicy Bypass -File .\scripts\dev\download_ai_requirements.ps1

NOTE
  Some packages (torch, torchvision) provide platform-specific wheels and may require manual selection
  if the automatic download does not return matching files for your platform. For git-based deps
  this script will clone the repository; you may need to install them manually from the cloned folder.
#>

Param()

Set-StrictMode -Version Latest

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-ErrorAndExit($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot "..\..")
$aiDir = Join-Path $repoRoot "project\ai_service"

if (-not (Test-Path $aiDir)) {
	Write-ErrorAndExit "AI service directory not found at: $aiDir"
}

Write-Info "AI service directory: $aiDir"

# Check for python
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
	Write-ErrorAndExit "Python was not found in PATH. Please install Python 3.12+ and re-run this script."
}

Write-Info "Using Python: $($pythonCmd.Path)"

# Create venv
$venvPath = Join-Path $aiDir ".venv"
if (-not (Test-Path $venvPath)) {
	Write-Info "Creating virtual environment at $venvPath"
	& python -m venv $venvPath
	if ($LASTEXITCODE -ne 0) { Write-ErrorAndExit "Failed to create virtual environment" }
} else {
	Write-Info "Virtual environment already exists at $venvPath"
}

$venvPython = Join-Path $venvPath "Scripts\python.exe"
if (-not (Test-Path $venvPython)) { Write-ErrorAndExit "Virtualenv python not found: $venvPython" }

Write-Info "Upgrading pip, setuptools, wheel in venv"
& $venvPython -m pip install --upgrade pip setuptools wheel
if ($LASTEXITCODE -ne 0) { Write-ErrorAndExit "Failed to upgrade pip/setuptools/wheel" }

# Prepare wheels folder
$wheelsDir = Join-Path $aiDir "wheels"
if (-not (Test-Path $wheelsDir)) { New-Item -ItemType Directory -Path $wheelsDir | Out-Null }

# Parse requirements and separate git+ lines
$reqFile = Join-Path $aiDir "requirements.txt"
if (-not (Test-Path $reqFile)) { Write-ErrorAndExit "requirements.txt not found at $reqFile" }

Write-Info "Reading requirements from $reqFile"

$lines = Get-Content $reqFile | Where-Object { -not ([string]::IsNullOrWhiteSpace($_)) }

$gitDeps = @()
$pypiReqs = @()
foreach ($line in $lines) {
	$trim = $line.Trim()
	if ($trim.StartsWith("#")) { continue }
	if ($trim -match "^git\+(.+)$") {
		$gitDeps += $Matches[1]
	} else {
		$pypiReqs += $trim
	}
}

if ($pypiReqs.Count -gt 0) {
	Write-Info "Downloading PyPI packages to $wheelsDir"

	# Write temporary req file containing only PyPI entries
	$tempReq = Join-Path $env:TEMP "fashionai_requirements.txt"
	$pypiReqs | Out-File -FilePath $tempReq -Encoding UTF8

	& $venvPython -m pip download -r $tempReq -d $wheelsDir
	if ($LASTEXITCODE -ne 0) {
		Write-Host "[WARN] pip download returned non-zero exit code. Some packages may have failed to download." -ForegroundColor Yellow
	} else {
		Write-Info "PyPI packages downloaded to $wheelsDir"
	}

	Remove-Item $tempReq -ErrorAction SilentlyContinue
} else {
	Write-Info "No PyPI packages found in requirements.txt"
}

if ($gitDeps.Count -gt 0) {
	# Ensure git available
	$gitCmd = Get-Command git -ErrorAction SilentlyContinue
	if (-not $gitCmd) { Write-Host "[WARN] git not found in PATH. Skipping cloning git+ dependencies." -ForegroundColor Yellow }
	else {
		$vendorDir = Join-Path $aiDir "vendor"
		if (-not (Test-Path $vendorDir)) { New-Item -ItemType Directory -Path $vendorDir | Out-Null }

		foreach ($url in $gitDeps) {
			# Normalize url (strip possible prefix like https://)
			$cleanUrl = $url
			# Derive repo name
			$repoName = [System.IO.Path]::GetFileNameWithoutExtension($cleanUrl.Split('/')[-1])
			$target = Join-Path $vendorDir $repoName
			if (Test-Path $target) {
				Write-Info "Repository already cloned: $repoName"
				continue
			}

			Write-Info "Cloning $cleanUrl -> $target"
			& git clone $cleanUrl $target
			if ($LASTEXITCODE -ne 0) { Write-Host "[WARN] git clone failed for $cleanUrl" -ForegroundColor Yellow }
		}
	}
}

Write-Info "Done. Next steps:\n  1) To install from the downloaded wheels: activate venv then run:\n     pip install --no-index --find-links=./wheels -r requirements.txt\n  2) For git-based dependencies (if any), install from the cloned folders in project/ai_service/vendor or use pip install -e path_to_repo.\n  3) Start the AI service:\n     .\.venv\Scripts\python.exe app.py\n"
