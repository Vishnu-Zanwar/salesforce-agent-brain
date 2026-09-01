# LWL003 — LDS Stale Cache After DML: refreshApex Pattern

**Domain:** LWC
**Pillar:** Learning
**Date:** 2026-09-01
**Tags:** `refreshApex` `@wire` `LDS` `cacheable=true` `DML` `cache invalidation` `isUserRegistered` `CourseOfferingParticipant`

---

## The Problem

When you call an **imperative DML method** (like `registerUser`) from an LWC,
the Salesforce **Lightning Data Service (LDS)** client-side cache does **not know**
that the database has changed. Any `@wire` adapter decorated with `cacheable=true`
will keep serving the old cached response until it naturally expires.

### What breaks

```
Page load  ->  @wire(isUserRegistered)  ->  Apex returns null (not registered)
               LDS caches: null

User registers  ->  registerUser DML  ->  DB record inserted OK

.then() fires  ->  this.isregister = true  <- JS memory only patch

User reloads page  ->  @wire fires again from LDS cache  ->  returns null
                        ->  wiredUserRegistration sets isregister = false  <- REVERTED
```

The UI shows the user as "Not Registered" even though the DML succeeded.

---

## Why It Happens

`@wire` adapters backed by `@AuraEnabled(cacheable=true)` Apex methods are
served through LDS. LDS caches responses **per unique parameter set** on the
client. Calling an unrelated imperative method (DML) **does not invalidate** that
cache. LDS has no way to know those two are related.

Simply patching `this.isregister = true` in `.then()` is a **JS-only hack** - 
it works until the next time the wire adapter fires and overwrites it with
stale cached data.

---

## The Fix: refreshApex

`refreshApex()` explicitly tells LDS: invalidate the cached result for this
specific wire adapter instance and re-fetch from Apex.

### Critical requirement
`refreshApex()` needs the **entire provisioned wire result object**, not
destructured data/error values. This means the wire handler must be
changed from the destructuring pattern to the stored-object pattern.

---

## Real Code Before and After

### Step 1: Add refreshApex import
```js
// refreshApex comes from @salesforce/apex - NOT from lwc
import { refreshApex } from "@salesforce/apex";
```

### Step 2: Store the full wire result object as a class property
```js
wiredUserRegistrationResult;
```

### Step 3: Change wire handler signature
```js
// BEFORE - destructuring throws away the full object
@wire(isUserRegistered, { recordId: "$recordId" })
wiredUserRegistration({ error, data }) {
    if (data !== undefined) {
        this.isregister = data !== null;
    }
}

// AFTER - store the full result first, then destructure locally
@wire(isUserRegistered, { recordId: "$recordId" })
wiredUserRegistration(result) {
    this.wiredUserRegistrationResult = result;
    const { data, error } = result;
    if (data !== undefined) {
        this.isregister = data !== null;
    }
}
```

### Step 4: Replace manual JS patch with refreshApex in .then()
```js
// BEFORE - unreliable manual patch
.then(() => {
    this.isregister = true;
    this.showToast(...);
})

// AFTER - invalidates cache, wire re-fetches from DB
.then(() => {
    this.showToast(...);
    return refreshApex(this.wiredUserRegistrationResult);
})
```

The `return` is important - it chains the promise so .then() waits for
cache bust to complete. After refreshApex resolves, wiredUserRegistration
fires automatically with fresh Apex data. No manual patching needed.

---

## 5 Approaches Compared

| Approach | Lines Changed | Re-fetches Server | Cache-safe on Reload |
|---|---|---|---|
| refreshApex() | Medium | Yes | Yes |
| Pure Imperative (connectedCallback) | Medium | Yes | Yes |
| Optimistic UI Guard (boolean flag) | Minimal | No | Yes |
| Reactive Param Trick (_cacheKey++) | Small | Yes | Yes |
| getRecordNotifyChange() | Minimal | Yes | Unreliable for custom Apex |

---

## How to Recognize This Pattern Next Time

- Imperative DML Apex method called from LWC
- On success you manually set a boolean (this.isXxx = true)
- UI looks correct immediately after DML but REVERTS on page reload
- There is a @wire backed by cacheable=true Apex watching the same data
- Wire handler uses destructuring pattern ({ data, error }) instead of storing full result

---

## Related PINCODEs

- LWE001 - Mutating immutable @wire property
- APL001 - Apex and LWC Performance Engineering: N+1 Wire Prevention
