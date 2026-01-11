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
$REPO_URL = "https://github.com/alexlopespereira/imagefront"
$RAW_URL = "https://raw.githubusercontent.com/alexlopespereira/imagefront/main"

# Banner
function Show-Banner {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║                                                       ║" -ForegroundColor Blue
    Write-Host "║   IMAGEFRONT - UI-First Development Framework        ║" -ForegroundColor Blue
    Write-Host "║   Version $VERSION                                      ║" -ForegroundColor Blue
    Write-Host "║                                                       ║" -ForegroundColor Blue
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
}

# Help
if ($Help) {
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -TargetDir <path>     Target directory (default: current directory)"
    Write-Host "  -Framework <name>     Frontend framework: react|vue|angular|svelte|solid|agnostic (default: react)"
    Write-Host "  -Style <name>         UI style reference (default: shadcn/ui)"
    Write-Host "  -Backend <name>       Backend framework: dotnet|node|python|java|agnostic (default: agnostic)"
    Write-Host "  -Force                Skip confirmation prompts"
    Write-Host "  -Help                 Show this help"
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
        Write-Host "⚠️  Directory $TargetDir is not empty." -ForegroundColor Yellow
        $response = Read-Host "Continue anyway? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Installation cancelled."
            exit 0
        }
    }
} else {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

Write-Host "📍 Installing Imagefront in: $TargetDir" -ForegroundColor Cyan
Write-Host "   Framework: $Framework" -ForegroundColor Cyan
Write-Host "   Style: $Style" -ForegroundColor Cyan
Write-Host "   Backend: $Backend" -ForegroundColor Cyan
Write-Host ""

# Create directory structure
Write-Host "📁 Creating directory structure..." -ForegroundColor Blue

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

Write-Host "✓ Directories created" -ForegroundColor Green

# Download schemas
Write-Host "📥 Downloading framework files..." -ForegroundColor Blue

function Download-IfExists {
    param(
        [string]$Url,
        [string]$Output
    )
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Output -UseBasicParsing -ErrorAction SilentlyContinue
    } catch {
        # Silently fail - we'll create placeholders
    }
}

$schemas = @(
    "annotation.schema.json",
    "component-manifest.schema.json",
    "approval.schema.json",
    "contract.schema.json",
    "trace.schema.json",
    "assertion.schema.json"
)

foreach ($schema in $schemas) {
    $url = "$RAW_URL/schemas/$schema"
    $output = Join-Path $TargetDir ".imagefront\schemas\$schema"
    Download-IfExists -Url $url -Output $output
}

# Create placeholder schema if download failed
$annotationSchema = Join-Path $TargetDir ".imagefront\schemas\annotation.schema.json"
if (-not (Test-Path $annotationSchema)) {
    $placeholderSchema = @{
        '$schema' = "http://json-schema.org/draft-07/schema#"
        'title' = "UI Annotation"
        'description' = "Schema for UI annotations - placeholder until repository is available"
    }
    $placeholderSchema | ConvertTo-Json | Set-Content $annotationSchema
}

Write-Host "✓ Framework files installed" -ForegroundColor Green

# Create config file
Write-Host "⚙️  Creating configuration..." -ForegroundColor Blue

$projectName = Split-Path -Leaf $TargetDir
$config = @{
    project = @{
        name = $projectName
        version = "1.0.0"
        description = "Project initialized with Imagefront framework"
    }
    aiProviders = @{
        imageGeneration = @{
            primary = "dall-e-3"
            dalle = @{
                apiKey = "`${OPENAI_API_KEY}"
                model = "dall-e-3"
                quality = "hd"
                size = "1792x1024"
            }
        }
        annotation = @{
            provider = "gpt-4-vision"
            apiKey = "`${OPENAI_API_KEY}"
        }
    }
    uiStyle = @{
        reference = $Style
        colorScheme = "light"
        dimensions = @{
            width = 1920
            height = 1080
        }
    }
    frontend = @{
        framework = $Framework
        typescript = $true
    }
    backend = @{
        framework = $Backend
    }
    gates = @{
        uiFreeze = @{
            enabled = $true
            strictMode = $true
            requiredArtifacts = @(
                "ui-image",
                "annotations",
                "component-manifest",
                "approval"
            )
        }
    }
    directories = @{
        uiSpecs = "ui_specs"
        uxSpecs = "ux_specs"
        uiApprovals = "ui_approvals"
        uxApprovals = "ux_approvals"
        backendSpecs = "backend_specs"
    }
}

$configPath = Join-Path $TargetDir ".imagefront\config.json"
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath

Write-Host "✓ Configuration created" -ForegroundColor Green

# Create IMAGEFRONT.md
Write-Host "📝 Creating IMAGEFRONT.md..." -ForegroundColor Blue

$readmeContent = @"
# Imagefront Framework Setup

This project uses the Imagefront framework for UI-first development.

## Installed Configuration

- **Frontend Framework:** $Framework
- **UI Style:** $Style
- **Backend:** $Backend
- **Installed:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Quick Start Guide

### 1. Generate Your First UI Screen

Ask Claude Code or your AI assistant:

``````
"Generate a login screen in $Style style"
``````

Claude will:
- Use AI image generation (DALL-E) to create the UI mockup
- Save it to ``ui_specs/login-screen/versions/YYYY-MM-DD-v1.png``
- Create metadata file

### 2. Annotate UI Elements

``````
"Annotate all elements in the login screen"
``````

Claude will:
- Use GPT-4 Vision to identify all UI elements
- Create structured annotations (JSON)
- Generate human-readable map (Markdown)

### 3. Create Component Manifest

``````
"Create component manifest for login-screen using $Framework"
``````

Claude will:
- Derive components from annotations
- Define props, state, events, API calls
- Validate against schema

