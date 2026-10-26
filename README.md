# INTEGRIX IX.VOICE — CANONICAL CONTRACTS & SCHEMAS

> **Single Source of Truth (SSOT)** cho toàn bộ nền tảng phân tích giọng nói Integrix IX.Voice.  
> Được thiết kế để làm **Git Submodule** dùng chung giữa các repository: **Frontend**, **Backend**, **AI Service**, và **Local Runtime Skeleton**.

---

## 1. Cấu trúc Hợp đồng Dữ liệu

```text
ix-voice-contracts/
├── schemas/                        # JSON Schemas (draft-07)
│   ├── audio_job_v0_1.json         # Vòng đời & trạng thái Processing Job
│   ├── transcript_v0_1.json        # Kết quả STT (PhoWhisper) & Speaker Diarization
│   ├── analysis_emotion_v0_1.json  # Tóm tắt, đối chiếu checklist & tín hiệu âm học
│   └── evidence_qa_v0_1.json       # Thẩm định chất lượng & kiểm toán tuân thủ (QA)
├── fixtures/                       # Bộ dữ liệu mẫu chuẩn hóa (Prudential Life Insurance)
│   ├── mock_audio_job.json
│   ├── mock_transcript.json
│   ├── mock_analysis_emotion.json
│   └── mock_evidence_qa.json
├── scripts/
│   └── codegen.ps1                 # Script tự động sinh mã nguồn (TS, Java, Python)
└── package.json
```

---

## 2. Hướng dẫn Tích hợp Git Submodule (Dành cho các Role)

Bất kỳ repository vệ tinh nào (Frontend, Backend, AI) cần sử dụng hợp đồng dữ liệu, chỉ cần chạy các lệnh sau:

### 2.1 Thêm Submodule vào repository của bạn:
```bash
git submodule add https://github.com/lamhoanghai-dang1911/ix-voice-contracts.git contracts
```

### 2.2 Clone repository đã có sẵn submodule:
```bash
git clone --recurse-submodules <URL_REPO_CUA_BAN>
# Hoặc nếu đã clone thông thường:
git submodule update --init --recursive
```

### 2.3 Cập nhật khi có phiên bản hợp đồng mới từ Tech Lead:
```bash
git submodule update --remote contracts
```

---

## 3. Sinh mã nguồn tự động (Codegen DTOs)

Sau khi kéo schema về, có thể sinh mã nguồn (Request/Response DTOs) ngay lập tức:

### Cách 1: Chạy bằng PowerShell
```powershell
# Sinh cho Frontend TypeScript:
powershell -ExecutionPolicy Bypass -File .\contracts\scripts\codegen.ps1 -Target frontend -OutputDir "./src/types"

# Sinh cho Backend Spring Boot Java:
powershell -ExecutionPolicy Bypass -File .\contracts\scripts\codegen.ps1 -Target backend -OutputDir "./src/main/java/vn/integrix/voice/model"

# Sinh cho AI Service Python:
powershell -ExecutionPolicy Bypass -File .\contracts\scripts\codegen.ps1 -Target ai -OutputDir "./app/models"
```

### Cách 2: Chạy trực tiếp qua quicktype
```bash
# TypeScript:
npx -y quicktype -s schema schemas/transcript_v0_1.json -o transcript.ts --just-types

# Java:
npx -y quicktype -s schema schemas/transcript_v0_1.json -o Transcript.java --package vn.integrix.voice.model

# Python Pydantic:
npx -y quicktype -s schema schemas/transcript_v0_1.json -o transcript.py --pydantic-base-model
```
