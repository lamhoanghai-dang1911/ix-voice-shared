/**
 * INTEGRIX IX.VOICE - STANDALONE MOCK BACKEND SERVER
 * Serves canonical fixtures on port 8080 for Frontend developers.
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
    return JSON.stringify({ error: `Fixture ${filename} not found` });
}

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
    res.setHeader('Content-Type', 'application/json; charset=utf-8');

    console.log(`[MockBackend] ${req.method} ${url}`);

    // Health
    if (url === '/api/v1/health') {
        res.writeHead(200);
        res.end(JSON.stringify({
            status: "healthy",
            service: "IX.VOICE Standalone Mock Backend",
            version: "0.1.0-mock",
            virtualThreadsEnabled: true
        }));
        return;
    }

    // Upload & Create Job
    if (req.method === 'POST' && url === '/api/v1/jobs') {
        res.writeHead(200);
        res.end(JSON.stringify({
            jobId: "f47ac10b-58cc-4372-a567-0e02b2c3d479",
            status: "COMPLETED",
            traceId: "trace-mock-" + Date.now()
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
    res.end(JSON.stringify({ error: "Endpoint not found in mock backend", url }));
});

server.listen(PORT, () => {
    console.log(`=======================================================`);
    console.log(`  IX.VOICE MOCK BACKEND RUNNING AT http://localhost:${PORT}`);
    console.log(`  Frontend developers can connect to /api/v1/*`);
    console.log(`=======================================================`);
});
