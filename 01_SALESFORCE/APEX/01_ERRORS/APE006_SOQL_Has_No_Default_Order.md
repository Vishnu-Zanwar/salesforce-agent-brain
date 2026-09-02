# #APE006: A SOQL Result Has No Order Unless You Give It One

- **PINCODE:** `#APE006`
- **Topic:** SOQL / Query Determinism & Pagination
- **Domain:** Apex
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 06 (Medium severity)

---

## 🎯 1. The Concept

Without `ORDER BY`, SOQL guarantees **nothing** about row order — not insertion order, not Id order, not the order you saw last time. It can change between two identical queries as data changes or the optimizer picks a different index. Harmless if you render the whole list. A correctness bug the moment you slice it (pagination).

## 🛑 2. Where It Goes Wrong

```apex
return [
  SELECT Id, Name, AvailabilityStatus, PrimaryFaculty.Name
  FROM CourseOffering
  WHERE LearningCourseId = :recordId
  WITH SYSTEM_MODE
];                          // no ORDER BY, no LIMIT
```
Client slices that array into pages by index. An admin edits one record between page loads; the refreshed list comes back in a different order — a record already seen reappears on the next page, one never seen is now buried on the current page. Records appear to duplicate and vanish.

Separately: a field selected but never filtered or rendered anywhere is a design smell — either it should gate the list, be visible, or not be in the `SELECT`.

## ✅ 3. The Fix

```apex
return [
  SELECT Id, Name, AvailabilityStatus, PrimaryFaculty.Name
  FROM CourseOffering
  WHERE LearningCourseId = :recordId
    AND AvailabilityStatus = 'Available'       // use the field or drop it
  WITH USER_MODE
  ORDER BY StartDate ASC NULLS LAST, Name ASC  // meaningful, and deterministic
  LIMIT 200
];
```
Sort by something the user would sort by, then add a **tiebreaker** (`Name` or `Id`) so rows with equal values still come back stable. `LIMIT` isn't paranoia — an unbounded query is a heap-size exception waiting for the one record with 5,000 children.

## 🧭 4. Other Ways to Solve It

- **Paginate server-side** (scales) — move `LIMIT`/`OFFSET` into Apex, return a page + total count. The only correct answer past a few hundred rows. Note `OFFSET` caps at 2,000 — deep paging needs a keyset approach (`WHERE StartDate > :lastSeen`).
- **Sort client-side after the wire returns** — simple, lets the user re-sort with no round trip. Stops working once server-side paging is added.
- **Render the filtered-out field instead of hiding it** — often better UX (e.g. show "Full" instead of hiding), but visual state alone is never enforcement — pair with a server-side check.

## 🔎 5. How to Recognize This

- Any query without `ORDER BY` whose result gets sliced, paged, or compared across two separate calls.
- A `SELECT`ed field that's never filtered on and never rendered.
