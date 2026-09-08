# Simple URL Shortener

A lightweight, containerized **URL shortener application** built with **React**, **Node.js**, **Express**, and **Docker**.

The application allows users to submit long URLs and receive short URLs that redirect to the original destination.

## Tech Stack

* **Frontend:** React, Vite, HTML5, CSS3
* **Backend:** Node.js, Express
* **Storage:** In-Memory Storage using JavaScript `Map`
* **Containerization:** Docker, Docker Compose

---

## Project Structure

```text
url-shortener/
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
│
├── frontend/
│   ├── Dockerfile
│   ├── index.html
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── App.jsx
│       └── main.jsx
│
├── .gitignore
└── docker-compose.yml
```

---

## Prerequisites

Make sure the following software is installed on your machine:

* **Docker**
* **Docker Compose**

Verify Docker:

```bash
docker --version
```

Verify Docker Compose:

```bash
docker compose version
```

---

## Getting Started

### 1. Open the Project Directory

Open a terminal in the root project directory:

```bash
cd url-shortener
```

---

### 2. Build and Run the Containers

Build the Docker images and start the application using Docker Compose:

```bash
docker compose up --build
```

Docker Compose will build and start both the **frontend** and **backend** services.

---

### 3. Access the Application

Once the containers are running, open your browser and visit:

**Frontend UI:**

```text
http://localhost:3000
```

**Backend API:**

```text
http://localhost:5000
```

---

## How It Works

The application follows a simple workflow:

```text
             ┌─────────────────┐
             │      User       │
             └────────┬────────┘
                      │
                      │ Long URL
                      ▼
             ┌─────────────────┐
             │ React Frontend  │
             └────────┬────────┘
                      │
                      │ POST /api/shorten
                      ▼
             ┌─────────────────┐
             │ Express Backend │
             └────────┬────────┘
                      │
                      │ Store URL
                      ▼
             ┌─────────────────┐
             │  JavaScript Map │
             │  shortId → URL  │
             └────────┬────────┘
                      │
                      │ Short URL
                      ▼
             ┌─────────────────┐
             │      User       │
             └─────────────────┘
```

When the user accesses the generated short URL, the backend looks up the corresponding original URL and redirects the browser.

---

# API Documentation

## 1. Shorten URL

Creates a short identifier for a long URL.

### Endpoint

```http
POST /api/shorten
```

### Content-Type

```http
Content-Type: application/json
```

### Request Body

```json
{
  "longUrl": "https://www.example.com"
}
```

### Response

```json
{
  "shortUrl": "http://localhost:5000/abc1234"
}
```

The returned `shortUrl` can then be used to redirect to the original URL.

---

## 2. Redirect to Original URL

Redirects the user to the original URL associated with a short identifier.

### Endpoint

```http
GET /:shortId
```

### Example

```http
GET /abc1234
```

The backend looks up `abc1234` in the in-memory URL map.

If the identifier exists:

```text
/abc1234
     │
     ▼
https://www.example.com
```

The browser is redirected to the original URL.

If the identifier does not exist, the server returns a **404 Not Found** response.

---

## Example Usage

### Create a Short URL

Using `curl`:

```bash
curl -X POST http://localhost:5000/api/shorten \
  -H "Content-Type: application/json" \
  -d '{"longUrl":"https://www.example.com"}'
```

Example response:

```json
{
  "shortUrl": "http://localhost:5000/abc1234"
}
```

---

### Use the Short URL

Open the generated URL:

```text
http://localhost:5000/abc1234
```

The backend redirects the browser to:

```text
https://www.example.com
```

---

## Storage

This project uses an in-memory JavaScript `Map` to store URL mappings.

Conceptually, the data is stored as:

```javascript
const urls = new Map();

urls.set("abc1234", "https://www.example.com");
```

The relationship is:

```text
Short ID      Original URL
─────────     ─────────────────────────
abc1234   →   https://www.example.com
xyz7890   →   https://github.com/
```

### Important

Because the URLs are stored **only in memory**, all stored URLs are lost when the backend container is restarted.

For a production application, a persistent database such as **PostgreSQL**, **MySQL**, **MongoDB**, or **Redis** could be used instead.

---

## Docker

The application consists of separate frontend and backend containers managed by Docker Compose.

```text
                  Docker Compose
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
 ┌─────────────────┐       ┌─────────────────┐
 │ Frontend        │       │ Backend         │
 │ React + Vite    │──────►│ Node.js         │
 │ Port: 3000      │       │ Express         │
 └─────────────────┘       │ Port: 5000      │
                           └────────┬────────┘
                                    │
                                    ▼
                             JavaScript Map
```

---

## Useful Docker Commands

### Start the Application

```bash
docker compose up
```

### Build and Start

```bash
docker compose up --build
```

### Run in the Background

```bash
docker compose up -d
```

### Stop the Application

```bash
docker compose down
```

### Rebuild the Containers

```bash
docker compose build
```

### View Logs

```bash
docker compose logs
```

### Follow Logs

```bash
docker compose logs -f
```

### View Running Containers

```bash
docker ps
```

---

## Features

* **URL shortening**
* **Automatic short ID generation**
* **URL redirection**
* **React frontend**
* **Express backend**
* **In-memory URL storage**
* **REST API**
* **Docker containerization**
* **Docker Compose orchestration**
* **404 handling for unknown short URLs**

---

## Future Improvements

Possible improvements for a production-ready version include:

* Persistent database storage
* User accounts and authentication
* Custom short URLs
* URL expiration
* Click analytics
* QR code generation
* Rate limiting
* URL validation
* HTTPS support
* Redis caching
* PostgreSQL database integration

---

## License

This project is intended for educational and development purposes.
