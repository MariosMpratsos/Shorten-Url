# URL Shortener Backend

A lightweight Express.js URL shortener service that stores mappings in a local JSON file (`urls.json`) and generates 3-digit numeric short IDs.

## Features

- **Shorten URLs (`POST /api/shorten`)**: Accepts a `longUrl`, normalizes missing `http://` or `https://` prefixes to `https://`, generates a 3-digit short ID (`100`–`999`), and returns the full `shortUrl`.
- **Redirect (`GET /:shortId`)**: Performs a `302` redirect to the stored target URL or returns a `404` status if not found.
- **Proxy Header Support**: Uses `trust proxy` and reads `x-forwarded-host` and `x-forwarded-proto` when building the returned short URL behind a reverse proxy.
- **JSON File Persistence**: Reads from and writes to `urls.json` on disk.
