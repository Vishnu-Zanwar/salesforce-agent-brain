# #APE004: One Business Rule, Enforced Identically at Every Layer

- **PINCODE:** `#APE004`
- **Topic:** Apex/LWC Architecture / Rule Consistency Across Layers
- **Domain:** Apex
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 04 (High severity)
- **Related:** [[APE003]]

---

## 🎯 1. The Concept

When the same rule is expressed twice — once in the read that decides what the UI offers, once in the write that decides what's allowed — the two must agree on **granularity**. If they disagree, the system contradicts itself: either the UI blocks something legal, or the API permits something the UI forbids.

## 🛑 2. Where It Goes Wrong

```apex
// isUserRegistered — checks at LEARNING COURSE level
WHERE CourseOffering.LearningCourseId = :recordId       // any cohort of this course

// registerUser — de-dupes at COURSE OFFERING level
WHERE CourseOfferingId IN :courseOfferingIds             // this exact cohort only
```
Enroll in the January cohort. `isUserRegistered` returns true, the Confirm button is removed from the DOM entirely — through the UI you're finished. But call `registerUser` directly with March's Id and Apex sees no row *for that offering* and inserts it. Given the confirmed rule (one cohort per course), `isUserRegistered` is right and `registerUser` is wrong.

## ✅ 3. The Fix

Move the guard to course level, in **one** method both callers share, so the two can never drift apart:

```apex
private static Map<Id, CourseOfferingParticipant> enrollmentsByCourse(
  Id contactId, Set<Id> learningCourseIds
) {
  // single source of truth — read and write both call this
  ...
}

CourseOfferingParticipant already =
    enrollmentsByCourse(contactId, new Set<Id>{ learningCourseId }).get(learningCourseId);
if (already != null) {
  throw createAuraException(
    'You are already enrolled in "' + already.CourseOffering.Name +
    '" for this course. Withdraw from it before registering for a different offering.'
  );
}
```
Note the message names what to do next — "already registered" is a dead end, "withdraw from January first" is a path.

## 🧭 4. Other Ways to Solve It

- **Enforce it in the data model** (strongest) — a unique key on `ParticipantContactId + LearningCourseId`, denormalizing the course Id onto the participant. Genuinely unbypassable, at the cost of a field to keep in sync.
- **A Validation Rule or trigger on the object** — extends the rule to Flow, Data Loader, admin edits. Needs a trigger (not a formula) for a cross-object rule.
- **Allow the change, don't block it** — if the business allows switching cohorts, implement an explicit *transfer* (withdraw + insert in one transaction) rather than a hard error. Needs sign-off since it changes the rule, not just its enforcement.

## 🔎 5. How to Recognize This

- Two different queries expressing "is this allowed" at two different levels of granularity (course vs. offering, object vs. field, list vs. record).
- A UI state (button removed, field disabled) that has no corresponding server-side check enforcing the same thing.