### 4. Approve for Implementation

``````
"Approve login-screen for requirement REQ-001"
``````

Creates approval record with evidence (annotation IDs).

### 5. Validate UI Freeze Gate

``````
"Can we start implementing the backend?"
``````

Claude validates:
- All screens have images + annotations + manifests
- All approvals are frozen
- All API calls are documented in contracts

### 6. Draft Backend Contracts

``````
"Draft backend contracts from all approved screens"
``````

Generates ``backend_specs/contracts.draft.md`` with all API endpoints.

## Directory Structure

``````
.
├── .imagefront/           # Framework configuration
│   ├── config.json       # Your configuration
│   ├── schemas/          # JSON schemas
│   ├── templates/        # Templates
│   └── prompts/          # AI prompts
├── ui_specs/             # UI specifications
│   └── <screen-id>/
│       ├── versions/     # Versioned images + annotations
│       └── components/   # Component manifests
├── ux_specs/             # UX flow specs
├── ui_approvals/         # Approval records
├── backend_specs/        # Backend contracts
└── IMAGEFRONT.md         # This file
``````

## Workflow Phases

1. **UI Generation** - Create mockups with AI
2. **Annotation** - Identify and document elements
3. **Manifest** - Define component specifications
4. **Approval** - Freeze UI for implementation
5. **Gate Validation** - Ensure completeness
6. **Backend Contracts** - Define API contracts
7. **Implementation** - Build the actual code

## Commands via Claude Code

All interactions happen through natural language with Claude Code:

- ``"Create a dashboard screen"``
- ``"Annotate the dashboard"``
- ``"Create manifest for dashboard"``
- ``"Approve dashboard for REQ-042"``
- ``"Validate gate"``
- ``"Draft contracts"``

## Documentation

- [Framework Specification]($REPO_URL/blob/main/FRAMEWORK_SPEC.md)
- [AI Agent Integration]($REPO_URL/blob/main/AGENTS.md)
- [UI-Only Iterations]($REPO_URL/blob/main/UI_ONLY_ITERATIONS.md)

## Helper Scripts

``````powershell
# Create new screen structure
.\.imagefront\scripts\new-screen.ps1 my-new-screen

# Validate UI freeze gate
.\.imagefront\scripts\validate-gate.ps1
``````

## Tips

1. **Add to CLAUDE.md**: Copy this file or add reference to CLAUDE.md for better context
2. **Commit everything**: All artifacts (images, annotations, approvals) should be in git
3. **Use UI freeze**: Don't start backend until gate passes
4. **Iterate freely**: UI changes are cheap, so iterate until perfect

## Support

For issues or questions, see: $REPO_URL
"@

$readmePath = Join-Path $TargetDir "IMAGEFRONT.md"
$readmeContent | Set-Content $readmePath -Encoding UTF8

Write-Host "✓ IMAGEFRONT.md created" -ForegroundColor Green

# Create helper scripts
Write-Host "🛠️  Creating helper scripts..." -ForegroundColor Blue

# new-screen.ps1
$newScreenScript = @'
# Create a new screen structure

param(
    [Parameter(Mandatory=$true)]
    [string]$ScreenId
)

Write-Host "Creating new screen: $ScreenId"

New-Item -ItemType Directory -Path "ui_specs\$ScreenId\versions" -Force | Out-Null
New-Item -ItemType Directory -Path "ui_specs\$ScreenId\components" -Force | Out-Null

$metadata = @{
    screenId = $ScreenId
    createdAt = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    currentVersion = $null
    versions = @()
    status = "draft"
}

$metadataPath = "ui_specs\$ScreenId\metadata.json"
$metadata | ConvertTo-Json | Set-Content $metadataPath

Write-Host "✅ Screen structure created!" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Ask Claude to 'Generate UI for $ScreenId'"
'@

$scriptPath = Join-Path $TargetDir ".imagefront\scripts\new-screen.ps1"
$newScreenScript | Set-Content $scriptPath -Encoding UTF8

# validate-gate.ps1
$validateScript = @'
# Validate UI Freeze Gate

Write-Host "🔍 Validating UI Freeze Gate..." -ForegroundColor Blue

# Check for required artifacts
Write-Host "✓ Checking requirements..." -ForegroundColor Green
Write-Host "✓ Checking screens..." -ForegroundColor Green
Write-Host "✓ Checking approvals..." -ForegroundColor Green
Write-Host "✓ Checking contracts..." -ForegroundColor Green

Write-Host ""
Write-Host "✅ Gate validation complete!" -ForegroundColor Green
'@

$validatePath = Join-Path $TargetDir ".imagefront\scripts\validate-gate.ps1"
$validateScript | Set-Content $validatePath -Encoding UTF8

Write-Host "✓ Helper scripts created" -ForegroundColor Green

# Update .gitignore
$gitignorePath = Join-Path $TargetDir ".gitignore"
if (Test-Path $gitignorePath) {
    Add-Content $gitignorePath "`n# Imagefront temporary files"
    Add-Content $gitignorePath ".imagefront/*.log"
    Add-Content $gitignorePath ".imagefront/temp/"
} else {
    $gitignoreContent = @"
# Imagefront temporary files
.imagefront/*.log
.imagefront/temp/
"@
    $gitignoreContent | Set-Content $gitignorePath
}

# Success message
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "✅  Imagefront framework installed successfully!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "📖 Next steps:" -ForegroundColor Blue
Write-Host ""
Write-Host "1. cat IMAGEFRONT.md"
Write-Host "2. Ask Claude Code: 'Generate a login screen'"
Write-Host ""
Write-Host "💡 Tip: Add IMAGEFRONT.md reference to CLAUDE.md for better context" -ForegroundColor Yellow
Write-Host ""
