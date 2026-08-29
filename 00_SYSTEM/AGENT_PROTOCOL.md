# Agent Protocol — Check-First, Log-After

This is the operating procedure any AI coding agent (Antigravity, Claude Code, or
any other IDE assistant) should follow when working in a codebase that this
knowledge base is meant to support. It is committed in the repo — not in any
one tool's local config — so it stays identical across every IDE that reads it.
Each IDE's own agent-config file (Antigravity's `SKILL.md`, Claude Code's
`CLAUDE.md`) should point here rather than duplicate this logic.

## The loop

```
Error occurs (or you're asked to solve one)
        |
        v
1. Extract a short signature: the error type + the 3-6 most specific terms
   (e.g. "wire proxy mutation TypeError", not the full stack trace)
        |
        v
2. Check H-AKOS BEFORE attempting a fix from scratch:
     .\brain.ps1 search "<signature>"
        |
   +----+----+
 MATCH       NO MATCH
   |             |
   v             v
3a. .\brain.ps1  3b. Solve the error normally with your own
    show <CODE>      reasoning/tools.
    Read the full
    note. Apply the
    documented fix.
    Tell the user
    which PINCODE
    this matches.
        |             |
        v             v
                  4. Was this non-trivial? (see threshold below)
                       |
                  +----+----+
                 YES        NO
                  |           |
                  v           v
             5. Write a    Don't log it.
                real note
                (not a
                stub) and
                register it
             6. Push
                immediately
                (git add,
                commit, push)
```

## Step 1 — Extract a signature

Use the error type plus the specific, searchable terms — not the whole stack
trace or a generic phrase. `brain.ps1 search` does substring/keyword matching
over note titles, so specificity matters more than completeness. Good:
`"wire proxy mutation"`. Too generic to be useful: `"error in component"`.

## Step 2 — Check first, always

Run `.\brain.ps1 search "<signature>"` before spending effort solving from
scratch. This is not optional or something to skip when you're confident you
already know the fix — the entire point of this system is that "I'm pretty
sure I know this" is exactly the case where a past, verified fix (or a subtly
different variant of the bug) is most valuable to check against.

If `search` turns up nothing and you suspect the phrasing was the problem, try
one alternate phrasing before concluding there's no match. Don't loop
indefinitely on phrasing — one retry is enough.

If both attempts miss, try `.\brain.ps1 search-semantic "<description>"`
before concluding nothing exists. It's slower (loads a local embedding
model) and needs Python + the packages in `requirements.txt`, but it
catches paraphrased matches the keyword index can't — e.g. "the screen
just hangs after I click save" finding a note titled "UI freezes on submit"
with no words in common. Keyword search stays the first move because it's
faster and exact-match results are more trustworthy than similarity scores;
semantic search is the fallback for when phrasing, not existence, was the
problem.

## Step 3 — On a match

Run `.\brain.ps1 show <PINCODE>` to get the full note in one call. Apply the
documented fix. State plainly to the user which PINCODE this came from (e.g.
"this matches #LWE001 — applying the known fix"), so it's clear the answer
came from verified prior experience, not a fresh guess.

If the match is close but not exact (a variant of a known error), apply the
documented pattern, but treat this as a candidate for its own new PINCODE if
the variant is meaningfully different — don't force-fit an unrelated fix.

## Step 4 — Deciding whether to log a new one

**Log it if:** solving it required real investigation — reading source,
reasoning about root cause, more than one attempt, or genuine platform/library
knowledge that isn't obvious from the error message alone.

**Skip logging if:** it was a typo, a missing import, an obvious syntax error,
or anything resolvable by reading the error message itself. Logging these
just adds noise that makes future searches less precise.

When genuinely unsure which side of the line something falls on, err toward
skipping — a missed log costs nothing (the next time it happens, if it turns
out to be a real pattern, it gets logged then), but a low-value entry sits in
the registry indefinitely diluting search results.

## Step 5 — Writing the note

Use `.\brain.ps1 new-pincode <PREFIX> "<Title>" "<folder>"` to register and
get a stub, then **replace the stub content immediately** — a registered
PINCODE with `(Fill in details here)` left in place is worse than not logging
it at all, since it shows up in search results but has nothing useful in it.
Follow the existing note format (see any file in `01_SALESFORCE/*/01_ERRORS/`
for the template: problem, root cause, fix, how to recognize it next time).

Pick the correct prefix for the domain — see `00_SYSTEM/pincode_registry.json`
for the full list. Current domains: `LW`/`AP`/`AD`/`IN` (Salesforce), `SD`
(System Design), `AI` (AI Engineering), `CL` (Career/Leadership), `LF` (Life
& Growth). Errors and Learning pillars exist in every domain; Code Samples,
Notebook, and Digest pillars currently only exist under Salesforce.

## Step 6 — Push immediately

Once the note is written and registered, commit and push right away:

```powershell
.\brain.ps1 sync
```

Don't batch multiple sessions' worth of new notes before pushing — the whole
point of "any IDE, any machine" is that a fix logged in one session should be
retrievable from a different machine or IDE within seconds, not at the end of
the day.

## A note on trust

This protocol only works if every logged note is actually correct and
verified — a wrong "fix" that gets applied automatically in a future session
because it matched a search is worse than no note at all. If you're not
confident the fix actually worked (tested, not just "should work"), don't log
it yet.
