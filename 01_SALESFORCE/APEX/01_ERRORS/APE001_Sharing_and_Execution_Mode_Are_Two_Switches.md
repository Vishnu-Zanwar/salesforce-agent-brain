# #APE001: Sharing and Execution Mode Are Two Switches, Not One

- **PINCODE:** `#APE001`
- **Topic:** Apex Security / Sharing Rules & CRUD-FLS Enforcement
- **Domain:** Apex
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 01 (High severity)
- **Related:** [[APE002]]

---

## 🎯 1. The Concept

Apex runs in system context by default: no sharing rules, no object permissions, no field-level security. Two **independent** switches turn parts of that back on:

- **The class keyword** — `with sharing` / `without sharing` / `inherited sharing` — controls **record-level** access (OWD, sharing rules, role hierarchy).
- **The query mode** — `WITH USER_MODE` / `WITH SYSTEM_MODE`, or `AccessLevel.USER_MODE` on DML — controls **object CRUD and field-level security**.

The trap: assuming `with sharing` also enforces FLS — it doesn't. And the reverse: `WITH USER_MODE` enforces object permissions, FLS, **and** sharing rules, overriding the class keyword. `USER_MODE` is the stronger default; the keyword governs whatever you leave in system mode.

## 🛑 2. Where It Goes Wrong

```apex
public without sharing class course {          // record access off
  ...
    FROM LearningCourse
    WHERE Id = :recordId
    WITH SYSTEM_MODE                            // FLS and CRUD off
    LIMIT 1
```
Both switches off, driven by an Id straight off the URL query string. Change the record Id in the address bar and any record comes back — including restricted fields — regardless of visibility rules. An unauthenticated guest can walk the entire catalog by Id enumeration.

## ✅ 3. The Fix

Not "turn everything back on" (breaks a legitimately public page) — make escalation **narrow, deliberate, and replaced with an explicit filter**:

```apex
public with sharing class CourseController {
  @AuraEnabled(cacheable=true)
  public static LearningCourse getCourseDetails(Id recordId) {
    return PublicCatalog.findCourse(recordId);   // delegates to the one escalated method
  }
}

private without sharing class PublicCatalog {
  static LearningCourse findCourse(Id recordId) {
    List<LearningCourse> rows = [
      SELECT Id, Name, Price__c FROM LearningCourse
      WHERE Id = :recordId AND IsPublished__c = true    // ← the gate that REPLACES sharing
      LIMIT 1
    ];
    return rows.isEmpty() ? null : rows[0];
  }
}
```
The load-bearing line is the explicit `IsPublished__c = true` filter. Escalating access without replacing what you switched off isn't escalation — it's an open door with a comment on it.

## 🧭 4. Other Ways to Solve It

- **Guest User Sharing Rules** (no code) — criteria-based sharing rules grant the Guest User read access; every class stays `with sharing` + `WITH USER_MODE`. Platform-sanctioned but Salesforce deliberately makes guest sharing awkward to set up.
- **`inherited sharing`** — the class runs in whatever mode its caller was in; correct default for any utility/service class. Doesn't solve the guest problem alone, but never leave a class with *no* keyword — unannotated classes entered from LWC silently behave as `without sharing`.
- **`Security.stripInaccessible`** — query in system mode, strip fields the user can't see before returning. Addresses field access only, not which *records* are reachable.

## 🔎 5. How to Recognize This

- Any `without sharing` class paired with `WITH SYSTEM_MODE` queries — both switches off is the maximally permissive combination the platform offers.
- Any recordId sourced from a URL or client input feeding a query with no additional filter.
- Not a one-off: check every controller class in a module for the same habit, not just the one you're reviewing.
