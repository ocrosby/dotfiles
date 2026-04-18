---
description: Researches a topic using live web sources, synthesizes a structured report, and publishes it to here.now — returns a live URL.
triggers:
  - /study
---

# Study: Research and Publish to here.now

Use this skill to research any topic and publish a self-contained report to here.now.

## Usage

```
/study <topic>              # research and publish anonymously (link expires in 24 hours)
/study <topic> --keep       # publish permanently (requires HERE_NOW_API_KEY env var)
```

## When to use

Invoke `/study` when you want to research a topic, synthesize it into a shareable report, and get a live URL back. Do not invoke when the user only wants a conversational answer — this skill always publishes.

## Workflow

### 1. Parse the Topic

Extract the topic from the argument. **If no topic is given: ask for one and do not proceed.**

Derive a URL slug: lowercase, spaces replaced with hyphens, max 40 characters.
Example: "quantum computing" → `quantum-computing`

### 2. Research the Topic

Use WebSearch to find 4–6 authoritative sources. Then use WebFetch on each to extract:
- Key definitions and concepts
- Current state or recent developments
- Notable perspectives or debates
- Any quantitative data (stats, dates, figures)

**Do not rely on training knowledge alone — always fetch live sources.** Record each source's URL and the facts drawn from it.

### 3. Synthesize the Report

Produce a complete, self-contained HTML document. Write it to `/tmp/study-{slug}.html`.

The document must follow this structure:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{Topic}</title>
  <style>
    :root { color-scheme: light dark; }
    body { font-family: system-ui, sans-serif; max-width: 800px; margin: 2rem auto;
           padding: 0 1rem; line-height: 1.6; }
    h1 { font-size: 2rem; margin-bottom: 0.25rem; }
    .meta { color: #666; font-size: 0.9rem; margin-bottom: 2rem; }
    h2 { border-bottom: 1px solid #ddd; padding-bottom: 0.3rem; margin-top: 2rem; }
    blockquote { border-left: 3px solid #ccc; margin: 1rem 0; padding: 0.5rem 1rem;
                 color: #555; }
    ol.sources { padding-left: 1.2rem; }
    ol.sources li { margin-bottom: 0.4rem; }
    a { color: #0070f3; }
  </style>
</head>
<body>
  <header>
    <h1>{Topic}</h1>
    <p class="meta">Researched {YYYY-MM-DD} · {N} sources</p>
  </header>
  <main>
    <section id="summary">
      <h2>Summary</h2>
      <p>{2–3 sentence overview}</p>
    </section>
    <section id="details">
      <h2>Key Points</h2>
      <!-- substantive content drawn from sources -->
    </section>
    <section id="sources">
      <h2>Sources</h2>
      <ol class="sources">
        <li><a href="{url}">{title or domain}</a></li>
        <!-- one entry per source fetched -->
      </ol>
    </section>
  </main>
</body>
</html>
```

### 4. Compute File Metadata

```bash
FILE="/tmp/study-{slug}.html"
SIZE=$(wc -c < "$FILE" | tr -d ' ')
HASH=$(python3 -c "import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" "$FILE")
```

### 5. Create the here.now Publication

POST the file manifest to the here.now API:

```bash
MANIFEST=$(python3 -c "
import json, sys, os
api_key = os.environ.get('HERE_NOW_API_KEY', '')
print(json.dumps({
  'files': [{
    'path': 'index.html',
    'size': int(sys.argv[1]),
    'contentType': 'text/html; charset=utf-8',
    'hash': sys.argv[2]
  }],
  'viewer': {
    'title': sys.argv[3],
    'description': 'Researched by Claude'
  }
}))" "$SIZE" "$HASH" "{Topic}")

AUTH_HEADER=""
if [ -n "$HERE_NOW_API_KEY" ]; then
  AUTH_HEADER="-H \"Authorization: Bearer $HERE_NOW_API_KEY\""
fi

RESPONSE=$(curl -s -X POST https://here.now/api/v1/publish \
  -H "Content-Type: application/json" \
  -H "X-HereNow-Client: claude-code/study" \
  $AUTH_HEADER \
  -d "$MANIFEST")
```

Extract from the response JSON:
- `SITE_URL` — the live public URL
- `UPLOAD_URL` — presigned PUT URL for the file (`upload.uploads[0].url`)
- `FINALIZE_URL` — URL to POST after upload (`upload.finalizeUrl`)
- `VERSION_ID` — version identifier (`upload.versionId`)

**If the POST returns a non-2xx status or an error field: stop, report the error, clean up the temp file, and do not proceed.**

### 6. Upload the File

```bash
curl -s -X PUT "$UPLOAD_URL" \
  -H "Content-Type: text/html; charset=utf-8" \
  --data-binary "@$FILE"
```

**If the PUT returns a non-2xx status: stop, report the error, clean up the temp file, and do not proceed.**

### 7. Finalize the Publication

```bash
curl -s -X POST "$FINALIZE_URL" \
  -H "Content-Type: application/json" \
  -d "{\"versionId\":\"$VERSION_ID\"}"
```

**If finalization returns a non-2xx status: stop and report the error.**

### 8. Verify and Report

Confirm the site is reachable:

```bash
STATUS=$(curl -s -o /dev/null -w "%{http_code}" --head "$SITE_URL")
```

Clean up the temp file regardless of the status:

```bash
rm -f "$FILE"
```

**If status is 200:** report success using this exact format:

```
Published: {SITE_URL}
Topic: {Topic} · {N} sources
Expires: 24 hours from now
```

If `HERE_NOW_API_KEY` was set, replace the Expires line with `Permanent`.

**If status is not 200:** report the URL anyway and note it may still be propagating (here.now CDN can take a few seconds).

## Rules

- Always fetch live sources — never publish a report based solely on training knowledge
- Never publish content that violates here.now's terms: no malware, phishing, spam, illegal content, or content exploiting minors
- Always clean up `/tmp/study-{slug}.html` after the workflow completes, even on failure
- If `HERE_NOW_API_KEY` is not set, always tell the user the link expires in 24 hours
- If the user passes `--keep` but `HERE_NOW_API_KEY` is not set, stop and tell them to set the env var before proceeding
