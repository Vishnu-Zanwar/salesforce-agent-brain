# #LWE006: Two JavaScript Traps — Falsy Zero and UTC Date Strings

- **PINCODE:** `#LWE006`
- **Topic:** JavaScript Fundamentals / Salesforce Time & Date Serialization
- **Domain:** LWC
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 10 (Medium severity)

---

## 🛑 1. The Problem

**Trap one.** `!x` is true for `0`, `''`, `NaN`, `false`, `null`, and `undefined`. Whenever a legitimate value can be any of those, `!x` is the wrong guard for "missing." Salesforce `Time` fields serialize as **milliseconds from midnight** — so midnight is `0`, which is falsy.

**Trap two.** ECMAScript specifies a *date-only* ISO string (`"2026-03-15"`) is parsed as **UTC**, while a date-*time* string without a zone is parsed as local. So `new Date('2026-03-15')` is midnight UTC, and `.toLocaleDateString()` on it shows the *previous day* to anyone west of Greenwich.

## 🔎 2. Where It Goes Wrong

```javascript
const formatTime = (timeVal) => {
  if (!timeVal) return "";     // ← 0 is a valid time: midnight
  ...
```
A session scheduled 00:00–02:00 (real for global cohorts, or a badly-imported record) formats to `""` and falls through to "Time TBD" for a session that has a perfectly good time.

```javascript
const d = new Date(dateVal);          // ← UTC for "YYYY-MM-DD"
return isNaN(d.getTime()) ? "" : d.toLocaleDateString();
```
A cohort starting `2026-03-15` renders correctly from IST (ahead of UTC) and as **March 14** from New York. Off-by-one-day bugs like this reach production constantly, precisely because the developer's own timezone hides them during testing.

## ✅ 3. The Fix

Guard on the actual missing condition, not on JS truthiness:
```javascript
const formatTime = (timeVal) => {
  if (timeVal === null || timeVal === undefined) return "";   // 0 is valid
  ...
```
Parse date-only strings as local, not UTC — either construct with explicit year/month/day, or use a helper the codebase already had but wasn't calling (worth checking for one before writing a new parser).

## 🧭 4. How to Recognize This

- Any `if (!x)` guarding a value where `0` is a legitimate, meaningful value (times, counts, indices, offsets).
- Any `new Date(dateOnlyString)` followed by locale-formatting for display — test it from a timezone behind UTC before trusting it.
- Salesforce field types worth double-checking: `Time` (ms from midnight — 0 is real), `Date` (date-only ISO — UTC parse trap).
