param (
    [string]$Target = "all",     # "all", "frontend", "backend", "ai"
    [string]$OutputDir = "",     # Thu muc repo dich muon ban DTO sang
    [string]$Package = "vn.integrix.voice.model.gen" # Package Java
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   IX.VOICE CONTRACTS - CODE GENERATOR                    " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$scriptRoot = (Split-Path -Parent $PSScriptRoot).Replace("\", "/")
$schemasDir = "$scriptRoot/schemas"

# 1. Frontend (TypeScript)
if ($Target -eq "all" -or $Target -eq "frontend") {
    $out = if ($OutputDir) { $OutputDir } else { "$scriptRoot/generated/types" }
    if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out -Force | Out-Null }
    Write-Host "[*] Generating TypeScript to: $out" -ForegroundColor Cyan

    npx -y quicktype -s schema -l typescript "$schemasDir/audio_job_v0_1.json" --just-types -o "$out/audio_job_v0_1.gen.ts"
    npx -y quicktype -s schema -l typescript "$schemasDir/transcript_v0_1.json" --just-types -o "$out/transcript_v0_1.gen.ts"
    npx -y quicktype -s schema -l typescript "$schemasDir/analysis_emotion_v0_1.json" --just-types -o "$out/analysis_emotion_v0_1.gen.ts"
    npx -y quicktype -s schema -l typescript "$schemasDir/evidence_qa_v0_1.json" --just-types -o "$out/evidence_qa_v0_1.gen.ts"
    Write-Host "[OK] TypeScript generated!" -ForegroundColor Green
}

# 2. Backend (Java Jackson DTOs)
if ($Target -eq "all" -or $Target -eq "backend") {
    $out = if ($OutputDir) { $OutputDir } else { "$scriptRoot/generated/java" }
    if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out -Force | Out-Null }
    Write-Host "[*] Generating Java DTOs to: $out" -ForegroundColor Cyan

    npx -y quicktype -s schema -l java "$schemasDir/audio_job_v0_1.json" --package $Package -o "$out/AudioJobV01Gen.java"
    npx -y quicktype -s schema -l java "$schemasDir/transcript_v0_1.json" --package $Package -o "$out/TranscriptV01Gen.java"
    Write-Host "[OK] Java DTOs generated!" -ForegroundColor Green
}

# 3. AI Service (Python Pydantic)
if ($Target -eq "all" -or $Target -eq "ai") {
    $out = if ($OutputDir) { $OutputDir } else { "$scriptRoot/generated/python" }
    if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out -Force | Out-Null }
    Write-Host "[*] Generating Python Pydantic models to: $out" -ForegroundColor Cyan

    npx -y quicktype -s schema -l python "$schemasDir/transcript_v0_1.json" --pydantic-base-model -o "$out/transcript_v0_1_gen.py"
    Write-Host "[OK] Python Pydantic models generated!" -ForegroundColor Green
}

Write-Host "`n[OK] Codegen complete!" -ForegroundColor Green
