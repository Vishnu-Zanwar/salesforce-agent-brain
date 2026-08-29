# DevOps Agent Protocol

This defines the `devops-agent` role: the one whose job is to keep this
repository itself healthy, not to log engineering knowledge into it (that's
`AGENT_PROTOCOL.md`'s job). Same principle as everything else here — its
responsibilities are checkable against disk, not a vague "maintain the repo"
mandate.

## Responsibilities

1. **Run the health check** and act on every failure — don't just report them.

   ```powershell
   .\00_SYSTEM\health_check.ps1
   ```

   Currently checks: no phantom registry entries (registered PINCODE pointing
   at a file that doesn't exist), no unfilled stub notes left in place, the
   keyword index matches the registry count, no hardcoded absolute paths
   reintroduced into `*.ps1` files, no tracked file over the 5MB storage
   policy limit.

2. **Run the staleness sweep** and flag (don't auto-fix) anything that needs
   a human to actually re-verify the content is still correct:

   ```powershell
   .\00_SYSTEM\staleness_check.ps1
   ```

3. **Keep both indexes fresh.** `.\brain.ps1 reindex` (keyword) is cheap and
   should just always be current — if `health_check.ps1` ever reports it
   drifted, that's a bug in whatever skipped calling it, not something to
   patch over by running it once. `.\brain.ps1 vector-reindex` (semantic) is
   more expensive; `sync` already refreshes it automatically, so a drift
   here usually means someone edited a note without going through `sync`.

4. **Verify automation claims stay honest.** Both GitHub Actions workflows
   (`weekly_brain_digest.yml`, `saturday_plan_generator.yml`) compute their
   status from the filesystem, not a hardcoded list — if you ever touch
   either workflow, keep it that way. A `done_if` check that can't actually
   fail isn't a check.

5. **Keep the branch/storage policies enforced, not just documented.**
   `.github/BRANCH_PROTECTION.md` and `00_SYSTEM/STORAGE_POLICY.md` are
   policy docs; `brain.ps1 sync`'s 5MB gate is the actual enforcement for
   one of them. If a policy doc exists with no corresponding enforcement,
   that's a gap worth closing, not something to leave as prose.

6. **When something breaks CI or an automated workflow**, diagnose from the
   actual GitHub Actions run logs (`gh run list` / `gh run view --log`), not
   by guessing from the workflow file alone — the failure is almost always
   more specific than what the YAML suggests.

7. **After every push, pull, or merge, verify it actually landed** — don't
   trust the command's exit code alone. This is not theoretical: PR #1 in
   this repo merged successfully (exit 0, no error) but only captured its
   first 2 commits, because 7 more commits got pushed to the branch *after*
   GitHub had already closed it as merged. Nobody noticed until several
   turns later, and every workflow/fix built in between was silently dead on
   `main` the whole time. Concretely, after any merge:

   ```powershell
   git fetch origin
   git log origin/main..origin/<branch-that-was-supposedly-merged> --oneline
   ```

   A non-empty result means something is stranded — either the merge missed
   commits (this repo's actual failure mode) or new commits landed on the
   branch post-merge and need their own PR. Either way, don't consider a
   merge finished until this comes back empty.

8. **No branch should carry commits `main` doesn't have with no open PR
   tracking them.** That's the general form of the same failure — a branch
   quietly diverges from `main` and nothing surfaces it. Check periodically:

   ```powershell
   gh pr list --state open --json headRefName
   git branch -r  # cross-reference: does every remote branch ahead of main have an open PR, or is it an intentional read-only mirror per BRANCH_PROTECTION.md?
   ```

9. **Merge conflicts:** attempt automatic resolution only for mechanical,
   unambiguous cases (e.g. the registry/index JSON files, where a rebuild
   via `brain.ps1 reindex` / `vector-reindex` is safer than hand-resolving
   the diff). For anything requiring a judgment call about which version of
   actual content is correct, stop and surface it — don't guess, and never
   force-push to make a conflict disappear.

## What this role does NOT do

- Doesn't write new Error/Learning notes — that's the check-first/log-after
  loop in `AGENT_PROTOCOL.md`, driven by whoever's actually solving a bug.
- Doesn't decide product direction (new pillars, new automation) — surface
  options, let the user decide, same as any other agent here.
- Doesn't force-push, rewrite history, or bypass `BRANCH_PROTECTION.md` to
  "fix" something faster.

## Before finishing any maintenance pass

Run `health_check.ps1` one more time. A maintenance pass that leaves new
failures behind is worse than not running at all, because it looks clean at
a glance.
