# #LWE003: Hidden Is Not the Same as Not Rendered

- **PINCODE:** `#LWE003`
- **Topic:** LWC Templates / lwc:if vs CSS-Hide, N+1 Rendering
- **Domain:** LWC
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 08 (Medium severity)
- **Related:** [[SDE001]]

---

## 🛑 1. The Problem

`lwc:if` / `if:true` control **whether the component exists**. CSS (`slds-hide`, `display:none`) controls only whether an *existing* component is **painted**. A component that exists has been constructed, connected, and — critically — **its wires have fired**. Hiding with CSS costs you the entire server round trip anyway.

## 🔎 2. Where It Goes Wrong

```html
<!-- Kept in DOM with class binding to eliminate render/fetch lag -->
<div class={Course.scheduleClass}>
  <c-course-schedule record-id={Course.Id}></c-course-schedule>
</div>
```
Each of 6 cards on screen mounts a `courseSchedule`, and each fires its own `@wire`. That's **six Apex round trips to render one page** where the user asked for zero — repeated on every filter change and page flip. The classic N+1: one query for the list, then one more per row. The comment names a real concern (expansion lag), but this is the expensive way to solve it — fetching eagerly to avoid a spinner is a trade made after measuring, not by default.

## ✅ 3. The Fix

Fetch in bulk; the child becomes a presentational component that does no wiring at all:

```apex
@AuraEnabled(cacheable=true)
public static Map<Id, List<CourseOfferingSchedule>> getSchedulesByOffering(List<Id> offeringIds) {
  Map<Id, List<CourseOfferingSchedule>> byOffering = new Map<Id, List<CourseOfferingSchedule>>();
  for (CourseOfferingSchedule s : [
    SELECT Id, CourseOfferingId, StartTime, EndTime
    FROM CourseOfferingSchedule
    WHERE CourseOfferingId IN :offeringIds
    WITH USER_MODE
    ORDER BY StartTime
  ]) { ... }
  return byOffering;
}
```
Passing data down instead of letting each child re-fetch is the general cure for N+1 in LWC. If lazy loading is genuinely wanted, the minimal correct version is `<template lwc:if={Course.showDetails}>` around the drawer — one line, not a CSS class.

## 🧭 4. Other Ways to Solve It

- **Lazy with `lwc:if`** — only the expanded card ever constructs the child. Trade-off: a visible delay on first expand (the thing the CSS-hide was trying to avoid); mitigate by tracking already-opened Ids so re-expanding doesn't refetch.
- **A child subquery on the parent** (cleanest) — `SELECT Id, (SELECT ... FROM ChildRelationship) FROM Parent`, one query, LDS caches everything together. Depends on the relationship being queryable this way, and subqueries cap at 200 rows per parent.
- **Stay eager, but make it cheap** — bulk-fetch as above and don't worry about the DOM nodes. The problem was never the six components, it was the six round trips.

## 🧭 5. How to Recognize This

- Any child component kept in the DOM with a CSS class toggling visibility, where the child itself wires data.
- A list rendering N child components, each independently calling `@wire` — check whether that's N+1 in disguise.
