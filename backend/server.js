const express = require('express');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
app.set('trust proxy', true);
app.use(cors());
app.use(express.json());

// In-memory database mapping shortId -> longUrl
const urlDatabase = new Map();

// API to generate short URL
app.post('/api/shorten', (req, res) => {
    const { longUrl } = req.body;
    if (!longUrl) {
        return res.status(400).json({ error: 'longUrl is required' });
    }

    // Ensure the URL has http:// or https:// so res.redirect() works externally
    const normalizedUrl = /^https?:\/\//i.test(longUrl.trim())
        ? longUrl.trim()
        : `https://${longUrl.trim()}`;

    // Generate a random 6-character hex string
    const shortId = crypto.randomBytes(3).toString('hex');
    urlDatabase.set(shortId, normalizedUrl);

    // Build base URL dynamically from Nginx headers (or BASE_URL env var if set)
    const protocol = req.headers['x-forwarded-proto'] || req.protocol;
    const host = req.headers['x-forwarded-host'] || req.get('host');
    const baseUrl = process.env.BASE_URL || `${protocol}://${host}`;

    const shortUrl = `${baseUrl}/${shortId}`;
    res.json({ shortUrl });
});

// Endpoint to redirect to the original URL
app.get('/:shortId', (req, res) => {
    const { shortId } = req.params;
    const longUrl = urlDatabase.get(shortId);

    if (longUrl) {
        return res.redirect(longUrl);
    } else {
        return res.status(404).send('URL not found');
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Backend running on port ${PORT}`);
});
