import React, { useState } from 'react';

function App() {
  const [longUrl, setLongUrl] = useState('');
  const [shortUrl, setShortUrl] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setShortUrl('');

    try {
      const response = await fetch('http://localhost:5000/api/shorten', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ longUrl }),
      });

      const data = await response.json();
      if (response.ok) {
        setShortUrl(data.shortUrl);
      } else {
        setError(data.error || 'Something went wrong');
      }
    } catch (err) {
      setError('Could not connect to the backend server.');
    }
  };

  return (
    <div style={{ fontFamily: 'sans-serif', textAlign: 'center', marginTop: '50px' }}>
      <h2>Simple URL Shortener</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="url"
          placeholder="Enter long URL (e.g., https://google.com)"
          value={longUrl}
          onChange={(e) => setLongUrl(e.target.value)}
          required
          style={{ width: '320px', padding: '8px', marginRight: '8px' }}
        />
        <button type="submit" style={{ padding: '8px 16px' }}>Shorten</button>
      </form>

      {shortUrl && (
        <div style={{ marginTop: '20px' }}>
          <p>Shortened URL:</p>
          <a href={shortUrl} target="_blank" rel="noopener noreferrer">{shortUrl}</a>
        </div>
      )}

      {error && <p style={{ color: 'red', marginTop: '20px' }}>{error}</p>}
    </div>
  );
}

export default App;
