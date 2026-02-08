# Photography Website + Aryeo Integration

## Files

- `index.html` - site structure and content
- `portfolio.html` - Aryeo shoots portfolio page (API-driven)
- `order.html` - on-site order page with embedded Aryeo form + live order status
- `styles.css` - styling and responsive layout
- `site-config.js` - central links and API base URL
- `script.js` - frontend logic for links, shoots, status lookup, and pipeline feed
- `api/server.js` - local Aryeo integration API server
- `api/.env.example` - required environment variables
- `data/lead-pipeline.jsonl` - local lead pipeline event log (auto-created)
- `images/` - put your own photo files here

## Run locally

Run both services:

```bash
cd /Users/chris/Photography-Website
cp api/.env.example api/.env
```

Edit `api/.env` and set:

```bash
ARYEO_API_TOKEN=your_real_token_here
WEBHOOK_SECRET=your_random_secret_here
```

Quick start (recommended):

```bash
cd /Users/chris/Photography-Website
./scripts/start-local.sh
```

Quick stop:

```bash
cd /Users/chris/Photography-Website
./scripts/stop-local.sh
```

Manual start API server:

```bash
cd /Users/chris/Photography-Website
node api/server.js
```

Manual start website (second terminal):

```bash
cd /Users/chris/Photography-Website
python3 -m http.server 8000
```

Then open `http://localhost:8000`.

## Customize for your brand

1. Update your name and email in `index.html`.
2. Replace sample Unsplash image URLs with your own files in `images/`.
3. Edit colors/fonts in `styles.css` variables under `:root`.

## Aryeo setup

1. Open `site-config.js`.
2. Keep `order_page` set to `order.html`.
3. Set `api_base` to your API URL (local default: `http://127.0.0.1:8788`).
4. Set `aryeo_order_form` and `aryeo_portal`.

## Features now live

1. Portfolio auto-loads Aryeo shoots from `GET /api/shoots`.
2. Order page provides live status lookup via `GET /api/order-status?order_id=...`.
3. Lead pipeline captures webhook events from `POST /api/webhooks/aryeo` and displays recent entries from `GET /api/pipeline/leads`.

## Aryeo webhook target

Set your Aryeo webhook URL to:

`https://your-domain.com/api/webhooks/aryeo`

For local testing:

`http://127.0.0.1:8788/api/webhooks/aryeo`

Include header:

`x-webhook-secret: <WEBHOOK_SECRET>`

## Upload to hosting

Most hosting services accept static files. Upload these items from the project root:

- `index.html`
- `styles.css`
- `site-config.js`
- `script.js`
- `api/` (if deploying the API with your site host)
- `images/`
