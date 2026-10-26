/**
 * INTEGRIX IX.VOICE - STANDALONE MOCK AI SERVICE
 * Serves canonical transcripts on port 5000 for Backend developers.
 * Zero external dependencies (Pure Node.js built-in HTTP module).
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 5000;
const FIXTURES_DIR = path.resolve(__dirname, '../../fixtures');

function loadFixture(filename) {
    const filePath = path.join(FIXTURES_DIR, filename);
    if (fs.existsSync(filePath)) {
        return fs.readFileSync(filePath, 'utf8');
    }
    return JSON.stringify({ error: `Fixture ${filename} not found` });
}

const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    const url = req.url.split('?')[0];
    res.setHeader('Content-Type', 'application/json; charset=utf-8');

    console.log(`[MockAIService] ${req.method} ${url}`);

    if (url === '/api/v1/ai/health') {
        res.writeHead(200);
        res.end(JSON.stringify({
            status: "healthy",
            service: "IX.VOICE Standalone Mock AI Service",
            version: "0.1.0-mock",
            pipelineMode: "mock",
            device: "cpu",
            modelId: "ntgiaky/faster-PhoWhisper-small (Simulated)"
        }));
        return;
    }

    if (req.method === 'POST' && url === '/api/v1/ai/transcribe') {
        let body = '';
        req.on('data', chunk => { body += chunk; });
        req.on('end', () => {
            let jobId = "f47ac10b-58cc-4372-a567-0e02b2c3d479";
            try {
                const parsed = JSON.parse(body);
                if (parsed.jobId) jobId = parsed.jobId;
            } catch (e) {}

            const raw = loadFixture('mock_transcript.json');
            const data = JSON.parse(raw);
            data.jobId = jobId;

            res.writeHead(200);
            res.end(JSON.stringify(data, null, 2));
        });
        return;
    }

    res.writeHead(404);
    res.end(JSON.stringify({ error: "Endpoint not found in mock AI service", url }));
});

server.listen(PORT, () => {
    console.log(`=======================================================`);
    console.log(`  IX.VOICE MOCK AI SERVICE RUNNING AT http://localhost:${PORT}`);
    console.log(`  Backend developers can connect to /api/v1/ai/*`);
    console.log(`=======================================================`);
});
