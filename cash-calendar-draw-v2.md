# Cash Calendar Draw — Project Spec (v2)

> A lightweight, single-file web app for running random number draws for cash calendar fundraisers.  
> Hosted on GitHub Pages. No build tools, no dependencies, no server required.  
> **v2 adds:** persistent exclusion list (survives browser close), CSV import, full smartphone optimization, and a pre-draw screen recording reminder.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [What's New in v2](#whats-new-in-v2)
3. [Repository Structure](#repository-structure)
4. [Feature Requirements](#feature-requirements)
5. [UI & UX Requirements](#ui--ux-requirements)
6. [Mobile Optimization](#mobile-optimization)
7. [Persistence — localStorage](#persistence--localstorage)
8. [CSV Import](#csv-import)
9. [Pre-Draw Reminder](#pre-draw-reminder)
10. [Core Logic](#core-logic)
11. [HTML Structure](#html-structure)
12. [CSS Notes](#css-notes)
13. [JavaScript Logic](#javascript-logic)
14. [GitHub Pages Setup](#github-pages-setup)
15. [Future Enhancements](#future-enhancements)

---

## Project Overview

**Purpose:** Run a fair, auditable random number draw for a cash calendar fundraiser.  
Each number on the calendar (e.g. 1–31) represents a day. Calendars that were not sold must be excluded so only sold calendar numbers are eligible to win.

**Draws are held weekly** — the exclusion list must survive page refreshes and browser closes between weekly draws.

**Tech stack:**
- Plain HTML, CSS, JavaScript — no frameworks, no npm
- Single file: `index.html`
- `localStorage` for persistence (no server needed)
- Hosted via GitHub Pages

---

## What's New in v2

| Feature | Details |
|---------|---------|
| **Persistent exclusions** | Exclusion list saved to `localStorage` — survives page close, browser restart, and weekly gaps between draws |
| **Persistent range settings** | Start/end numbers also saved so you don't re-enter them each week |
| **CSV import** | Upload a `.csv` file of unsold calendar numbers — parsed client-side, no server |
| **Smartphone-first layout** | Large tap targets, thumb-friendly bottom draw button, no pinch-zoom needed |
| **Session draw history** | History stored in `sessionStorage` — clears when you close the tab (intentional) |
| **Pre-draw reminder banner** | Dismissible prompt reminding the user to start screen recording before drawing — reappears each new session |

---

## Repository Structure

```
cash-calendar-draw/
├── index.html        ← Entire app lives here
├── README.md         ← Usage instructions
└── .github/
    └── workflows/
        └── pages.yml ← (Optional) GitHub Actions auto-deploy
```

---

## Feature Requirements

### Inputs

| Field | Type | Description |
|-------|------|-------------|
| Start Number | Number input | First number in range (e.g. `1`) — persisted |
| End Number | Number input | Last number in range (e.g. `31`) — persisted |
| Exclusion entry | Number input + Add button | Single number entry for unsold calendars |
| CSV Upload | File input (`accept=".csv"`) | Bulk-import unsold calendar numbers from a spreadsheet export |

### Persistence Behaviour

| Data | Storage | Lifetime |
|------|---------|---------|
| Start number | `localStorage` | Until manually cleared |
| End number | `localStorage` | Until manually cleared |
| Exclusion list | `localStorage` | Until manually cleared |
| Draw history | `sessionStorage` | Current browser session only |

### Actions

| Button / Control | Behaviour |
|-----------------|-----------|
| Add to exclusion list | Validates, adds tag, saves to `localStorage` immediately |
| Remove tag (×) | Removes number, updates `localStorage` immediately |
| Upload CSV | Parses file, merges valid numbers into exclusion list, saves |
| **Draw!** | Picks random number from eligible pool, animates result, saves to session history |
| Dismiss reminder | Hides the pre-draw reminder banner for the rest of the session |
| Clear Exclusions | Wipes exclusion list from UI **and** `localStorage` (confirm dialog first) |
| Clear History | Clears session draw history from UI and `sessionStorage` |

### Outputs

| Output | Description |
|--------|-------------|
| Result display | Large animated number — primary focus of the screen |
| Pool size indicator | "X numbers eligible" shown before/after draw |
| Exclusion count | Badge showing how many numbers are excluded |
| Draw history | Previous draws this session, newest first |

---

## UI & UX Requirements

- **One-handed use** — all primary actions reachable with a thumb
- **Large tap targets** — minimum 48×48px for all interactive elements (WCAG AA)
- **No horizontal scroll** — layout fully contained within viewport width
- **No pinch-zoom required** — all text readable at default zoom
- **Draw button pinned** — fixed or prominently bottom-positioned on mobile
- **Result number dominates** — should be the largest element on screen after a draw
- **Exclusion tags** — scrollable horizontally or wrap cleanly, with easy ×-remove on touch
- **CSV feedback** — show count of numbers imported and any that were skipped (duplicates / out of range)

### Error States

| Condition | Message |
|-----------|---------|
| Start > End | "Start must be less than or equal to end." |
| All numbers excluded | "No eligible numbers — all are excluded." |
| Exclusion out of range | "Number must be between {start} and {end}." |
| Duplicate exclusion | Silently ignored (no error flash needed) |
| CSV has no valid numbers | "No valid numbers found in the uploaded file." |
| CSV parse error | "Could not read the file. Make sure it's a plain .csv." |

---

## Mobile Optimization

### Viewport & Meta

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
<meta name="theme-color" content="#0f0d09" />
<meta name="apple-mobile-web-app-capable" content="yes" />
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
```

> `maximum-scale=1.0` prevents auto-zoom on input focus (iOS Safari behaviour).

### Layout Strategy

```
┌─────────────────────────┐
│  Header (compact)       │
├─────────────────────────┤
│  📱 Start screen record │  ← pre-draw reminder banner (dismissible)
│     before drawing! [✕] │
├─────────────────────────┤
│  Range inputs (2-col)   │
├─────────────────────────┤
│  Exclusion tags (wrap)  │
│  + Add input row        │
│  + CSV upload button    │
├─────────────────────────┤
│                         │
│   RESULT NUMBER         │  ← dominant, centered
│   (large, animated)     │
│                         │
├─────────────────────────┤
│  Pool size / status     │
├─────────────────────────┤
│  [    🎲 DRAW    ]      │  ← full-width, 64px tall, fixed or near bottom
└─────────────────────────┘
```

### Touch Target Sizing

```css
/* Minimum 48px tall for all interactive elements */
input[type="number"],
input[type="file"],
button {
  min-height: 48px;
}

/* Tag remove buttons — needs explicit sizing */
.tag-remove {
  min-width: 32px;
  min-height: 32px;
  padding: 4px 8px;
}
```

### Input Keyboard Types

```html
<!-- Numeric keypad on mobile for number fields -->
<input type="number" inputmode="numeric" pattern="[0-9]*" />
```

> Use both `type="number"` and `inputmode="numeric"` — `inputmode` controls the soft keyboard on iOS/Android more reliably.

### CSS: Mobile-first Approach

Write base styles for small screens first, then use `min-width` media queries to adjust for larger screens:

```css
/* Base: mobile */
.card { padding: 16px; }
.row  { grid-template-columns: 1fr 1fr; gap: 12px; }
.btn-draw { font-size: 1.2rem; padding: 18px; }

/* Tablet and up */
@media (min-width: 540px) {
  .card { padding: 32px 36px; }
  .btn-draw { font-size: 1.35rem; }
}
```

### Sticky Draw Button

On small screens, pin the Draw button so it's always visible without scrolling:

```css
.draw-footer {
  position: sticky;
  bottom: 0;
  background: var(--ink);
  padding: 12px 16px;
  border-top: 1px solid rgba(201,168,76,0.2);
  z-index: 10;
}

.btn-draw {
  width: 100%;
  height: 64px;
  font-size: 1.25rem;
}
```

### Prevent iOS Rubber-banding on Body

```css
html, body {
  height: 100%;
  overscroll-behavior: none;
}
```

### Safe Area Insets (iPhone notch / home bar)

```css
.draw-footer {
  padding-bottom: calc(12px + env(safe-area-inset-bottom));
}
```

---

## Persistence — localStorage

### Keys

| Key | Value | Example |
|-----|-------|---------|
| `ccd_start` | String (number) | `"1"` |
| `ccd_end` | String (number) | `"31"` |
| `ccd_exclusions` | JSON array of integers | `"[3,7,14,22]"` |

> Prefix `ccd_` (cash calendar draw) avoids collisions with other apps on the same domain.

**sessionStorage keys:**

| Key | Value | Lifetime |
|-----|-------|---------|
| `ccd_history` | JSON array of drawn numbers | Current session |
| `ccd_reminder_dismissed` | `"1"` | Current session — resets on next open |

### Save & Load Pattern

```javascript
// --- SAVE ---
function saveState() {
  localStorage.setItem('ccd_start', document.getElementById('start').value);
  localStorage.setItem('ccd_end',   document.getElementById('end').value);
  localStorage.setItem('ccd_exclusions', JSON.stringify(exclusions));
}

// --- LOAD on page init ---
function loadState() {
  const start      = localStorage.getItem('ccd_start');
  const end        = localStorage.getItem('ccd_end');
  const savedExcl  = localStorage.getItem('ccd_exclusions');

  if (start !== null) document.getElementById('start').value = start;
  if (end   !== null) document.getElementById('end').value   = end;

  if (savedExcl !== null) {
    try {
      exclusions = JSON.parse(savedExcl);
      if (!Array.isArray(exclusions)) exclusions = [];
    } catch {
      exclusions = [];
    }
  }

  renderTags();
  updatePoolInfo();
}

// --- CLEAR exclusions only ---
function clearExclusions() {
  if (!confirm('Remove all excluded numbers? This cannot be undone.')) return;
  exclusions = [];
  localStorage.removeItem('ccd_exclusions');
  renderTags();
  updatePoolInfo();
}

// Call loadState() on DOMContentLoaded
document.addEventListener('DOMContentLoaded', loadState);
```

### Auto-save Triggers

Call `saveState()` after every state change:

```javascript
function addExclusion(value) {
  // ... validation ...
  exclusions.push(num);
  exclusions.sort((a, b) => a - b);
  saveState();        // ← persist immediately
  renderTags();
  updatePoolInfo();
}

function removeExclusion(num) {
  exclusions = exclusions.filter(n => n !== num);
  saveState();        // ← persist immediately
  renderTags();
  updatePoolInfo();
}

// Also save when range inputs change
document.getElementById('start').addEventListener('change', saveState);
document.getElementById('end').addEventListener('change', saveState);
```

---

## CSV Import

### Expected CSV Format

The CSV may come from Excel or Google Sheets. Accept any of these layouts — the parser should handle all of them:

```
# Single column, no header
3
7
14
22
28

# Single column, with header
Unsold Calendars
3
7
14

# Multi-column — only first column used
Number,Name,Notes
3,Jane Doe,returned
7,Bob Smith,never picked up

# Comma-separated on one line (rare but possible)
3,7,14,22,28
```

### File Input HTML

```html
<label class="btn-csv" for="csvInput">
  📂 Import from CSV
</label>
<input type="file" id="csvInput" accept=".csv,text/csv" style="display:none;" />

<!-- Feedback line -->
<p class="csv-feedback" id="csvFeedback"></p>
```

> Using a styled `<label>` as the trigger keeps the visual button consistent with the rest of the UI. The actual `<input type="file">` is hidden.

### CSV Parser

```javascript
document.getElementById('csvInput').addEventListener('change', function (e) {
  const file = e.target.files[0];
  if (!file) return;

  const reader = new FileReader();

  reader.onload = function (evt) {
    const text = evt.target.result;
    parseCSV(text);
    // Reset input so same file can be re-uploaded if needed
    e.target.value = '';
  };

  reader.onerror = function () {
    showCSVFeedback('Could not read the file. Make sure it\'s a plain .csv.', 'error');
  };

  reader.readAsText(file);
});

function parseCSV(text) {
  const start = parseInt(document.getElementById('start').value, 10);
  const end   = parseInt(document.getElementById('end').value, 10);

  // Split into tokens: split on newlines AND commas, trim whitespace
  const tokens = text
    .split(/[\r\n,]+/)
    .map(t => t.trim())
    .filter(t => t.length > 0);

  let added   = 0;
  let skipped = 0; // duplicates or out-of-range

  tokens.forEach(token => {
    const num = parseInt(token, 10);

    // Skip non-numeric tokens (e.g. header row text)
    if (isNaN(num)) return;

    // Out of range
    if (num < start || num > end) { skipped++; return; }

    // Duplicate
    if (exclusions.includes(num)) { skipped++; return; }

    exclusions.push(num);
    added++;
  });

  exclusions.sort((a, b) => a - b);
  saveState();
  renderTags();
  updatePoolInfo();

  // User feedback
  if (added === 0 && skipped === 0) {
    showCSVFeedback('No numbers found in the file.', 'error');
  } else {
    const msg = `Imported ${added} number${added !== 1 ? 's' : ''}` +
                (skipped > 0 ? ` · ${skipped} skipped (duplicate or out of range)` : '');
    showCSVFeedback(msg, 'success');
  }
}

function showCSVFeedback(msg, type) {
  const el = document.getElementById('csvFeedback');
  el.textContent = msg;
  el.className   = 'csv-feedback ' + type; // style .success and .error differently
  // Auto-clear after 5 seconds
  setTimeout(() => { el.textContent = ''; el.className = 'csv-feedback'; }, 5000);
}
```

### CSV Feedback Styling

```css
.csv-feedback {
  font-family: 'DM Mono', monospace;
  font-size: 0.72rem;
  min-height: 18px;
  margin-top: 6px;
  transition: opacity 0.3s;
}
.csv-feedback.success { color: var(--green); }
.csv-feedback.error   { color: var(--red);   }
```

---

## Pre-Draw Reminder

A dismissible banner shown at the top of the page reminding the user to start iPhone screen recording **before** tapping Draw. iOS does not allow a web app to trigger screen recording programmatically — this banner is the next best thing.

Uses `sessionStorage` so it reappears at the start of each new browser session (i.e. next week's draw) but stays hidden once dismissed during the current session.

### Persistence Key

| Key | Storage | Value | Lifetime |
|-----|---------|-------|---------|
| `ccd_reminder_dismissed` | `sessionStorage` | `"1"` | Current session only — resets on next open |

### HTML

Place this banner at the top of `<main>`, before the range inputs card:

```html
<div class="reminder-banner" id="reminderBanner">
  <span class="reminder-icon">📱</span>
  <span class="reminder-text">
    Start your <strong>screen recording</strong> before drawing!
  </span>
  <button
    class="reminder-dismiss"
    onclick="dismissReminder()"
    aria-label="Dismiss reminder"
  >✕</button>
</div>
```

### JavaScript

```javascript
function loadReminder() {
  const dismissed = sessionStorage.getItem('ccd_reminder_dismissed');
  if (dismissed) {
    document.getElementById('reminderBanner').style.display = 'none';
  }
}

function dismissReminder() {
  document.getElementById('reminderBanner').style.display = 'none';
  sessionStorage.setItem('ccd_reminder_dismissed', '1');
}
```

Call `loadReminder()` inside `DOMContentLoaded` alongside `loadState()` and `loadHistory()`.

### CSS

```css
.reminder-banner {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(201,168,76,0.12);
  border: 1px solid rgba(201,168,76,0.4);
  border-radius: 2px;
  padding: 12px 14px;
  margin-bottom: 12px;
  font-family: 'DM Sans', sans-serif;
  font-size: 0.88rem;
  color: var(--gold-light);
  line-height: 1.4;
}

.reminder-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
}

.reminder-text {
  flex: 1;
}

.reminder-text strong {
  color: var(--gold);
}

.reminder-dismiss {
  background: none;
  border: none;
  color: rgba(201,168,76,0.45);
  font-size: 1rem;
  cursor: pointer;
  /* Touch-friendly target */
  min-width: 36px;
  min-height: 36px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 2px;
}
.reminder-dismiss:active { color: var(--red); }
```

---

## Core Logic

### Building the Eligible Pool

```javascript
function buildPool(start, end, exclusions) {
  const pool = [];
  for (let i = start; i <= end; i++) {
    if (!exclusions.includes(i)) pool.push(i);
  }
  return pool;
}
```

### Random Draw

```javascript
function draw(pool) {
  if (pool.length === 0) return null;
  return pool[Math.floor(Math.random() * pool.length)];
}
```

### Pool Info Display

Update this after every exclusion change and after every draw:

```javascript
function updatePoolInfo() {
  const start = parseInt(document.getElementById('start').value, 10);
  const end   = parseInt(document.getElementById('end').value, 10);
  const pool  = buildPool(start, end, exclusions);

  document.getElementById('poolInfo').textContent =
    isNaN(start) || isNaN(end) || start > end
      ? '—'
      : `${pool.length} of ${end - start + 1} numbers eligible`;

  document.getElementById('exclBadge').textContent =
    exclusions.length > 0 ? `${exclusions.length} excluded` : '';
}
```

### Validation Before Draw

```javascript
function validate(start, end) {
  if (isNaN(start) || isNaN(end))  return 'Please enter valid start and end numbers.';
  if (start > end)                  return 'Start must be less than or equal to end.';
  const pool = buildPool(start, end, exclusions);
  if (pool.length === 0)            return 'No eligible numbers — all are excluded.';
  return null;
}
```

### Handle Draw

```javascript
function handleDraw() {
  const start = parseInt(document.getElementById('start').value, 10);
  const end   = parseInt(document.getElementById('end').value, 10);

  const err = validate(start, end);
  if (err) {
    document.getElementById('errorMsg').textContent = err;
    return;
  }
  document.getElementById('errorMsg').textContent = '';

  const pool   = buildPool(start, end, exclusions);
  const winner = draw(pool);

  // Display result with animation
  const resultEl = document.getElementById('resultNumber');
  resultEl.textContent = winner;
  resultEl.classList.remove('spin');
  void resultEl.offsetWidth;        // force reflow to restart animation
  resultEl.classList.add('spin');

  document.getElementById('resultBox').classList.add('show');
  document.getElementById('resultSub').textContent =
    `Drawn from ${pool.length} eligible number${pool.length !== 1 ? 's' : ''}`;

  // Save to session history
  history.unshift(winner);
  sessionStorage.setItem('ccd_history', JSON.stringify(history));
  renderHistory();
}
```

---

## HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
  <meta name="theme-color" content="#0f0d09" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
  <title>Cash Calendar Draw</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet" />
  <style>/* --- All styles inline --- */</style>
</head>
<body>

  <!-- HEADER -->
  <header>
    <span class="badge">Fundraiser Tool</span>
    <h1>Cash Calendar <span>Draw</span></h1>
  </header>

  <!-- SCROLLABLE CONTENT AREA -->
  <main>

    <!-- Pre-draw reminder -->
    <div class="reminder-banner" id="reminderBanner">
      <span class="reminder-icon">📱</span>
      <span class="reminder-text">
        Start your <strong>screen recording</strong> before drawing!
      </span>
      <button class="reminder-dismiss" onclick="dismissReminder()" aria-label="Dismiss reminder">✕</button>
    </div>

    <!-- Range inputs -->
    <section class="card">
      <div class="row">
        <div class="field">
          <label for="start">Start</label>
          <input type="number" id="start" value="1" min="0" inputmode="numeric" pattern="[0-9]*" />
        </div>
        <div class="field">
          <label for="end">End</label>
          <input type="number" id="end" value="31" min="0" inputmode="numeric" pattern="[0-9]*" />
        </div>
      </div>
      <p class="pool-info" id="poolInfo">— eligible numbers</p>
    </section>

    <!-- Exclusion list -->
    <section class="card">
      <div class="section-header">
        <label>Unsold Calendars <span class="excl-badge" id="exclBadge"></span></label>
        <button class="btn-text-danger" onclick="clearExclusions()">Clear all</button>
      </div>

      <!-- Tags -->
      <div class="tags-wrap" id="tagsWrap">
        <span id="emptyMsg" class="empty-msg">No exclusions — all numbers eligible</span>
      </div>

      <!-- Manual entry -->
      <div class="exclude-input-row">
        <input
          type="number"
          id="excludeInput"
          placeholder="Add number…"
          inputmode="numeric"
          pattern="[0-9]*"
        />
        <button class="btn-add" onclick="handleAddExclusion()">Add</button>
      </div>

      <!-- CSV import -->
      <div class="csv-row">
        <label class="btn-csv" for="csvInput">📂 Import CSV</label>
        <input type="file" id="csvInput" accept=".csv,text/csv" style="display:none;" />
        <p class="csv-feedback" id="csvFeedback"></p>
      </div>
    </section>

    <!-- Result display -->
    <section class="result-section" id="resultBox">
      <p class="result-label">Winner</p>
      <div class="result-number" id="resultNumber">?</div>
      <p class="result-sub" id="resultSub">Tap Draw to begin</p>
    </section>

    <!-- Error message -->
    <p class="error-msg" id="errorMsg"></p>

    <!-- Draw history -->
    <section class="history-section" id="historySection">
      <div class="history-header">
        <span class="history-title">Session History</span>
        <button class="btn-text" onclick="clearHistory()">Clear</button>
      </div>
      <div class="history-list" id="historyList"></div>
    </section>

  </main>

  <!-- STICKY DRAW BUTTON FOOTER -->
  <div class="draw-footer">
    <button class="btn-draw" id="drawBtn" onclick="handleDraw()">
      🎲 &nbsp;Draw a Number
    </button>
  </div>

  <script>/* --- All JavaScript inline --- */</script>
</body>
</html>
```

---

## CSS Notes

### CSS Variables

```css
:root {
  --gold:         #c9a84c;
  --gold-light:   #e8c96b;
  --gold-dim:     #7a6030;
  --ink:          #0f0d09;
  --paper:        #faf6ee;
  --paper-dark:   #f0e9d8;
  --red:          #c0392b;
  --green:        #1a6b3c;

  /* Spacing scale */
  --sp-xs: 6px;
  --sp-sm: 12px;
  --sp-md: 16px;
  --sp-lg: 24px;
}
```

### Page Layout (mobile-first, sticky footer)

```css
html, body {
  height: 100%;
  overscroll-behavior: none;
}

body {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: var(--ink);
}

main {
  flex: 1;
  overflow-y: auto;
  padding: var(--sp-md);
  padding-bottom: 100px; /* clear sticky footer */
  display: flex;
  flex-direction: column;
  gap: var(--sp-md);
}

/* Sticky draw button */
.draw-footer {
  position: sticky;
  bottom: 0;
  background: var(--ink);
  border-top: 1px solid rgba(201,168,76,0.2);
  padding: var(--sp-sm) var(--sp-md);
  padding-bottom: calc(var(--sp-sm) + env(safe-area-inset-bottom));
  z-index: 10;
}

.btn-draw {
  width: 100%;
  height: 64px;
  font-family: 'Playfair Display', serif;
  font-size: 1.25rem;
  background: var(--ink);
  color: var(--gold-light);
  border: 1px solid var(--gold);
  cursor: pointer;
  border-radius: 2px;
  letter-spacing: 0.05em;
}
.btn-draw:active { transform: scale(0.98); }
```

### Result Number

```css
.result-section {
  text-align: center;
  padding: var(--sp-lg) 0;
}

.result-number {
  font-family: 'Playfair Display', serif;
  font-size: clamp(5rem, 28vw, 9rem);
  font-weight: 900;
  color: var(--paper);
  line-height: 1;
}

.result-number.spin {
  animation: popIn 0.45s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes popIn {
  0%   { opacity: 0; transform: scale(0.5) rotate(-8deg); }
  70%  { opacity: 1; transform: scale(1.08) rotate(2deg); }
  100% { opacity: 1; transform: scale(1) rotate(0deg); }
}
```

### Exclusion Tags (touch-friendly)

```css
.tags-wrap {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-xs);
  min-height: 40px;
  padding: var(--sp-xs);
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(201,168,76,0.2);
  border-radius: 2px;
  margin-bottom: var(--sp-sm);
}

.tag {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: var(--ink);
  color: var(--gold-light);
  font-family: 'DM Mono', monospace;
  font-size: 0.8rem;
  padding: 6px 10px;
  border-radius: 2px;
  border: 1px solid var(--gold-dim);
}

.tag button {
  /* Minimum touch target */
  min-width: 28px;
  min-height: 28px;
  background: none;
  border: none;
  color: rgba(232,201,107,0.5);
  cursor: pointer;
  font-size: 1rem;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
.tag button:active { color: var(--red); }
```

---

## JavaScript Logic

### Complete State Variables

```javascript
let exclusions = []; // persisted to localStorage
let history    = []; // persisted to sessionStorage
```

### Initialization

```javascript
document.addEventListener('DOMContentLoaded', () => {
  loadState();
  loadHistory();
  loadReminder(); // ← show/hide pre-draw reminder based on sessionStorage

  // Auto-save range on change
  document.getElementById('start').addEventListener('change', () => {
    saveState();
    updatePoolInfo();
  });
  document.getElementById('end').addEventListener('change', () => {
    saveState();
    updatePoolInfo();
  });

  // Add exclusion on Enter key
  document.getElementById('excludeInput').addEventListener('keydown', e => {
    if (e.key === 'Enter') handleAddExclusion();
  });

  // Comma-paste / bulk entry detection
  document.getElementById('excludeInput').addEventListener('input', e => {
    if (e.target.value.includes(',')) {
      e.target.value.split(',').forEach(v => addExclusion(v.trim()));
      e.target.value = '';
    }
  });

  // CSV file listener
  document.getElementById('csvInput').addEventListener('change', handleCSVUpload);
});
```

### Function Summary

| Function | Description |
|----------|-------------|
| `loadState()` | Reads `localStorage`, populates inputs and `exclusions[]`, calls `renderTags()` + `updatePoolInfo()` |
| `saveState()` | Writes start, end, and `exclusions[]` to `localStorage` |
| `loadHistory()` | Reads `sessionStorage` into `history[]`, calls `renderHistory()` |
| `loadReminder()` | Checks `sessionStorage` — hides reminder banner if already dismissed this session |
| `dismissReminder()` | Hides reminder banner, sets `ccd_reminder_dismissed` in `sessionStorage` |
| `addExclusion(value)` | Validates, pushes to `exclusions[]`, calls `saveState()` + `renderTags()` + `updatePoolInfo()` |
| `removeExclusion(num)` | Filters `exclusions[]`, calls `saveState()` + `renderTags()` + `updatePoolInfo()` |
| `clearExclusions()` | Confirm dialog → clears `exclusions[]` + `localStorage` key |
| `handleCSVUpload(e)` | Reads file via `FileReader`, calls `parseCSV()` |
| `parseCSV(text)` | Tokenizes, validates, merges into `exclusions[]`, calls `saveState()` + `showCSVFeedback()` |
| `showCSVFeedback(msg, type)` | Sets feedback text, auto-clears after 5s |
| `buildPool(start, end, exclusions)` | Returns eligible number array |
| `draw(pool)` | Returns random element |
| `validate(start, end)` | Returns error string or `null` |
| `handleDraw()` | Orchestrates validate → draw → animate → history |
| `renderTags()` | Re-renders all exclusion chip elements |
| `updatePoolInfo()` | Updates pool count label and exclusion badge |
| `renderHistory()` | Re-renders session history list |
| `clearHistory()` | Clears `history[]` + `sessionStorage` key |

---

## GitHub Pages Setup

### 1. Create the Repository

```bash
# On GitHub.com:
# New repo → name: cash-calendar-draw → Public → Create

git clone https://github.com/YOUR_USERNAME/cash-calendar-draw.git
cd cash-calendar-draw
```

### 2. Add Your Files

```bash
git add index.html README.md
git commit -m "feat: cash calendar draw v2 — persistent exclusions, CSV import, mobile-first"
git push origin main
```

### 3. Enable GitHub Pages

1. Repo → **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: `main` / Folder: `/ (root)`
4. **Save**

Live at: `https://YOUR_USERNAME.github.io/cash-calendar-draw/`

### 4. Optional: GitHub Actions Auto-Deploy

`.github/workflows/pages.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  pages: write
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v4
      - uses: actions/upload-pages-artifact@v3
        with:
          path: '.'
      - uses: actions/deploy-pages@v4
```

---

## Future Enhancements

| Feature | Notes |
|---------|-------|
| **Export exclusion list** | Download current exclusions as `.csv` for backup |
| **Named draw sessions** | Label each weekly draw (e.g. "Week 3 — May 18") |
| **Block re-draws** | Prevent same number winning twice across sessions |
| **Shareable URL** | Encode range + exclusions in the URL hash for sharing |
| **Sound effect** | Optional drum roll or cash register on draw |
| **PWA / installable** | Add `manifest.json` + service worker so it installs like an app on iPhone home screen |
| **QR code** | Display QR to live URL so ticket holders can follow along |
| **Date-based auto-range** | Auto-set end number to days-in-current-month |

---

## README.md Template

```markdown
# 🎰 Cash Calendar Draw

Random number generator for weekly cash calendar fundraiser draws.

## Features

- Set a number range (e.g. 1–31)
- Exclude unsold calendar numbers — **saved automatically between draws**
- Import unsold numbers from a `.csv` file
- Full draw history for the current session
- Pre-draw reminder to start screen recording
- Works on smartphones

## How to Use

1. Set **Start** and **End** numbers for your calendar range.
2. Add **unsold calendar numbers** to the exclusion list (they'll be remembered next week).
3. **Start your iPhone screen recording** from Control Center before tapping Draw.
4. Tap **Draw a Number** to pick a winner from sold calendars only.
5. To update exclusions for the next week, add or remove numbers — changes save instantly.

## Importing from a Spreadsheet

1. Open your sales tracking spreadsheet.
2. Copy the unsold calendar numbers into a single column.
3. Save / export as `.csv`.
4. Tap **Import CSV** in the app and select the file.

## Live App

👉 [Open the Draw App](https://YOUR_USERNAME.github.io/cash-calendar-draw/)

## Local Use

No install required — open `index.html` in any browser.
```

---

*Built for community fundraisers. Single-file, no server, works offline after first load.*
