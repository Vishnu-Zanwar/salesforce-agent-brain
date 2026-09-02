# #LWE004: Component State Must Be Derived From Its Inputs, or Reset With Them

- **PINCODE:** `#LWE004`
- **Topic:** LWC Architecture / State Ownership
- **Domain:** LWC
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 05 (High severity)
- **Related:** [[LWL001]]

---

## 🎯 1. The Concept

An LWC's private state (a selection, a current page, a filter) is **independent** of its `@api` inputs unless you make it dependent. When `recordId` changes, LWC re-runs the wire and re-renders — it does **not** reset your fields. Any state that only made sense under the old input is now stale, and stale state that drives a *write* is a correctness bug.

Second half: `renderedCallback` runs after *every* render and is not an initialization hook. Mutating reactive state there risks an infinite render loop — initialization belongs in a setter, a wire handler, or a getter.

## 🛑 2. Where It Goes Wrong

**(a) Selection survives filtering/paging** — `getSelectedCoursesIds()` reads the unfiltered list, so a selection that's scrolled off-screen or filtered out is still "selected" and gets submitted. **(b) Selection survives a change of course** — auto-select logic lives in `renderedCallback`, guarded only on "not already set," so nothing resets it when `recordId` changes; in a component reused across page navigations, course B's page can hold course A's selected offering Id.

## ✅ 3. The Fix

Let the input own the state:

```javascript
_recordId;
@api
get recordId() { return this._recordId; }
set recordId(value) {
  if (value !== this._recordId) {
    this._recordId = value;
    this.resetSelectionState();   // new course => nothing is selected
  }
}

@api
getSelectedCoursesIds() {
  const visible = this.displayedOfferings.some(o => o.Id === this.selectedOfferingId);
  return visible ? [this.selectedOfferingId] : [];   // never return what the user can't see
}
```
Move single-offering auto-select out of `renderedCallback` into the wire handler, where the data actually arrives.

## 🧭 4. Other Ways to Solve It

- **Lift the selection to the parent** (strongest) — the child becomes fully *controlled*, owns no selection state at all. One source of truth makes both bugs impossible rather than fixed. Costs prop plumbing and a parent re-render per selection.
- **Keep the off-screen selection, but surface it** — a persistent "Selected: X ✕" chip. Fixes invisibility, not the cross-course leak; still needs the setter.
- **Clear on filter change only** (stopgap) — fastest patch for the bug users will actually hit, leaves the cross-course leak open.

## 🔎 5. How to Recognize This

- Any private field that isn't derived from `@api` props and isn't explicitly reset when they change.
- Initialization logic living in `renderedCallback` instead of a setter or wire handler.
- Ask: "if this component is reused for a different record without being destroyed, what state survives that shouldn't?"
