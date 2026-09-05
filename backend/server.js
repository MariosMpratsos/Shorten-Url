const express = require('express');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
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

    // Generate a random 6-character hex string
    const shortId = crypto.randomBytes(3).toString('hex');
    urlDatabase.set(shortId, longUrl);

    const shortUrl = `http://localhost:5000/${shortId}`;
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
