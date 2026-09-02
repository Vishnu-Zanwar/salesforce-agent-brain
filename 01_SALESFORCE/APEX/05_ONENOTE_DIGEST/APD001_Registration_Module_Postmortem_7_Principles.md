# #APD001: 7 Principles From the Registration Module Postmortem

- **PINCODE:** `#APD001`
- **Topic:** Apex/LWC Security & Correctness — Quick Reference
- **Domain:** Apex
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** Registration Module Postmortem — 15 findings, 12 lessons, reduced to 7 rules that would have prevented all of them
- **Full lessons:** [[APE001]] [[APE002]] [[APE003]] [[APE004]] [[APE006]] [[APE007]] [[APE008]] [[LWE003]] [[LWE004]] [[LWE005]] [[LWE006]] [[LWE007]]

---

## The 7 rules

1. **The LWC decides what to show. Apex decides what is allowed.** Every rule enforced in the UI needs a server-side twin.
2. **`@AuraEnabled` is a public API** whether you intended it or not. Re-query and re-validate every Id the client sends you.
3. **Turning off an access control obliges you to replace it.** `without sharing`, `WITH SYSTEM_MODE` — an explicit filter, in the narrowest scope you can manage, or it's just an open door with a comment on it.
4. **Check-then-act loses races.** If uniqueness matters, the database has to be the one enforcing it — not a SELECT before an INSERT.
5. **Three states, not two: loading, loaded, failed.** Never let "failed" render as "empty."
6. **Falsy is not "missing," and a date string is not a date.** `0` is a valid time; `'2026-03-15'` is midnight UTC.
7. **Getters are not cached and hidden is not unrendered.** Each quietly costs you a loop or a round trip you never asked for.

## 5-minute self-check before shipping an Apex + LWC feature

- [ ] Does every UI-enforced rule have a matching Apex check? (#1)
- [ ] Does every `@AuraEnabled` method re-validate its Id parameters against the caller's actual context? (#2)
- [ ] Any `without sharing` or `WITH SYSTEM_MODE` — is there an explicit filter replacing what was turned off? (#3)
- [ ] Any SELECT-then-INSERT for uniqueness — is there a database-enforced unique key backing it? (#4)
- [ ] Does the wire error path render differently from the empty-data path? (#5)
- [ ] Any `!x` guard where `x` could legitimately be `0`? Any `new Date()` on a date-only string? (#6)
- [ ] Any getter called from multiple other getters — would it survive 200 rows, not just 6? Any CSS-hidden component that still wires data? (#7)
