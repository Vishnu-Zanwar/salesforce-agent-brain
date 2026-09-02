# #APE003: Read-Then-Write Is Not Atomic

- **PINCODE:** `#APE003`
- **Topic:** Apex Concurrency / Check-Then-Act Races
- **Domain:** Apex
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 03 (High severity)

---

## 🎯 1. The Concept

A `SELECT` to see whether something exists, followed by an `INSERT` if it doesn't, is a **check-then-act race**. Two concurrent transactions both run the SELECT before either commits, both see nothing, both insert. Not a Salesforce quirk — the oldest concurrency bug there is. **The only dedupe you can rely on is one the database enforces.**

## 🛑 2. Where It Goes Wrong

Two defects compounding: the UI sets no in-flight flag or `disabled` binding on the submit button, and the Apex guard is exactly the "check" half of check-then-act:

```apex
Set<Id> existingOfferingIds = new Set<Id>();
for (CourseOfferingParticipant existing : [ SELECT ... ]) {   // ← the check
  existingOfferingIds.add(existing.CourseOfferingId);
}
...
insert copList;                                                // ← the act
```
A user on a slow connection double-clicks Confirm. Requests A and B both reach the method. A's SELECT finds nothing. B's SELECT also finds nothing — A hasn't committed yet. Both insert. Two enrolled rows, every downstream roll-up and capacity check now wrong.

## ✅ 3. The Fix

Fix both layers, but be clear only the second is the actual fix — the UI guard just removes the common case:

```javascript
isRegistering = false;
handleregister() {
  if (this.isRegistering) return;
  this.isRegistering = true;
  registerUser({ ... }).then(...).finally(() => { this.isRegistering = false; });
}
```
The real fix: a **unique key the platform enforces** — a text field `Registration_Key__c`, External Id + Unique, populated in a before-insert trigger as `ParticipantContactId + '-' + CourseOfferingId`. The second insert is rejected with `DUPLICATE_VALUE` no matter how it arrives — concurrent request, Data Loader, Flow, or retry.

## 🧭 4. Other Ways to Solve It

- **`FOR UPDATE` on the SELECT** — locks matching rows so a second transaction waits. Wrong tool *here*: both transactions are inserting brand-new rows, nothing exists yet to lock. Use it for read-then-*update* races (e.g. a seat counter), not read-then-*insert*.
- **`Database.insert(records, false)`** — pairs with the unique-key fix; inspect `SaveResult` and turn `DUPLICATE_VALUE` into a message the user can act on.
- **A platform Duplicate Rule** (no code) — declarative, but has known gaps under high concurrency/bulk operations. Defence in depth, never the only control.

## 🔎 5. How to Recognize This

- Any `SELECT ... exists? then INSERT` pattern with no database-enforced uniqueness backing it.
- A submit button with no in-flight guard on a network-dependent action.
- Ask: "what happens if this exact request arrives twice, milliseconds apart, before either commits?"
