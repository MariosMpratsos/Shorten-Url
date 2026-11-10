const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
app.set('trust proxy', true);
app.use(cors());
app.use(express.json());

const DB_FILE = path.join(__dirname, 'urls.json');

function getDatabase() {
    try {
        if (fs.existsSync(DB_FILE)) {
            return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
        }
    } catch (e) {}
    return {};
}

function saveDatabase(db) {
    fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2));
}

// 1. REDIRECT ROUTE FIRST (Must be before any static or catch-all handlers)
app.get('/:shortId', (req, res) => {
    const { shortId } = req.params;
    
    // Ignore favicon or asset requests if they slip through Nginx
    if (shortId === 'favicon.ico' || shortId === 'assets') {
        return res.status(404).send('Not found');
    }

    const db = getDatabase();
    const longUrl = db[shortId];

    if (longUrl) {
        return res.redirect(302, longUrl);
    } else {
        return res.status(404).send('URL not found');
    }
});

// 2. API ROUTE
app.post('/api/shorten', (req, res) => {
    const { longUrl } = req.body;
    if (!longUrl) {
        return res.status(400).json({ error: 'longUrl is required' });
    }

    const normalizedUrl = /^https?:\/\//i.test(longUrl.trim())
        ? longUrl.trim()
        : `https://${longUrl.trim()}`;

    const shortId = String(Math.floor(100 + Math.random() * 900));
    
    const db = getDatabase();
    db[shortId] = normalizedUrl;
    saveDatabase(db);

    const protocol = req.headers['x-forwarded-proto'] || 'http';
    const shortUrl = `${protocol}://shortener.bratsos.online/${shortId}`;
    
    res.json({ shortUrl });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Backend running on port ${PORT}`);
});
