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
