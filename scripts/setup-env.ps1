param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("frontend", "backend", "ai")]
    [string]$Role,

    [switch]$Init,

    [switch]$StartMock,

    [string]$TargetDir = "."
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   INTEGRIX IX.VOICE - 1-CLICK PLATFORM BOOTSTRAP WIZARD " -ForegroundColor Yellow
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

# Auto-detect directories
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
Write-Host "[*] Shared DevKit: $scriptDir" -ForegroundColor Green
Write-Host "[*] Thu muc repo dich: $targetAbs" -ForegroundColor Green

# Ensure target .github/workflows directory exists
$workflowDir = "$targetAbs/.github/workflows"
if (-not (Test-Path $workflowDir)) {
    New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
}

switch ($Role) {
    "frontend" {
        Write-Host "`n[1/5] Cau hinh Dockerfile & Nginx chuan cho Frontend..." -ForegroundColor Cyan
        if ($Init -or (-not (Test-Path "$targetAbs/Dockerfile"))) {
            Copy-Item "$scriptDir/dockerfiles/Dockerfile.frontend" "$targetAbs/Dockerfile" -Force
            Write-Host "  -> [OK] Da sao chep Dockerfile vao thu muc goc." -ForegroundColor Green
        }
        if ($Init -or (-not (Test-Path "$targetAbs/nginx.conf"))) {
            Copy-Item "$scriptDir/nginx/nginx.conf" "$targetAbs/nginx.conf" -Force
            Write-Host "  -> [OK] Da sao chep nginx.conf vao thu muc goc." -ForegroundColor Green
        }

        Write-Host "`n[2/5] Cai dat GitHub Actions CI/CD Pipeline..." -ForegroundColor Cyan
        Copy-Item "$scriptDir/ci-templates/github-ci-frontend.yml" "$workflowDir/ci.yml" -Force
        Write-Host "  -> [OK] CI/CD Enterprise da san sang tai $workflowDir/ci.yml" -ForegroundColor Green

        Write-Host "`n[3/5] Sinh TypeScript DTOs tu Schemas vao $targetAbs/src/types..." -ForegroundColor Cyan
        powershell -ExecutionPolicy Bypass -File "$scriptDir/scripts/codegen.ps1" -Target frontend -OutputDir "$targetAbs/src/types"

        Write-Host "`n[4/5] Khoi tao file .env & .env.example cho Frontend..." -ForegroundColor Cyan
        $envFe = "VITE_API_BASE_URL=http://localhost:8080/api/v1`nVITE_ENABLE_MOCK_FALLBACK=true"
        Set-Content -Path "$targetAbs/.env.example" -Value $envFe -Encoding utf8
        if (-not (Test-Path "$targetAbs/.env")) {
            Set-Content -Path "$targetAbs/.env" -Value $envFe -Encoding utf8
            Write-Host "  -> [OK] Da tao file .env" -ForegroundColor Green
        }

        Write-Host "`n[5/5] Huong dan chay ngay:" -ForegroundColor Yellow
        Write-Host "  1. Chay Frontend React:" -ForegroundColor White
        Write-Host "     npm run dev" -ForegroundColor Green
        Write-Host "  2. Bat Mock Backend Server (port 8080 co Swagger):" -ForegroundColor White
        Write-Host "     node $scriptDir/environments/frontend-env/mock-backend-server.js" -ForegroundColor Green

        if ($StartMock) {
            Write-Host "`n[⚡] Dang khoi dong Mock Backend Server tren port 8080..." -ForegroundColor Cyan
            Start-Process node -ArgumentList "$scriptDir/environments/frontend-env/mock-backend-server.js"
        }
    }

    "backend" {
        Write-Host "`n[1/5] Cau hinh Dockerfile Java 21 Temurin chuan cho Backend..." -ForegroundColor Cyan
        if ($Init -or (-not (Test-Path "$targetAbs/Dockerfile"))) {
            Copy-Item "$scriptDir/dockerfiles/Dockerfile.backend" "$targetAbs/Dockerfile" -Force
            Write-Host "  -> [OK] Da sao chep Dockerfile vao thu muc goc." -ForegroundColor Green
        }

        Write-Host "`n[2/5] Cai dat GitHub Actions CI/CD Pipeline..." -ForegroundColor Cyan
        Copy-Item "$scriptDir/ci-templates/github-ci-backend.yml" "$workflowDir/ci.yml" -Force
        Write-Host "  -> [OK] CI/CD Enterprise da san sang tai $workflowDir/ci.yml" -ForegroundColor Green

        Write-Host "`n[3/5] Sinh Java DTOs tu Schemas vao $targetAbs/src/main/java/vn/integrix/voice/model/gen..." -ForegroundColor Cyan
        powershell -ExecutionPolicy Bypass -File "$scriptDir/scripts/codegen.ps1" -Target backend -OutputDir "$targetAbs/src/main/java/vn/integrix/voice/model/gen"

        Write-Host "`n[4/5] Khoi tao file .env & .env.example cho Backend..." -ForegroundColor Cyan
        $envBe = "BACKEND_PORT=8080`nSPRING_THREADS_VIRTUAL_ENABLED=true`nAI_SERVICE_URL=http://localhost:5000`nSTORAGE_LOCAL_DIR=./data/storage"
        Set-Content -Path "$targetAbs/.env.example" -Value $envBe -Encoding utf8
        if (-not (Test-Path "$targetAbs/.env")) {
            Set-Content -Path "$targetAbs/.env" -Value $envBe -Encoding utf8
            Write-Host "  -> [OK] Da tao file .env" -ForegroundColor Green
        }

        Write-Host "`n[5/5] Huong dan chay ngay:" -ForegroundColor Yellow
        Write-Host "  1. Chay Backend Spring Boot:" -ForegroundColor White
        Write-Host "     mvn spring-boot:run" -ForegroundColor Green
        Write-Host "  2. Bat Docker PostgreSQL + Mock AI (port 5000):" -ForegroundColor White
        Write-Host "     docker compose -f $scriptDir/environments/backend-env/docker-compose.postgres.yml up -d" -ForegroundColor Green
        Write-Host "     node $scriptDir/environments/backend-env/mock-ai-server.js" -ForegroundColor Green

        if ($StartMock) {
            Write-Host "`n[⚡] Dang khoi dong Docker PostgreSQL & Mock AI..." -ForegroundColor Cyan
            docker compose -f "$scriptDir/environments/backend-env/docker-compose.postgres.yml" up -d
            Start-Process node -ArgumentList "$scriptDir/environments/backend-env/mock-ai-server.js"
        }
    }

    "ai" {
        Write-Host "`n[1/5] Cau hinh Dockerfile Python 3.10 + PyTorch chuan cho AI..." -ForegroundColor Cyan
        if ($Init -or (-not (Test-Path "$targetAbs/Dockerfile"))) {
            Copy-Item "$scriptDir/dockerfiles/Dockerfile.ai" "$targetAbs/Dockerfile" -Force
            Write-Host "  -> [OK] Da sao chep Dockerfile vao thu muc goc." -ForegroundColor Green
        }

        Write-Host "`n[2/5] Cai dat GitHub Actions CI/CD Pipeline..." -ForegroundColor Cyan
        Copy-Item "$scriptDir/ci-templates/github-ci-ai.yml" "$workflowDir/ci.yml" -Force
        Write-Host "  -> [OK] CI/CD Enterprise da san sang tai $workflowDir/ci.yml" -ForegroundColor Green

        Write-Host "`n[3/5] Sinh Python Pydantic Models tu Schemas vao $targetAbs/app/models..." -ForegroundColor Cyan
        powershell -ExecutionPolicy Bypass -File "$scriptDir/scripts/codegen.ps1" -Target ai -OutputDir "$targetAbs/app/models"

        Write-Host "`n[4/5] Khoi tao file .env & .env.example cho AI Service..." -ForegroundColor Cyan
        $envAi = "AI_SERVICE_PORT=5000`nPIPELINE_MODE=real`nDEVICE=cpu`nCOMPUTE_TYPE=int8`nHF_MODEL_ID=ntgiaky/faster-PhoWhisper-small"
        Set-Content -Path "$targetAbs/.env.example" -Value $envAi -Encoding utf8
        if (-not (Test-Path "$targetAbs/.env")) {
            Set-Content -Path "$targetAbs/.env" -Value $envAi -Encoding utf8
            Write-Host "  -> [OK] Da tao file .env" -ForegroundColor Green
        }

        Write-Host "`n[5/5] Huong dan khoi chay AI Service:" -ForegroundColor Yellow
        Write-Host "  1. Tai cache Model PhoWhisper:" -ForegroundColor White
        Write-Host "     python $scriptDir/scripts/download_model.py" -ForegroundColor Green
        Write-Host "  2. Chay FastAPI:" -ForegroundColor White
        Write-Host "     uvicorn app.main:app --host 0.0.0.0 --port 5000 --reload" -ForegroundColor Green
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   BOOTSTRAP HOAN TAT - REPO DA SAN SANG DE PHAT TRIEN!   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
