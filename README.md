# Cash Calendar Draw Helper

Single-file web app for cash calendar fundraiser draws organized into weekly draws.

## Implemented in this version

- Start/end range validation
- Unsold-number exclusions with local persistence
- CSV import for exclusions
- **Week-based draw system**: Enter starting date (e.g., June 1), year, then draws auto-increment by calendar day
- 7 draws per week automatically grouped into Week 1, Week 2, etc.
- Draw names auto-generate as "Week X - Day Name, Date"
- Persistent draw history UI (newest first)
- Safer delete flow: checkbox-select records, then confirm delete
- Mobile-first layout and sticky draw button
- Pre-draw screen-recording reminder per session
- Optional Firebase Firestore sync for shared phone/PC history

## Repository

https://github.com/robwinship/cash-calendar-draw-helper

## Files

- index.html: full app (HTML/CSS/JS in one file)
- README.md: setup and usage

## Quick start (local)

1. Open `index.html` in a browser.
2. Set start/end number range (1–31 for a calendar).
3. Enter **Week Starting Date** (e.g., June 1, 2026) and **Year**.
4. Add unsold numbers manually or with CSV import.
5. Tap **Draw a Number** — it will generate a draw named "Week 1 - Monday, June 1", then "Week 1 - Tuesday, June 2", etc.
6. After 7 draws, the next draw starts "Week 2 - Monday, June 8".
7. History shows all draws with week grouping.

Without Firebase configuration, history still persists locally in the browser.

## Week-Based Draw Logic

- **Starting Date**: Set the first date of your draw period (e.g., June 1, 2026).
- **Auto-Increment**: Each draw advances by 1 calendar day.
- **Grouping**: Days 1–7 are "Week 1", days 8–14 are "Week 2", etc.
- **Draw Names**: Auto-generated as "Week X - Day Name, Date" (e.g., "Week 2 - Thursday, June 8").
- **Next Draw Indicator**: Shows which week you're in and what day is coming next.

## Enable shared history across phone and PC (Firebase)

This app is ready for cloud sync, but you must fill Firebase config values.

### 1) Create Firebase project

1. Go to Firebase Console.
2. Create a project.
3. Enable Firestore Database (production or test mode).
4. In Project Settings, add a Web App and copy config values.

### 2) Paste config in index.html

In `index.html`, find `firebaseConfig` and fill:

- apiKey
- authDomain
- projectId
- storageBucket
- messagingSenderId
- appId

### 3) Firestore collection

The app uses collection: `drawHistory`

Each record includes:

- id
- drawName
- winnerNumber
- createdAt
- rangeStart
- rangeEnd
- exclusionCount
- poolSize
- week (auto-calculated)
- drawIndex (position in sequence)

### 4) Suggested Firestore rules (starter)

Use stricter rules before public release.

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /drawHistory/{docId} {
      allow read: if true;
      allow create, update, delete: if true;
    }
  }
}
```

For production, replace open write access with authenticated rules.

## Deployment (GitHub Pages)

1. Push repository to GitHub.
2. In repo settings, open Pages.
3. Set source to `main` branch and `/ (root)`.
4. Save.

Live URL format:

`https://<your-username>.github.io/cash-calendar-draw-helper/`

## Notes

- Exclusions and range are stored in localStorage per device/browser.
- Week start date and year are stored and reused between sessions.
- Shared history needs Firebase configured in the same project across devices.
- There is no one-click clear-all history button in UI for safety.
