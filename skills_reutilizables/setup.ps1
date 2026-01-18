# Master Skills Setup Script (Windows)
# Run: .\skills\setup.ps1
#
# This script synchronizes skills from:
# 1. Root skills/ folder (master skills)
# 2. Java decompilado/skills/ folder (development skills)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SourceSkillsDir = Join-Path $RepoRoot "Java decompilado\skills"

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   Master AI Skills Setup - Lucera2 Project" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Count skills from both locations
$MasterSkillCount = (Get-ChildItem -Path $ScriptDir -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count
$SourceSkillCount = 0
if (Test-Path $SourceSkillsDir) {
    $SourceSkillCount = (Get-ChildItem -Path $SourceSkillsDir -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count
}

Write-Host "Found $MasterSkillCount master skills in skills/" -ForegroundColor Blue
Write-Host "Found $SourceSkillCount development skills in Java decompilado/skills/" -ForegroundColor Blue
Write-Host ""

# Check if AGENTS.md exists
$agentsMd = Join-Path $RepoRoot "AGENTS.md"
if (-not (Test-Path $agentsMd)) {
    Write-Host "ERROR: AGENTS.md not found in project root!" -ForegroundColor Red
    Write-Host "Expected path: $agentsMd" -ForegroundColor Yellow
    exit 1
}

Write-Host "AGENTS.md found: $agentsMd" -ForegroundColor Green
Write-Host ""

# Merge skills from source to master
function Merge-SourceSkills {
    if (-not (Test-Path $SourceSkillsDir)) {
        Write-Host "Source skills directory not found, skipping merge." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Merging development skills to master..." -ForegroundColor Yellow
    
    $sourceSkills = Get-ChildItem -Path $SourceSkillsDir -Directory
    foreach ($skill in $sourceSkills) {
        $skillName = $skill.Name
        $targetDir = Join-Path $ScriptDir $skillName
        
        # Skip if already exists (master takes priority)
        if (Test-Path $targetDir) {
            continue
        }
        
        # Copy skill to master
        Copy-Item -Recurse $skill.FullName $targetDir
        Write-Host "  + Merged: $skillName" -ForegroundColor Green
    }
}

# Claude Code
function Setup-Claude {
    Write-Host "Configuring Claude Code..." -ForegroundColor Yellow
    $claudeDir = Join-Path $RepoRoot ".claude"
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
    
    # Copy skills folder
    $skillsTarget = Join-Path $claudeDir "skills"
    if (Test-Path $skillsTarget) { Remove-Item -Recurse -Force $skillsTarget }
    Copy-Item -Recurse $ScriptDir $skillsTarget
    Write-Host "  + .claude/skills/" -ForegroundColor Green
    
    # Copy AGENTS.md as CLAUDE.md
    Copy-Item $agentsMd (Join-Path $claudeDir "CLAUDE.md")
    Write-Host "  + .claude/CLAUDE.md" -ForegroundColor Green
}

# Gemini CLI / Antigravity
function Setup-Gemini {
    Write-Host "Configuring Gemini/Antigravity..." -ForegroundColor Yellow
    $geminiDir = Join-Path $RepoRoot ".gemini"
    New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null
    
    # Copy skills folder
    $skillsTarget = Join-Path $geminiDir "skills"
    if (Test-Path $skillsTarget) { Remove-Item -Recurse -Force $skillsTarget }
    Copy-Item -Recurse $ScriptDir $skillsTarget
    Write-Host "  + .gemini/skills/" -ForegroundColor Green
    
    # Copy AGENTS.md as GEMINI.md
    Copy-Item $agentsMd (Join-Path $geminiDir "GEMINI.md")
    Write-Host "  + .gemini/GEMINI.md" -ForegroundColor Green
}

# GitHub Copilot
function Setup-Copilot {
    Write-Host "Configuring GitHub Copilot..." -ForegroundColor Yellow
    $githubDir = Join-Path $RepoRoot ".github"
    New-Item -ItemType Directory -Force -Path $githubDir | Out-Null
    
    # Copy AGENTS.md as copilot-instructions.md
    Copy-Item $agentsMd (Join-Path $githubDir "copilot-instructions.md")
    Write-Host "  + .github/copilot-instructions.md" -ForegroundColor Green
}

# Run all setups
Write-Host ""
Merge-SourceSkills
Write-Host ""
Setup-Claude
Write-Host ""
Setup-Gemini
Write-Host ""
Setup-Copilot

# Recount after merge
$TotalSkills = (Get-ChildItem -Path $ScriptDir -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "   Done! $TotalSkills total skills configured." -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Configured for:" -ForegroundColor Cyan
Write-Host "  - Claude Code:        .claude/skills/ + CLAUDE.md"
Write-Host "  - Gemini/Antigravity: .gemini/skills/ + GEMINI.md"
Write-Host "  - GitHub Copilot:     .github/copilot-instructions.md"
Write-Host ""
Write-Host "Restart your AI assistant to load the skills." -ForegroundColor Yellow
Write-Host ""
