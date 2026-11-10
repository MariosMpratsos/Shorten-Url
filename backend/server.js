const express = require('express');
const cors = require('cors');

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

    // Add https:// if the user typed "www.google.com" without a protocol
    const normalizedUrl = /^https?:\/\//i.test(longUrl.trim())
        ? longUrl.trim()
        : `https://${longUrl.trim()}`;

    // Generate a random 3-digit number (100 - 999)
    const shortId = String(Math.floor(100 + Math.random() * 900));
    urlDatabase.set(shortId, normalizedUrl);

    // Always return shortener.bratsos.online (preserving http or https)
    const protocol = req.headers['x-forwarded-proto'] || req.protocol || 'http';
    const baseUrl = process.env.BASE_URL || `${protocol}://shortener.bratsos.online`;

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
