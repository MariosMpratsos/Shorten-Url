const express = require('express');
const cors = require('cors');

const app = express();
app.set('trust proxy', true);
app.use(cors());
app.use(express.json());

const urlDatabase = new Map();

app.post('/api/shorten', (req, res) => {
    const { longUrl } = req.body;
    if (!longUrl) {
        return res.status(400).json({ error: 'longUrl is required' });
    }

    const normalizedUrl = /^https?:\/\//i.test(longUrl.trim())
        ? longUrl.trim()
        : `https://${longUrl.trim()}`;

    const shortId = String(Math.floor(100 + Math.random() * 900));
    urlDatabase.set(shortId, normalizedUrl);

    const protocol = req.headers['x-forwarded-proto'] || 'http';
    const shortUrl = `${protocol}://shortener.bratsos.online/${shortId}`;
    
    res.json({ shortUrl });
});

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
