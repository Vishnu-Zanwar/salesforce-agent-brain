# #APE002: An @AuraEnabled Method Is a Public API

- **PINCODE:** `#APE002`
- **Topic:** Apex Security / Server-Side Input Validation
- **Domain:** Apex
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 02 (High severity)
- **Related:** [[APE001]]

---

## 🎯 1. The Concept

Every `@AuraEnabled` method is callable by any authenticated user, with any arguments, from the browser console — no LWC required. Your component is a convenience for well-behaved users, not a gate. **Anything the UI prevents, the method must prevent again.**

Corollary: typing a parameter as `Id` only guarantees a well-formed 15/18-character Id belonging to *some* object — it is not validation. Apex will accept an Id of the wrong object type and only fail at DML, with a message nobody can act on.

## 🛑 2. Where It Goes Wrong

```apex
for (Id offeringId : courseOfferingIds) {
  if (!existingOfferingIds.contains(offeringId)) {
    copList.add(new CourseOfferingParticipant(
      CourseOfferingId = offeringId,   // ← never verified to exist, belong here, or be open
      ...
    ));
  }
}
```
Open DevTools on any page and call `registerUser({courseOfferingIds: ['a0X...']})` with an Id scraped from anywhere — another campus, a paid programme, a closed cohort. You're enrolled, especially when this compounds with [[APE001]]'s `without sharing`.

## ✅ 3. The Fix

Re-fetch the records server-side. One query proves everything at once:

```apex
@AuraEnabled
public static void registerUser(Id learningCourseId, List<Id> courseOfferingIds) {
  Set<Id> requested = new Set<Id>(courseOfferingIds);
  Map<Id, CourseOffering> allowed = new Map<Id, CourseOffering>([
    SELECT Id, LearningCourseId, AvailabilityStatus
    FROM CourseOffering
    WHERE Id IN :requested
      AND LearningCourseId = :learningCourseId     // belongs to THIS course
      AND AvailabilityStatus = 'Available'         // and is open
    WITH USER_MODE                                 // and the user can see it
  ]);
  if (allowed.size() != requested.size()) {
    throw createAuraException('One or more selected offerings are no longer available.');
  }
}
```
`learningCourseId` is now a required parameter — without it there's no way to assert "this offering belongs to the context you were on."

## 🧭 4. Other Ways to Solve It

- **Don't accept record Ids at all** (most secure) — pass a course Id plus a selection from a server-generated list; the client literally cannot name an arbitrary record.
- **Custom validation layer** shared by every write path that accepts an Id, so the check can't be skipped by a new caller.

## 🔎 5. How to Recognize This

- Any `@AuraEnabled` method whose only validation is the parameter's Apex type (`Id`, `String`).
- Ids passed from client to server with no re-query against the caller's actual context.
- Test this by opening DevTools and calling the method directly with a plausible-but-wrong Id — if it succeeds, the UI was the only gate.
