# #APE008: Craft Debt — Names, Copy, and the Tests That Don't Exist

- **PINCODE:** `#APE008`
- **Topic:** Apex/LWC Code Quality / Test Coverage as a Deploy Blocker
- **Domain:** Apex
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 12 (Low severity findings, but a Deploy Blocker)

---

## 🛑 1. The Problem

Three things that individually look minor and together block a release.

**Names.** `course` should be `CourseController` — it's an LWC controller, not a domain object; Apex classes are PascalCase and should say what they are. A folder typo (`utlis` for `utils`) propagates into every import once it's a module name. A method like `getCourseSchedules(Id recordId)` that actually takes a `CourseOfferingId` should say so in the parameter name — so a caller can't get it wrong by type-checking alone.

**Copy.** `` `${count} Offernings` `` — a typo on a public hero, and not pluralization-aware ("1 Offernings"). User-facing strings deserve the same review as logic, and on a multi-language site they belong in Custom Labels, not hardcoded in a getter.

**The actual deploy blocker.** The module's classes directory contains real controller classes and **no test classes at all**. Salesforce requires 75% org-wide Apex coverage to deploy to production — this module cannot ship as-is. Jest specs were also untouched CLI scaffolds still asserting `expect(1).toBe(1)`.

## ✅ 2. What the Tests Actually Need to Prove

```apex
@IsTest
private class CourseControllerTest {
  @IsTest static void registerUser_rejectsOfferingFromAnotherCourse() { /* the fix in APE002 */ }
  @IsTest static void registerUser_rejectsSecondCohortOfSameCourse()  { /* the fix in APE004 */ }
  @IsTest static void registerUser_isIdempotentOnDoubleSubmit()       { /* the fix in APE003 */ }
  @IsTest static void getCourseDetails_hidesUnpublishedCourseFromGuest() {
    System.runAs(guestUser) { /* the fix in APE001 */ }
  }
}
```
The point is in the method names: **every security fix needs a negative test** — one that proves the bad thing is now rejected. A test that only exercises the happy path would have passed against the broken code too, which is exactly why these bugs shipped in the first place. Coverage percentage is a floor, not a goal — a test that calls a method and asserts nothing raises the number and catches nothing.

## 🔎 3. How to Recognize This

- A module with real logic and zero test classes — this is a release blocker, not a code-quality nit, the moment it needs to deploy to production.
- Test methods whose names don't describe a specific rejected scenario ("testRegister" tells you nothing; "registerUser_rejectsOfferingFromAnotherCourse" tells you exactly what would have caught the bug).
- Any test that exercises a security fix without a negative case proving the bad path is actually blocked.
