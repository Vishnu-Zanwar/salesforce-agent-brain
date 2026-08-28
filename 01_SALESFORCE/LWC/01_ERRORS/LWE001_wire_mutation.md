# #LWE001: Mutating Immutable @wire Property Directly

- **PINCODE:** `#LWE001`
- **Topic:** Lightning Data Service Proxy Immutability
- **Domain:** LWC / Reactive Data
- **Created Date:** 2026-08-21
- **Last Verified:** 2026-08-28
- **Status:** Active
- **Related:** [[APL001]], [[LWL002]]

---

## 🛑 1. The Error

```
TypeError: 'set' on proxy: trap returned falsish for property 'isSelected'
```

Thrown when a component tries to mutate a property directly on data returned from `@wire`, e.g.:

```javascript
// ❌ ANTI-PATTERN — crashes with the proxy error above
this.wiredAccounts.forEach(acc => acc.isSelected = false);
```

## 🔎 2. Root Cause

Data provisioned via `@wire` (or returned from an imperative Apex call cached by Lightning Data Service) is emitted as an **immutable `Proxy` object**. LDS wraps the response so the framework can track reactivity and prevent components from silently corrupting a shared cache entry that other components may also be reading. Any direct property assignment on that proxy — even setting a field to the same value — throws.

This is not a one-off quirk: it applies to any object or array that came out of `@wire`, including nested objects inside a list.

## ✅ 3. Verified Fix

Shallow-clone (or deep-clone, if mutating nested fields) before mutating:

```javascript
// ✅ Shallow-clone objects out of the proxy before mutating
this.accounts = this.wiredAccounts.map(acc => ({
    ...acc,
    isSelected: false
}));
```

For nested objects that also need mutation, spread at each level you touch:

```javascript
this.accounts = this.wiredAccounts.map(acc => ({
    ...acc,
    schedule: { ...acc.schedule, isConfirmed: true }
}));
```

## 🧭 4. How to Recognize This Before It Happens

- Any variable assigned from `@wire(...)` or from `.then()` on an imperative Apex call is a candidate.
- If you're about to write `wiredData.someProp = x` or `wiredData.push(...)`, stop and clone first.
- Prefer keeping a separate local, mutable copy in component state (`this.accounts`) rather than mutating the wired reference (`this.wiredAccounts`) at all — read from wired data once, transform into local state, mutate the local state from then on.
