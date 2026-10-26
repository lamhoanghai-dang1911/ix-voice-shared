param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("frontend", "backend", "ai")]
    [string]$Role,

    [string]$TargetDir = "."
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   INTEGRIX IX.VOICE - ROLE ENVIRONMENT SETUP WIZARD      " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

if (-not $Role) {
    Write-Host "`nChon role ban muon thiet lap moi truong:" -ForegroundColor Yellow
    Write-Host "  1. Frontend (React / TypeScript)" -ForegroundColor White
    Write-Host "  2. Backend (Java 21 / Spring Boot 3)" -ForegroundColor White
    Write-Host "  3. AI Service (Python / Speech AI)" -ForegroundColor White
    $c = Read-Host "Nhap lua chon (1/2/3)"
    switch ($c) {
        "1" { $Role = "frontend" }
        "2" { $Role = "backend" }
        "3" { $Role = "ai" }
        default { $Role = "frontend" }
    }
}

$scriptDir = (Split-Path -Parent $PSScriptRoot).Replace("\", "/")
$currentLoc = (Get-Location).Path.Replace("\", "/")
if ($currentLoc.EndsWith("/devkit/scripts")) {
    $targetAbs = (Resolve-Path "../..").Path.Replace("\", "/")
} elseif ($currentLoc.EndsWith("/devkit")) {
    $targetAbs = (Resolve-Path "..").Path.Replace("\", "/")
} else {
    $targetAbs = (Resolve-Path $TargetDir).Path.Replace("\", "/")
}

Write-Host "`n[*] Role duoc chon: $Role" -ForegroundColor Green
Write-Host "[*] Thu muc repo muc tieu: $targetAbs" -ForegroundColor Green

# Ensure target .github/workflows directory exists
$workflowDir = "$targetAbs/.github/workflows"
if (-not (Test-Path $workflowDir)) {
    New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
}

switch ($Role) {
    "frontend" {
        Write-Host "`n[1/4] Sinh TypeScript DTOs vao $targetAbs/src/types..." -ForegroundColor Cyan
        powershell -ExecutionPolicy Bypass -File "$scriptDir/scripts/codegen.ps1" -Target frontend -OutputDir "$targetAbs/src/types"

        Write-Host "`n[2/4] Khoi tao file .env & .env.example cho Frontend..." -ForegroundColor Cyan
        $envFe = "VITE_API_BASE_URL=http://localhost:8080/api/v1`nVITE_ENABLE_MOCK_FALLBACK=true"
        Set-Content -Path "$targetAbs/.env.example" -Value $envFe -Encoding utf8
        if (-not (Test-Path "$targetAbs/.env")) {
            Set-Content -Path "$targetAbs/.env" -Value $envFe -Encoding utf8
        }

        Write-Host "`n[3/4] Cai dat GitHub Actions CI template cho Frontend..." -ForegroundColor Cyan
        Copy-Item "$scriptDir/ci-templates/github-ci-frontend.yml" "$workflowDir/ci.yml" -Force
        Write-Host "[OK] CI pipeline da cai vao $workflowDir/ci.yml" -ForegroundColor Green

        Write-Host "`n[4/4] Huong dan chay ngay khong can cai Java:" -ForegroundColor Yellow
        Write-Host "  1. Chay Frontend React:" -ForegroundColor White
        Write-Host "     npm run dev" -ForegroundColor Green
        Write-Host "  2. Bat Mock Backend (tra cuu fixtures chuan):" -ForegroundColor White
        Write-Host "     node $scriptDir/environments/frontend-env/mock-backend-server.js" -ForegroundColor Green
    }

    "backend" {
        Write-Host "`n[1/4] Sinh Java DTOs vao $targetAbs/src/main/java/vn/integrix/voice/model..." -ForegroundColor Cyan
        powershell -ExecutionPolicy Bypass -File "$scriptDir/scripts/codegen.ps1" -Target backend -OutputDir "$targetAbs/src/main/java/vn/integrix/voice/model"

        Write-Host "`n[2/4] Khoi tao file .env & .env.example cho Backend..." -ForegroundColor Cyan
        $envBe = "BACKEND_PORT=8080`nSPRING_THREADS_VIRTUAL_ENABLED=true`nAI_SERVICE_URL=http://localhost:5000`nSTORAGE_LOCAL_DIR=./data/storage"
        Set-Content -Path "$targetAbs/.env.example" -Value $envBe -Encoding utf8
        if (-not (Test-Path "$targetAbs/.env")) {
            Set-Content -Path "$targetAbs/.env" -Value $envBe -Encoding utf8
        }

        Write-Host "`n[3/4] Cai dat GitHub Actions CI template cho Backend..." -ForegroundColor Cyan
        Copy-Item "$scriptDir/ci-templates/github-ci-backend.yml" "$workflowDir/ci.yml" -Force
        Write-Host "[OK] CI pipeline da cai vao $workflowDir/ci.yml" -ForegroundColor Green

        Write-Host "`n[4/4] Huong dan chay ngay khong can cai Python/GPU:" -ForegroundColor Yellow
        Write-Host "  1. Chay Backend Spring Boot:" -ForegroundColor White
        Write-Host "     mvn spring-boot:run" -ForegroundColor Green
        Write-Host "  2. Bat Mock AI Service:" -ForegroundColor White
        Write-Host "     node $scriptDir/environments/backend-env/mock-ai-server.js" -ForegroundColor Green
        Write-Host "  3. Bat PostgreSQL 16 dung san:" -ForegroundColor White
        Write-Host "     docker compose -f $scriptDir/environments/backend-env/docker-compose.postgres.yml up -d" -ForegroundColor Green
    }

    "ai" {
        Write-Host "`n[1/4] Sinh Python Pydantic Models vao $targetAbs/app/models..." -ForegroundColor Cyan
        powershell -ExecutionPolicy Bypass -File "$scriptDir/scripts/codegen.ps1" -Target ai -OutputDir "$targetAbs/app/models"

        Write-Host "`n[2/4] Khoi tao file .env & .env.example cho AI Service..." -ForegroundColor Cyan
        $envAi = "AI_SERVICE_PORT=5000`nPIPELINE_MODE=real`nDEVICE=cpu`nCOMPUTE_TYPE=int8`nHF_MODEL_ID=ntgiaky/faster-PhoWhisper-small"
        Set-Content -Path "$targetAbs/.env.example" -Value $envAi -Encoding utf8
        if (-not (Test-Path "$targetAbs/.env")) {
            Set-Content -Path "$targetAbs/.env" -Value $envAi -Encoding utf8
        }

        Write-Host "`n[3/4] Cai dat GitHub Actions CI template cho AI Service..." -ForegroundColor Cyan
        Copy-Item "$scriptDir/ci-templates/github-ci-ai.yml" "$workflowDir/ci.yml" -Force
        Write-Host "[OK] CI pipeline da cai vao $workflowDir/ci.yml" -ForegroundColor Green

        Write-Host "`n[4/4] Huong dan khoi chay AI Service:" -ForegroundColor Yellow
        Write-Host "  1. Tai cache Model PhoWhisper:" -ForegroundColor White
        Write-Host "     python $scriptDir/scripts/download_model.py" -ForegroundColor Green
        Write-Host "  2. Chay FastAPI:" -ForegroundColor White
        Write-Host "     uvicorn app.main:app --host 0.0.0.0 --port 5000 --reload" -ForegroundColor Green
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   SETUP MOI TRUONG CHO ROLE $Role THANH CONG!            " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
