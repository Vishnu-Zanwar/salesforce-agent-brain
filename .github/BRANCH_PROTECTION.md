# Branch Protection & Write-Lock Policy

## Rule

**All content writes happen on `main`.** Every domain/sub-domain branch listed below is a **read-only mirror/reference branch** — it exists so a specific agent or specialist can be pointed at a narrow slice of history (e.g. `salesforce/lwc/errors`), not so content is committed there directly.

`brain.ps1 sync` pushes `main` plus all branches in one pass (`git push --all origin`), which only works safely if nothing but `main` ever receives new commits — otherwise `push --all` would publish divergent, un-reviewed branch state. Do not commit directly to a domain branch; commit to `main`, then let `sync` propagate.

## Why

With multiple agents (`@salesforce-brain`, domain specialists) potentially working against the same repo, letting agents write to their own branch invites the exact failure this policy exists to prevent: two branches diverge, nobody merges them, and cross-references (`[[LWL001]]`, PINCODE links, `contracts.jsonl` entries) start pointing at content that only exists on one branch. A single-writer branch (`main`) keeps the PINCODE registry, the contract ledger, and the file tree consistent as one linear history.

## Current branch inventory (reference-only, do not commit here)

```
ai-engineering/{main,llm-fine-tuning,multi-agent-swarms,open-source-models,rag-and-vector-db}
career-leadership/{main,communication-and-management,interview-prep,system-design-drills}
domain/{life-and-growth,salesforce}
life-growth/{main,finance-and-investing,habits-and-productivity,reading-digests}
salesforce/admin/{main,code-samples,errors,learning}
salesforce/apex/{main,code-samples,errors,learning,notebook,onenote}
salesforce/api/{main,code-samples,errors,learning}
salesforce/lwc/{main,code-samples,errors,learning,notebook,onenote}
system-design/{main,case-studies,databases-and-caching,distributed-systems,microservices}
```

## Enforcement

This document is the policy source of truth that `brain.ps1` and any agent should read before committing. It is **not** a substitute for GitHub's server-side branch protection rules (require PR review, block force-push, restrict who can push to `main`) — those must be configured separately in the repo's Settings → Branches on GitHub, which is a shared-infrastructure change outside what an agent should do unattended. If you want that configured, say so explicitly and confirm the exact rules (e.g. "require PR before merging to main") before it's applied.
