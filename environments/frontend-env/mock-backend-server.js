/**
 * INTEGRIX IX.VOICE - STANDALONE MOCK BACKEND SERVER WITH SWAGGER UI
 * Serves canonical fixtures and interactive Swagger UI on port 8080 for Frontend developers.
 * Zero external dependencies (Pure Node.js built-in HTTP module).
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8080;
const FIXTURES_DIR = path.resolve(__dirname, '../../fixtures');

function loadFixture(filename) {
    const filePath = path.join(FIXTURES_DIR, filename);
    if (fs.existsSync(filePath)) {
        return fs.readFileSync(filePath, 'utf8');
    }
    return JSON.stringify({
        status: "READY",
        message: "Mock data removed by DevOps. Teams (FE, BE, AI) will discuss and define domain data.",
        fixture: filename,
        data: {}
    }, null, 2);
}

const OPENAPI_SPEC = {
    openapi: '3.0.1',
    info: {
        title: 'INTEGRIX IX.VOICE - Canonical API Gateway',
        description: 'Tài liệu API tương tác cho Frontend Developers. Kết nối trực tiếp vào Mock Backend (hoặc Spring Boot Backend thật) tại cổng 8080.',
        version: '0.1.0-canonical'
    },
    servers: [
        { url: 'http://localhost:8080', description: 'Local Mock Server (Port 8080)' }
    ],
    paths: {
        '/api/v1/health': {
            get: {
                tags: ['System Health'],
                summary: 'Kiểm tra trạng thái sẵn sàng của hệ thống',
                responses: { '200': { description: 'Hệ thống hoạt động bình thường' } }
            }
        },
        '/api/v1/jobs': {
            post: {
                tags: ['Audio Processing Jobs'],
                summary: 'Tạo Job xử lý âm thanh mới (Upload Audio File)',
                requestBody: {
                    content: {
                        'multipart/form-data': {
                            schema: {
                                type: 'object',
                                properties: {
                                    file: { type: 'string', format: 'binary', description: 'Tệp âm thanh WAV/MP3/M4A' }
                                }
                            }
                        }
                    }
                },
                responses: { '200': { description: 'Tạo Job thành công, trả về jobId' } }
            }
        },
        '/api/v1/jobs/{jobId}': {
            get: {
                tags: ['Audio Processing Jobs'],
                summary: 'Lấy thông tin chi tiết và tiến trình xử lý Audio Job',
                parameters: [
                    { name: 'jobId', in: 'path', required: true, schema: { type: 'string' }, example: 'f47ac10b-58cc-4372-a567-0e02b2c3d479' }
                ],
                responses: { '200': { description: 'Dữ liệu AudioJob theo chuẩn Canonical Schema' } }
            }
        },
        '/api/v1/jobs/{jobId}/transcript': {
            get: {
                tags: ['Transcription & Speech AI'],
                summary: 'Lấy kết quả bóc băng hội thoại (Transcript & Timestamps)',
                parameters: [
                    { name: 'jobId', in: 'path', required: true, schema: { type: 'string' }, example: 'f47ac10b-58cc-4372-a567-0e02b2c3d479' }
                ],
                responses: { '200': { description: 'Dữ liệu Transcript đầy đủ lời thoại theo người nói' } }
            }
        },
        '/api/v1/jobs/{jobId}/analysis': {
            get: {
                tags: ['Speech Analysis & Compliance'],
                summary: 'Lấy báo cáo phân tích cảm xúc & Checklist tuân thủ Prudential',
                parameters: [
                    { name: 'jobId', in: 'path', required: true, schema: { type: 'string' }, example: 'f47ac10b-58cc-4372-a567-0e02b2c3d479' }
                ],
                responses: { '200': { description: 'Báo cáo chỉ số WPM, tỷ lệ im lặng, checklist tuân thủ' } }
            }
        },
        '/api/v1/jobs/{jobId}/qa-review': {
            get: {
                tags: ['QA Audit & Review'],
                summary: 'Lấy hồ sơ thẩm định chất lượng kiểm toán viên QA',
                parameters: [
                    { name: 'jobId', in: 'path', required: true, schema: { type: 'string' }, example: 'f47ac10b-58cc-4372-a567-0e02b2c3d479' }
                ],
                responses: { '200': { description: 'Hồ sơ thẩm định chất lượng QA' } }
            }
        }
    }
};

const SWAGGER_HTML = `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>INTEGRIX IX.VOICE - Swagger UI (Mock Backend)</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
  <style>
    body { margin: 0; background: #fafafa; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
    .topbar { display: none !important; }
    .integrix-banner {
      background: #0F2942;
      color: white;
      padding: 14px 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }
    .integrix-title { font-size: 17px; font-weight: bold; letter-spacing: 0.5px; }
    .integrix-badge {
      background: #0284C7;
      color: white;
      font-size: 12px;
      font-weight: 600;
      padding: 5px 12px;
      border-radius: 999px;
    }
  </style>
</head>
<body>
  <div class="integrix-banner">
    <div class="integrix-title">TẬP ĐOÀN INTEGRIX • IX.VOICE API SWAGGER UI</div>
    <div class="integrix-badge">PORT 8080 (MOCK BACKEND)</div>
  </div>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
  <script>
    window.onload = () => {
      window.ui = SwaggerUIBundle({
        url: '/api/v1/api-docs',
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIBundle.SwaggerUIStandalonePreset
        ],
        layout: "BaseLayout"
      });
    };
  </script>
</body>
</html>`;

const server = http.createServer((req, res) => {
    // CORS Headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    const url = req.url.split('?')[0];
    console.log(`[MockBackend] ${req.method} ${url}`);

    // Swagger UI HTML Page
    if (url === '/swagger-ui.html' || url === '/docs') {
        res.setHeader('Content-Type', 'text/html; charset=utf-8');
        res.writeHead(200);
        res.end(SWAGGER_HTML);
        return;
    }

    // OpenAPI Spec JSON
    if (url === '/api/v1/api-docs') {
        res.setHeader('Content-Type', 'application/json; charset=utf-8');
        res.writeHead(200);
        res.end(JSON.stringify(OPENAPI_SPEC, null, 2));
        return;
    }

    // Default JSON responses
    res.setHeader('Content-Type', 'application/json; charset=utf-8');

    // Root Welcome Endpoint
    if (url === '/') {
        res.writeHead(200);
        res.end(JSON.stringify({
            message: 'IX.VOICE Standalone Mock Backend Server is RUNNING',
            status: 'HEALTHY',
            port: PORT,
            swaggerUi: `http://localhost:${PORT}/swagger-ui.html`,
            availableEndpoints: [
                'GET  /swagger-ui.html (Tài liệu Swagger UI tương tác)',
                'GET  /api/v1/api-docs (OpenAPI JSON)',
                'GET  /api/v1/health',
                'POST /api/v1/jobs',
                'GET  /api/v1/jobs/:id',
                'GET  /api/v1/jobs/:id/transcript',
                'GET  /api/v1/jobs/:id/analysis',
                'GET  /api/v1/jobs/:id/qa-review'
            ],
            note: 'Mở http://localhost:8080/swagger-ui.html để xem Swagger UI trực quan'
        }, null, 2));
        return;
    }

    // Health
    if (url === '/api/v1/health') {
        res.writeHead(200);
        res.end(JSON.stringify({
            status: 'healthy',
            service: 'IX.VOICE Standalone Mock Backend',
            version: '0.1.0-mock',
            virtualThreadsEnabled: true
        }));
        return;
    }

    // Upload & Create Job
    if (req.method === 'POST' && url === '/api/v1/jobs') {
        res.writeHead(200);
        res.end(JSON.stringify({
            jobId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            status: 'COMPLETED',
            traceId: 'trace-mock-' + Date.now()
        }));
        return;
    }

    // Transcript
    if (url.match(/\/api\/v1\/jobs\/[^\/]+\/transcript/)) {
        res.writeHead(200);
        res.end(loadFixture('mock_transcript.json'));
        return;
    }

    // Analysis
    if (url.match(/\/api\/v1\/jobs\/[^\/]+\/analysis/)) {
        res.writeHead(200);
        res.end(loadFixture('mock_analysis_emotion.json'));
        return;
    }

    // QA Review
    if (url.match(/\/api\/v1\/jobs\/[^\/]+\/qa-review/)) {
        res.writeHead(200);
        res.end(loadFixture('mock_evidence_qa.json'));
        return;
    }

    // Get Job Details
    if (url.match(/\/api\/v1\/jobs\/[^\/]+/)) {
        res.writeHead(200);
        res.end(loadFixture('mock_audio_job.json'));
        return;
    }

    // Default 404
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Endpoint not found in mock backend', url }));
});

server.listen(PORT, () => {
    console.log(`=======================================================`);
    console.log(`  IX.VOICE MOCK BACKEND RUNNING AT http://localhost:${PORT}`);
    console.log(`  Swagger UI: http://localhost:${PORT}/swagger-ui.html`);
    console.log(`  Frontend developers can connect to /api/v1/*`);
    console.log(`=======================================================`);
});
