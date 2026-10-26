# INTEGRIX IX.VOICE — SHARED DEVKIT & CANONICAL CONTRACTS (`ix-voice-shared`)

> **Bộ công cụ phát triển & Môi trường dùng chung (Shared DevKit & Environment Hub)**  
> Dành cho 3 đội ngũ phát triển độc lập: **Frontend (React)**, **Backend (Spring Boot)**, và **AI Service (PhoWhisper)**.  
> Được nhúng vào repository của từng Role thông qua **Git Submodule**.

---

## 1. Cấu trúc của `ix-voice-shared`

```text
ix-voice-shared/
├── schemas/                        # [1] Canonical JSON Schemas (Single Source of Truth)
│   ├── audio_job_v0_1.json         # Vòng đời & trạng thái Processing Job
│   ├── transcript_v0_1.json        # Kết quả STT (PhoWhisper) & Speaker Diarization
│   ├── analysis_emotion_v0_1.json  # Tóm tắt, đối chiếu checklist & tín hiệu âm học
│   └── evidence_qa_v0_1.json       # Thẩm định chất lượng & kiểm toán tuân thủ (QA)
│
├── fixtures/                       # [2] Bộ dữ liệu mẫu chuẩn hóa (Prudential Life Insurance)
│   ├── mock_audio_job.json
│   ├── mock_transcript.json
│   ├── mock_analysis_emotion.json
│   └── mock_evidence_qa.json
│
├── environments/                   # [3] Môi trường giả lập (Mock Services) cho từng Role
│   ├── frontend-env/               # Mock Backend (Port 8080) -> FE dev KHÔNG CẦN cài Java
│   │   ├── mock-backend-server.js
│   │   └── docker-compose.mock-be.yml
│   └── backend-env/                # Mock AI (Port 5000) -> BE dev KHÔNG CẦN cài Python/GPU
│       ├── mock-ai-server.js
│       ├── docker-compose.mock-ai.yml
│       ├── docker-compose.postgres.yml # PostgreSQL 16 container dựng sẵn
│       └── init-db/01-schema.sql   # DDL tables: audio_jobs, transcripts, segments
│
├── ci-templates/                   # [4] Mẫu GitHub Actions CI cho từng repo
│   ├── github-ci-frontend.yml
│   ├── github-ci-backend.yml
│   └── github-ci-ai.yml
│
├── scripts/                        # [5] Bộ công cụ tự động hóa
│   ├── setup-env.ps1               # 1-Click thiết lập môi trường theo Role
│   ├── codegen.ps1                 # 1-Click sinh DTO cho TypeScript, Java, Python
│   └── download_model.py           # Tải cache model PhoWhisper
│
├── package.json                    # Hỗ trợ npm run codegen
└── README.md
```

---

## 2. Hướng dẫn Dành cho Từng Role (Kịch bản 1 Click)

Khi bạn nhận một repository mới từ tổ chức, hãy làm theo các bước dưới đây để thiết lập môi trường ngay lập tức:

### 2.1. Dành cho Role Frontend (React / TypeScript)

1. **Nhúng DevKit vào repo của bạn (chỉ làm 1 lần)**:
   ```bash
   git submodule add https://github.com/lamhoanghai-dang1911/ix-voice-shared.git devkit
   ```
2. **Kích hoạt môi trường Frontend**:
   ```powershell
   powershell -File .\devkit\scripts\setup-env.ps1 -Role frontend
   ```
   *Lệnh này sẽ tự động:*
   - Sinh toàn bộ TypeScript DTOs vào `src/types/`.
   - Tạo file `.env.example`.
3. **Chạy Mock Backend để test UI mà KHÔNG CẦN cài Java**:
   ```bash
   node devkit/environments/frontend-env/mock-backend-server.js
   # Hoặc dùng Docker:
   docker compose -f devkit/environments/frontend-env/docker-compose.mock-be.yml up -d
   ```
   👉 Giao diện React gọi tới `http://localhost:8080/api/v1` sẽ nhận phản hồi ngay lập tức!

---

### 2.2. Dành cho Role Backend (Java 21 / Spring Boot 3)

1. **Nhúng DevKit vào repo của bạn**:
   ```bash
   git submodule add https://github.com/lamhoanghai-dang1911/ix-voice-shared.git devkit
   ```
2. **Kích hoạt môi trường Backend**:
   ```powershell
   powershell -File .\devkit\scripts\setup-env.ps1 -Role backend
   ```
   *Lệnh này sẽ tự động:*
   - Sinh toàn bộ Java DTOs (Jackson) vào `src/main/java/.../model/`.
   - Tạo file `.env.example`.
3. **Bật Mock AI Service & PostgreSQL 16 (KHÔNG CẦN cài Python / PyTorch / GPU)**:
   ```bash
   # Bật Mock AI Service (Port 5000):
   node devkit/environments/backend-env/mock-ai-server.js

   # Bật PostgreSQL 16 dựng sẵn kèm bảng mẫu (Port 5432):
   docker compose -f devkit/environments/backend-env/docker-compose.postgres.yml up -d
   ```
   👉 Backend Spring Boot gọi `POST http://localhost:5000/api/v1/ai/transcribe` sẽ nhận transcript chuẩn trong mili-giây!

---

### 2.3. Dành cho Role AI Service (Python / Speech AI)

1. **Nhúng DevKit vào repo của bạn**:
   ```bash
   git submodule add https://github.com/lamhoanghai-dang1911/ix-voice-shared.git devkit
   ```
2. **Kích hoạt môi trường AI Service**:
   ```powershell
   powershell -File .\devkit\scripts\setup-env.ps1 -Role ai
   ```
   *Lệnh này sẽ tự động sinh Pydantic Models vào `app/models/`.*
3. **Tải cache model PhoWhisper**:
   ```bash
   python devkit/scripts/download_model.py
   ```

---

## 3. Cập nhật khi có Hợp đồng Dữ liệu mới

Khi Tech Lead cập nhật JSON Schema trên repo `ix-voice-shared`, các team chỉ cần chạy:
```bash
git submodule update --remote devkit
powershell -File .\devkit\scripts\codegen.ps1
```
Lập tức DTO của cả 3 bên đều được đồng bộ lên bản mới nhất!
