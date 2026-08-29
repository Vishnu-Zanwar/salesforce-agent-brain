# CLAUDE.md

This repo is a personal, version-controlled knowledge base (see `README.md`
§0 for the full purpose). It's meant to be read the same way by any AI coding
agent in any IDE — this file is Claude Code's entry point into that shared
behavior.

## Before solving an error encountered while working in this repo (or any repo this knowledge base supports)

Follow `00_SYSTEM/AGENT_PROTOCOL.md` — the full check-first/log-after loop,
the logging threshold, and the note format are defined there. Short version:

1. Extract a short error signature and run `.\brain.ps1 search "<signature>"` before solving from scratch.
2. On a match, run `.\brain.ps1 show <PINCODE>` and apply the documented fix — cite the PINCODE.
3. On no match, solve normally. If it was non-trivial (not a typo/import/syntax slip), write a real note (no stub content left in place), register it with `.\brain.ps1 new-pincode`, and push immediately with `.\brain.ps1 sync`.

## Working in this repo specifically

- `brain.ps1` is portable — it resolves its own location via `$PSScriptRoot`, so it works correctly no matter where the repo is cloned. Don't reintroduce hardcoded absolute paths.
- Registry/index are `00_SYSTEM/pincode_registry.json` and `00_SYSTEM/pincode_index.json` — always run `.\brain.ps1 reindex` after any direct edit to the registry (not needed after `new-pincode`, which does this automatically).
- Only `main` receives commits directly — see `.github/BRANCH_PROTECTION.md`. The many `domain/*` branches are read-only mirrors.
- Large/binary files never get committed — see `00_SYSTEM/STORAGE_POLICY.md`. `brain.ps1 sync` enforces a 5MB gate.
- Treat any specific status claim in `README.md` or the workflow emails as something to verify against the actual filesystem, not as ground truth by itself — this repo has a history of aspirational claims outrunning what was actually built.
