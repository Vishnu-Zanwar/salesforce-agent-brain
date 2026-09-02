# #APE007: Catch Blocks Are Code Too

- **PINCODE:** `#APE007`
- **Topic:** Apex Exception Handling / Typed vs String Matching
- **Domain:** Apex
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 07 (Medium severity)

---

## 🎯 1. The Concept

Two rules people forget. **First:** an exception thrown *inside* a `catch` block is not caught by that same `try`'s other catch blocks — they're siblings, not a chain. It propagates straight out of the method. **Second:** matching on an exception's *message text* means matching on a localized, version-dependent string — match on the typed API instead.

## 🛑 2. Where It Goes Wrong

```apex
} catch (DmlException de) {
  String dmlMsg = de.getDmlMessage(0);        // null when getNumDml() == 0
  if (dmlMsg.contains('is full') || ...) {    // ← NullPointerException, here
    throw createAuraException('This course offering is currently full…');
  }
} catch (Exception e) {                       // ← never runs for that NPE
  ...
}
```
`getDmlMessage(0)` returns null when the exception carries no per-row DML results — exactly the case for `DmlException`s raised by triggers or limits. `.contains()` then throws an NPE *inside* the catch, so `catch (Exception e)` below it never runs. The one scenario this block existed to handle is the one it fails on.

Also fragile: `.contains('is full')` is English prose. Change the user's language or let Salesforce reword the message and the branch silently stops matching — nothing breaks loudly, it just quietly stops working.

## ✅ 3. The Fix

```apex
} catch (DmlException de) {
  Boolean hasRows = de.getNumDml() > 0;
  Boolean isFull = hasRows && (
       de.getDmlType(0) == StatusCode.LIMIT_EXCEEDED
    || de.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION
  );
  if (isFull) {
    throw createAuraException('This offering is full and can\'t accept more registrations.');
  }
  System.debug(LoggingLevel.ERROR, de.getStackTraceString());  // detail stays server-side
  throw createAuraException('We couldn\'t complete your registration. Please try again.');
}
```
Related defect worth flagging separately: a generic `catch (Exception e) { throw createAuraException(e.getMessage()); }` forwards **raw internal messages to the browser** — field API names, SOQL fragments, sometimes record Ids. That's information disclosure. Log detail server-side, return a message you chose.

## 🧭 4. Other Ways to Solve It

- **Check capacity before the insert** — better UX, but it's *another* check-then-act ([[APE003]]); keep the DML catch as the real backstop.
- **Custom exception types** (e.g. `OfferingFullException`), thrown by a validation helper and caught by type — readable at the throw site. Only covers failures *you* raise; the platform still throws `DmlException`.
- **`Database.insert(list, false)`** — read `SaveResult.getErrors()[0].getStatusCode()` directly, no try/catch, honest partial-success handling for multi-record writes.

## 🔎 5. How to Recognize This

- Any catch block that calls a method (`.getDmlMessage()`, `.contains()`) on a value that can be null without checking first.
- Any branch matching on `e.getMessage().contains(...)` instead of a typed status code or exception type.
- A generic catch that forwards `e.getMessage()` straight to a client-facing exception.
