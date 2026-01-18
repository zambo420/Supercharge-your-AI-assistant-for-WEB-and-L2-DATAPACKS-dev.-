# Skills Setup Script (Windows)
# Copy this file to your project: skills/setup.ps1
# Run: .\skills\setup.ps1

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

Write-Host "AI Skills Setup" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan
Write-Host ""

# Count skills
$SkillCount = (Get-ChildItem -Path $ScriptDir -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count
Write-Host "Found $SkillCount skills to configure" -ForegroundColor Blue
Write-Host ""

# Check if AGENTS.md exists
$agentsMd = Join-Path $RepoRoot "AGENTS.md"
if (-not (Test-Path $agentsMd)) {
    Write-Host "ERROR: AGENTS.md not found in project root!" -ForegroundColor Red
    Write-Host "Create AGENTS.md first, then run this script." -ForegroundColor Yellow
    exit 1
}

# Claude Code
function Setup-Claude {
    Write-Host "Configuring Claude Code..." -ForegroundColor Yellow
    $claudeDir = Join-Path $RepoRoot ".claude"
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
    
    $skillsTarget = Join-Path $claudeDir "skills"
    if (Test-Path $skillsTarget) { Remove-Item -Recurse -Force $skillsTarget }
    Copy-Item -Recurse $ScriptDir $skillsTarget
    Write-Host "  + .claude/skills/" -ForegroundColor Green
    
    Copy-Item $agentsMd (Join-Path $claudeDir "CLAUDE.md")
    Write-Host "  + .claude/CLAUDE.md" -ForegroundColor Green
}

# Gemini CLI / Antigravity
function Setup-Gemini {
    Write-Host "Configuring Gemini/Antigravity..." -ForegroundColor Yellow
    $geminiDir = Join-Path $RepoRoot ".gemini"
    New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null
    
    $skillsTarget = Join-Path $geminiDir "skills"
    if (Test-Path $skillsTarget) { Remove-Item -Recurse -Force $skillsTarget }
    Copy-Item -Recurse $ScriptDir $skillsTarget
    Write-Host "  + .gemini/skills/" -ForegroundColor Green
    
    Copy-Item $agentsMd (Join-Path $geminiDir "GEMINI.md")
    Write-Host "  + .gemini/GEMINI.md" -ForegroundColor Green
}

# GitHub Copilot
function Setup-Copilot {
    Write-Host "Configuring GitHub Copilot..." -ForegroundColor Yellow
    $githubDir = Join-Path $RepoRoot ".github"
    New-Item -ItemType Directory -Force -Path $githubDir | Out-Null
    
    Copy-Item $agentsMd (Join-Path $githubDir "copilot-instructions.md")
    Write-Host "  + .github/copilot-instructions.md" -ForegroundColor Green
}

# Run all setups
Setup-Claude
Setup-Gemini
Setup-Copilot

Write-Host ""
Write-Host "Done! $SkillCount skills configured." -ForegroundColor Green
Write-Host ""
Write-Host "Configured:" -ForegroundColor Cyan
Write-Host "  - Claude Code:        .claude/skills/ + CLAUDE.md"
Write-Host "  - Gemini/Antigravity: .gemini/skills/ + GEMINI.md"
Write-Host "  - GitHub Copilot:     .github/copilot-instructions.md"
Write-Host ""
Write-Host "Restart your AI assistant to load the skills." -ForegroundColor Yellow
