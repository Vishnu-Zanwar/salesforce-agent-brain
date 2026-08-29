# #LWE002: lwc:spread Silently Drops Unmatched Public Properties

- **PINCODE:** `#LWE002`
- **Topic:** LWC Templates / Parent-Child Data Binding
- **Domain:** LWC
- **Created Date:** 2026-08-29
- **Last Verified:** 2026-08-29
- **Status:** Active

---

## 🛑 1. The Problem

`lwc:spread` spreads every key of an object onto a child component's public (`@api`) properties in one shot:

```html
<c-child2 lwc:spread={contact}></c-child2>
```

If `contact` has keys the child never declared with `@api` (e.g. `{ firstName, lastName, email, accountId, contactId }` spread onto a child that only declares `@api firstName/lastName/email`), the extra keys (`accountId`, `contactId`) are **silently dropped** — no compiler error, no runtime warning, no console message. The child component just never receives them, and nothing in the UI tells you why.

This is easy to miss because everything *looks* correct: the template compiles, the app runs, no error anywhere in the console.

## 🔎 2. Root Cause

`lwc:spread` bypasses the compiler's static verification of prop bindings — normal explicit bindings (`account={account}`) are checked against the child's declared `@api` properties at build time, but a spread object's shape is only known at runtime, so there's nothing to check against. Salesforce's own documentation flags `lwc:spread` as something to avoid for exactly this reason.

## ✅ 3. Fix

Prefer explicit bindings over `lwc:spread` whenever the source object has any keys the child doesn't need — which is nearly always, since data objects usually carry more fields than any one child component's UI needs:

```html
<!-- ❌ Fragile: silently drops accountId/contactId, no signal anything's wrong -->
<c-child2 lwc:spread={contact}></c-child2>

<!-- ✅ Explicit: compiler-verified, and it's obvious at a glance what the child receives -->
<c-child2
    first-name={contact.firstName}
    last-name={contact.lastName}
    email={contact.email}>
</c-child2>
```

If you must use `lwc:spread` (e.g. genuinely dynamic prop sets), verify at development time that the child declares an `@api` property for every key the spread source can produce — and re-check that list whenever either side changes, since nothing else will catch drift between them.

## 🧭 4. How to Recognize This Before It Happens

- Any `lwc:spread={obj}` in a template is worth a second look: list the object's keys, list the child's `@api` properties, and confirm they match exactly.
- If a child component seems to be missing data that's clearly present in the parent's object, and there's no console error at all, `lwc:spread` key mismatch is one of the first things to check.
