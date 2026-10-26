# INTEGRIX IX.VOICE - Central Shared DevKit & Platform Hub

Trung tâm hợp đồng dữ liệu chuẩn hóa (Single Source of Truth), bộ công cụ tự động hóa khởi tạo dự án (1-Click Platform Bootstrap), sinh code DTO (Codegen) và môi trường giả lập (Standalone Mock Servers) cho dự án AI Voice INTEGRIX.

---

## 🚀 Tính năng nổi bật: 1-Click Platform Bootstrap

Khi bất kỳ role nào (**Frontend**, **Backend**, **AI**) bắt đầu từ một repository mã nguồn thô (chưa có Dockerfile, chưa có CI/CD):

Chỉ cần thực hiện **2 bước**:

```bash
# Bước 1: Nhúng bộ công cụ Shared làm submodule
git submodule add https://github.com/lamhoanghai-dang1911/ix-voice-shared.git devkit

# Bước 2: Chạy lệnh Bootstrap theo role của bạn
./devkit/scripts/setup-env.ps1 -Role frontend -Init
# hoặc
./devkit/scripts/setup-env.ps1 -Role backend -Init
# hoặc
./devkit/scripts/setup-env.ps1 -Role ai -Init
```

### ⚙️ Script sẽ tự động thực hiện từ A-Z trong 5 giây:
1. **Sao chép Dockerfile & Nginx chuẩn Enterprise** tương ứng cho từng công nghệ vào thư mục gốc.
2. **Cài đặt GitHub Actions CI/CD Pipeline chuẩn** (`.github/workflows/ci.yml`) hỗ trợ test tự động, build multi-stage Docker và deploy Staging/Production.
3. **Sinh code Type/DTO tự động** từ 4 file JSON Schema chuẩn (`src/types/` cho FE, `model/gen/` cho BE, `app/models/` cho AI).
4. **Tạo file `.env` & `.env.example`** với cấu hình cổng chuẩn sẵn sàng chạy.
5. **Hướng dẫn 1-click khởi động Mock Server / PostgreSQL** để bắt đầu dev ngay mà không phụ thuộc vào nhau.

---

## 📁 Cấu trúc kho lưu trữ Shared

```text
ix-voice-shared/
├── dockerfiles/                    <-- Dockerfile chuẩn Enterprise cho từng Role
│   ├── Dockerfile.frontend         <-- Node 20 builder + Nginx Alpine
│   ├── Dockerfile.backend          <-- Java 21 Temurin Alpine + Virtual Threads
│   └── Dockerfile.ai               <-- Python 3.10 slim + PyTorch + FFmpeg
├── nginx/
│   └── nginx.conf                  <-- Nginx SPA routing & reverse proxy /api/
├── ci-templates/                   <-- Mẫu GitHub Actions CI/CD Enterprise
│   ├── github-ci-frontend.yml
│   ├── github-ci-backend.yml
│   └── github-ci-ai.yml
├── schemas/                        <-- 4 Hợp đồng JSON Schema chuẩn
│   ├── audio_job_v0_1.json
│   ├── transcript_v0_1.json
│   ├── analysis_emotion_v0_1.json
│   └── evidence_qa_v0_1.json
├── environments/                   <-- Môi trường giả lập & DB cục bộ
│   ├── frontend-env/               <-- Mock Backend (port 8080) có Swagger UI
│   └── backend-env/                <-- Mock AI (port 5000) & PostgreSQL 16 (port 5432)
└── scripts/
    ├── setup-env.ps1               <-- 1-Click Platform Bootstrap Wizard
    ├── codegen.ps1                 <-- Sinh mã DTOs đa ngôn ngữ
    └── download_model.py           <-- Tải pre-trained weights PhoWhisper
```

---
© 2026 INTEGRIX Solution. All rights reserved.
