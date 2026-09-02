# #LWE005: "Failed" and "Empty" Are Different States, and Users Can Tell

- **PINCODE:** `#LWE005`
- **Topic:** LWC Wire Adapters / Error State Handling
- **Domain:** LWC
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 09 (Medium severity)
- **Related:** [[LWE001]]

---

## 🛑 1. The Problem

A wire adapter emits `{ data, error }` and exactly one is ever populated. That gives **three** UI states, not two: *loading*, *loaded* (possibly zero rows), and *failed*. Collapsing "failed" into "empty" tells the user a confident lie and destroys your only diagnostic signal.

## 🔎 2. Where It Goes Wrong

```javascript
// error object assigned nowhere, logged nowhere
} else if (error) {
  this.courseOfferingsData = [];
}

// .error is never read at all
get isLoading() {
  return !this.wiredOfferingsResult ||
    (!this.wiredOfferingsResult.data && !this.wiredOfferingsResult.error);
}   // ↑ false once EITHER arrives — an error falls through silently
```
Apex throws — a bad recordId, an FLS change, a governor limit. The template renders *"No Cohorts Currently Available"* and removes the Confirm button. The user reads a confident, wrong sentence and leaves. Support gets a ticket saying the course has no cohorts. Nobody has an error to look at.

## ✅ 3. The Fix

```javascript
get hasError() {
  return Boolean(this.wiredOfferingsResult && this.wiredOfferingsResult.error);
}
get errorMessage() {
  const e = this.wiredOfferingsResult && this.wiredOfferingsResult.error;
  return (e?.body?.message) || 'We couldn\'t load the offerings for this course.';
}
```
```html
<template lwc:if={isLoading}>        <!-- spinner --></template>
<template lwc:elseif={hasError}>     <!-- error + Retry --></template>
<template lwc:elseif={hasOfferings}> <!-- the grid --></template>
<template lwc:else>                  <!-- genuine empty --></template>
```
Three things make the error state useful: it offers a way forward (Retry via `refreshApex`), it shows a message *you* chose rather than raw Apex text ([[APE007]]), and the failure is reported somewhere durable — `console.error` vanishes the moment the tab closes.

## 🧭 4. Other Ways to Solve It

- **Inline banner instead of a full-page state** — keep rendering whatever loaded, show a dismissible error above it. Right shape for partial failure. Risk: easy to dismiss and forget while acting on half-loaded data.
- **A toast** — cheap and consistent if the app already has a toast helper. Toasts disappear; never use one as the *only* signal for a state that persists.
- **Verbose message in lower environments only** — useful for support/QA behind a debug flag, but a misconfigured flag in production reopens information disclosure ([[APE007]]).

## 🔎 5. How to Recognize This

- Any `isLoading` getter that only checks `data`, not `error`.
- Any `else` branch after a data check that silently treats an error the same as zero rows.
