# Imagefront Framework Installer (PowerShell)
# Similar to GitHub Spec-Kit, this script bootstraps the Imagefront framework in your project

param(
    [string]$TargetDir = ".",
    [string]$Framework = "react",
    [string]$Style = "shadcn/ui",
    [string]$Backend = "agnostic",
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$VERSION = "1.0.0"
$RAW_URL = "https://raw.githubusercontent.com/alexlopespereira/imagefront/main"

# Banner
function Show-Banner {
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Blue
    Write-Host "   IMAGEFRONT - UI-First Development Framework" -ForegroundColor Blue
    Write-Host "   Version $VERSION" -ForegroundColor Blue
    Write-Host "=========================================================" -ForegroundColor Blue
    Write-Host ""
}

# Help
if ($Help) {
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -TargetDir PATH      Target directory (default: current directory)"
    Write-Host "  -Framework NAME      Frontend framework: react|vue|angular|svelte|solid|agnostic (default: react)"
    Write-Host "  -Style NAME          UI style reference (default: shadcn/ui)"
    Write-Host "  -Backend NAME        Backend framework: dotnet|node|python|java|agnostic (default: agnostic)"
    Write-Host "  -Force               Skip confirmation prompts"
    Write-Host "  -Help                Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  iwr -useb https://raw.githubusercontent.com/alexlopespereira/imagefront/main/install.ps1 | iex"
    Write-Host "  .\install.ps1 -Framework vue -Style material"
    Write-Host "  .\install.ps1 -TargetDir my-app -Backend dotnet"
    exit 0
}

Show-Banner

# Resolve target directory
if ($TargetDir -eq ".") {
    $TargetDir = Get-Location
} else {
    $TargetDir = Join-Path (Get-Location) $TargetDir
}

# Check if directory exists and is not empty
if (Test-Path $TargetDir) {
    $items = Get-ChildItem -Path $TargetDir -Force | Where-Object { $_.Name -ne ".git" }
    if ($items.Count -gt 0 -and -not $Force) {
        Write-Host "WARNING: Directory $TargetDir is not empty." -ForegroundColor Yellow
        $response = Read-Host "Continue anyway? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Installation cancelled."
            exit 0
        }
    }
} else {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

Write-Host "Installing Imagefront in: $TargetDir" -ForegroundColor Cyan
Write-Host "   Framework: $Framework" -ForegroundColor Cyan
Write-Host "   Style: $Style" -ForegroundColor Cyan
Write-Host "   Backend: $Backend" -ForegroundColor Cyan
Write-Host ""

# Create directory structure
Write-Host "Creating directory structure..." -ForegroundColor Blue

$directories = @(
    ".imagefront\schemas",
    ".imagefront\templates",
    ".imagefront\prompts",
    ".imagefront\scripts",
    "ui_specs",
    "ux_specs",
    "ui_approvals",
    "ux_approvals",
    "backend_specs\contracts",
    "backend_specs\scaffolds"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $TargetDir $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

Write-Host "[OK] Directories created" -ForegroundColor Green

# Download schemas
Write-Host "Downloading framework files..." -ForegroundColor Blue

function Get-FileIfExists {
    param([string]$Url, [string]$Output)
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Output -UseBasicParsing -ErrorAction SilentlyContinue
    } catch {}
}

$schemas = @("annotation.schema.json", "component-manifest.schema.json", "approval.schema.json",
             "contract.schema.json", "trace.schema.json", "assertion.schema.json")

foreach ($schema in $schemas) {
    $url = "$RAW_URL/schemas/$schema"
    $output = Join-Path $TargetDir ".imagefront\schemas\$schema"
    Get-FileIfExists -Url $url -Output $output
}

# Create placeholder if download failed
$annotationSchema = Join-Path $TargetDir ".imagefront\schemas\annotation.schema.json"
if (-not (Test-Path $annotationSchema)) {
    @{'$schema'="http://json-schema.org/draft-07/schema#"; 'title'="UI Annotation";
      'description'="Schema for UI annotations"} | ConvertTo-Json | Set-Content $annotationSchema
}

Write-Host "[OK] Framework files installed" -ForegroundColor Green

# Create config file
Write-Host "Creating configuration..." -ForegroundColor Blue

$projectName = Split-Path -Leaf $TargetDir
$config = @{
    project = @{ name = $projectName; version = "1.0.0" }
    frontend = @{ framework = $Framework; typescript = $true }
    uiStyle = @{ reference = $Style }
    backend = @{ framework = $Backend }
    gates = @{ uiFreeze = @{ enabled = $true; strictMode = $true } }
}

$configPath = Join-Path $TargetDir ".imagefront\config.json"
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath

Write-Host "[OK] Configuration created" -ForegroundColor Green

# Create IMAGEFRONT.md
Write-Host "Creating IMAGEFRONT.md..." -ForegroundColor Blue

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$readme = "# Imagefront Framework Setup`n`n"
$readme += "This project uses the Imagefront framework for UI-first development.`n`n"
$readme += "## Configuration`n`n- Framework: $Framework`n- Style: $Style`n- Backend: $Backend`n- Installed: $timestamp`n`n"
$readme += "## Quick Start`n`n"
$readme += "Ask Claude Code to:`n"
$readme += "1. Generate a login screen in $Style style`n"
$readme += "2. Annotate all elements`n"
$readme += "3. Create component manifest`n"
$readme += "4. Approve for implementation`n`n"
$readme += "## Documentation`n`n"
$readme += "https://github.com/alexlopespereira/imagefront`n"

$readmePath = Join-Path $TargetDir "IMAGEFRONT.md"
$readme | Set-Content $readmePath -Encoding UTF8

Write-Host "[OK] IMAGEFRONT.md created" -ForegroundColor Green

# Create helper scripts
Write-Host "Creating helper scripts..." -ForegroundColor Blue

$newScreenScript = @'
param([Parameter(Mandatory=$true)][string]$ScreenId)
Write-Host "Creating new screen: $ScreenId"
New-Item -ItemType Directory -Path "ui_specs\$ScreenId\versions" -Force | Out-Null
New-Item -ItemType Directory -Path "ui_specs\$ScreenId\components" -Force | Out-Null
@{screenId=$ScreenId; createdAt=(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"); status="draft"} | ConvertTo-Json | Set-Content "ui_specs\$ScreenId\metadata.json"
Write-Host "[OK] Screen created! Ask Claude to generate UI for $ScreenId" -ForegroundColor Green
'@

$scriptPath = Join-Path $TargetDir ".imagefront\scripts\new-screen.ps1"
$newScreenScript | Set-Content $scriptPath -Encoding UTF8

Write-Host "[OK] Helper scripts created" -ForegroundColor Green

# Success message
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "[SUCCESS] Imagefront framework installed successfully!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Blue
Write-Host "1. cat IMAGEFRONT.md"
Write-Host "2. Ask Claude Code to generate your first screen"
Write-Host ""
Write-Host "Tip: Add IMAGEFRONT.md reference to CLAUDE.md" -ForegroundColor Yellow
Write-Host ""
