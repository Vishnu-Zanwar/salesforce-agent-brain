# #LWE007: Getters Run on Every Access — Keep Them Cheap and Pure

- **PINCODE:** `#LWE007`
- **Topic:** LWC Performance / Getter Chains
- **Domain:** LWC
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem, Lesson 11 (Low severity, real at scale)
- **Related:** [[APL001]]

---

## 🛑 1. The Problem

A getter in LWC is a plain JavaScript getter. It is **not memoized**. Every reference in the template, and every reference from another getter, re-executes the whole body. Chain a few and you get accidental quadratic work. A getter should also be *pure*: no mutation, no side effects, ideally no freshly-allocated objects — returning a new array each call also defeats the template's diffing.

## 🔎 2. Where It Goes Wrong

One getter mapped the entire array (building class strings, a spread copy per row), and was then called by eight other getters — several of which called each other — so a single render triggered the full map roughly a dozen times:

```javascript
get instructorOptions() {
  const rawData = this.coursedetails || [];       // full map, again
  uniqueInstructors.forEach(name => {
    const count = rawData.filter(c => { ... }).length;   // ← O(n²)
    options.push({ label: `${name} (${count})`, value: name });
  });
}
```
At six rows, invisible — this is exactly the class of bug that only appears in the org with real data, long after the code shipped. At two hundred rows: a janky filter dropdown and a slow page.

## ✅ 3. The Fix

Compute once when the data arrives, count in a single pass:

```javascript
@wire(getCourseOfferings, { recordId: '$recordId' })
wiredOfferings(result) {
  this.wiredOfferingsResult = result;
  if (result.data) {
    this.offerings = this.decorate(result.data);   // map ONCE, on arrival
  }
}

get instructorOptions() {
  const counts = new Map();
  for (const c of this.offerings) {                // one pass, not n passes
    const name = (c.facultyName || '').trim() || 'Staff / Unassigned';
    counts.set(name, (counts.get(name) || 0) + 1);
  }
  return [...];
}
```
The split that makes this work: fields depending only on the *record* belong in the one-time `decorate`. Fields depending on *selection* (a highlighted-row class, say) must stay dynamic — compute those in the small getter that actually needs them. Mapping the visible rows is cheap; mapping all of them, a dozen times, is not.

## 🧭 4. Other Ways to Solve It

- **Compute in the wire handler, store in a field** (recommended, above) — the standard answer. You must remember to recompute anywhere else the source data changes — usually only the wire.
- **Memoize on a cache key** — keep the getter, return cached unless `(dataVersion, filter, page)` changed. Useful when inputs can change from several places, but invalidation logic is its own well-known bug category.
- **Shape the data in Apex** — return counts/display fields pre-computed. Fewer moving parts client-side, but costs a round trip whenever a *client-side-only* filter changes — wrong for values that change per interaction.

## 🔎 5. How to Recognize This

- A getter that maps/filters/reduces a full array, called from multiple other getters or template bindings.
- Anything invisible at dev-time (6 rows) that's worth asking "what does this cost at 200, 2000 rows?"
