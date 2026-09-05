# Simple URL Shortener

A lightweight, containerized URL shortener application built with React, Node.js, Express, and Docker.

## Tech Stack

- **Frontend:** React, Vite, HTML5, CSS3
- **Backend:** Node.js, Express, In-Memory Storage (JavaScript Map)
- **Containerization:** Docker, Docker Compose

---

## Project Structure

```text
url-shortener/
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── frontend/
│   ├── Dockerfile
│   ├── index.html
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── App.jsx
│       └── main.jsx
├── .gitignore
└── docker-compose.yml

Prerequisites

Ensure you have the following installed on your machine:

    Docker

    Docker Compose

Getting Started

    Open a terminal in the root project directory (url-shortener/).

    Build and run the containers using Docker Compose:
    Bash

    docker compose up --build

    Open your web browser and access the application:

        Frontend UI: http://localhost:3000

        Backend API: http://localhost:5000

API Endpoints
1. Shorten URL

    Endpoint: POST /api/shorten

    Request Body:
    JSON

{
  "longUrl": "[https://www.example.com](https://www.example.com)"
}

Response:
JSON

    {
      "shortUrl": "http://localhost:5000/abc1234"
    }

2. Redirect to Original URL

    Endpoint: GET /:shortId

    Action: Redirects the user browser session to the registered long URL or returns a 404 error if the short identifier does not exist.
