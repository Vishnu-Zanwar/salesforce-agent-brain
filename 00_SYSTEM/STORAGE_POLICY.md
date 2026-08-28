# Storage Tiering Policy

## Rule

**Git holds text and code only.** Anything binary or large (recordings, exported PDFs, images, datasets) goes to Google Drive, and the note that references it links to the Drive URL instead of committing the file.

Concretely, never commit:
- Video/audio recordings
- Exported PDFs (NotebookLM digests, OneNote exports)
- Images/screenshots over a few hundred KB
- Datasets, CSV dumps, or any file that isn't source-controlled text

Anything under `01_SALESFORCE/**` should be `.md`, `.cls`, `.js`, `.json`, `.ts`, `.html`, `.css`, `.xml`, or similarly plain-text. If a note needs to reference a recording or PDF, embed the Drive link, not the file.

## Why

GitHub free-tier repos get flagged/warned around 1GB, and large binaries bloat every future `git clone`/`git pull` regardless of whether anyone needs that specific file. A single accidentally-committed screen recording can make the repo slow to work with for good.

## Enforcement

`.gitattributes` below marks common binary types so Git treats them correctly *if* one slips in (diff-safe, not silently corrupted) — this is a safety net, not permission to commit them. The real enforcement is `brain.ps1 sync` running a size check before it pushes (added below); anyone committing directly with plain `git commit` bypasses that check, so this remains a policy backed by process, not a hard technical guarantee.
