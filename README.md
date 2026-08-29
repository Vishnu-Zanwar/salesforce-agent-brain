# 🌐 The Lifelong Multi-Agent Knowledge Operating System (H-AKOS)

> **Permanent • Hierarchical • Self-Evolving • Cost-Optimized**
> **Addressing Protocol:** 6-Character Universal `#PINCODE`
> **Storage Engine:** Version-Controlled Git & Private GitHub Cloud
> **Local Root Location:** `D:\salesforce-agent-brain`

---

## 0. 🎯 Purpose — What This Is and Why It Exists

**The problem:** every time a hard Salesforce bug gets solved — an obscure `@wire` proxy error, a governor-limit edge case, a flow race condition — that knowledge normally lives only inside one chat session. The session ends, the context resets, and three weeks later the same bug costs another two hours, because neither the engineer's memory nor any AI assistant's context window is a durable place to keep it.

**What this repository is:** a version-controlled, file-based external memory for Salesforce (and adjacent) engineering knowledge. It is not a wiki for browsing — it's built to be read by AI coding agents (Claude Code, Antigravity, or any other IDE assistant) as well as by you, so that a fix written down once is instantly retrievable later instead of being re-derived, guessed at, or hallucinated.

**What we're trying to achieve:**
1. **Never solve the same bug twice.** Every real error, once understood, gets a permanent, deterministically-addressable note (a `#PINCODE`) instead of evaporating with the chat session.
2. **Deterministic retrieval over fuzzy guessing.** Lookup is by exact ID or indexed keyword (`brain.ps1 search`), not vector-similarity guesswork that can miss or hallucinate.
3. **Tool-agnostic by construction.** Everything that matters is plain Markdown/JSON/code on disk — no IDE-specific plugin, config, or vendor lock-in. Any AI agent in any editor should be able to read this repo and use it the same way.
4. **Verified, not aspirational.** A note or automation only counts as "done" if it's actually checkable on disk — this repo went through an audit that found several early "solved" claims pointed at files that didn't exist, and the ongoing discipline here is to keep status honest rather than let the documentation drift ahead of reality.
5. **Grow one verified domain at a time.** Salesforce (LWC/Apex/Admin/API) is the first fully-built-out pillar; System Design, AI Engineering, Career/Leadership, and Life & Growth exist as reserved structure for the same pattern to be applied later, not built out yet.

This is a personal knowledge system for one engineer, not a product — the "multi-agent," "autonomous," and "self-evolving" language below describes the direction it's growing in, not a finished system. Treat any specific claim in this document as something to verify against the actual repo state, not as ground truth by itself.

---

## 1. 🧭 Executive Manifesto: The End of AI Amnesia

Standard AI chatbots suffer from **Context Amnesia**—conversations get wiped, token limits run out, and the AI repeats the exact same mistakes week after week.

This repository acts as an **Immutable, Version-Controlled External Cortex (Second Brain)**:

* **Never Solves the Same Bug Twice:** Every error and gotcha solved is permanently indexed under a `#PINCODE`.
* **Zero Vendor Lock-in:** Stored entirely in clean Markdown, JSONL, and source code on Git.
* **Autonomous Evolution:** Agents auto-harvest daily learnings, ingest platform releases, and generate spaced-repetition drills.
* **Multi-Model Cost Optimization:** 95% of routine operations run on 100% free open-source models (Groq, Ollama, Google AI Studio).

---

## 2. 🏛️ Master System Architecture

```text
                                🌐 ROOT: MASTER ORCHESTRATOR
                              (Coordinates Multi-Agent Swarm)
                                              │
    ┌──────────────────┬──────────────────────┼──────────────────────┬──────────────────┐
    ▼                  ▼                      ▼                      ▼                  ▼
01_SALESFORCE     02_SYSTEM_DESIGN       03_AI_ENGINEERING      04_CAREER_LEADERSHIP  05_LIFE_OPERATIONS
• LW (LWC)        • SD (Sys Design)      • AG (Agent Swarms)    • IN (Interview Prep) • FN (Finance & Wealth)
• AP (Apex)       • DB (Databases)       • LL (LLM Fine-Tuning) • LD (Leadership)    • HT (Health & Habits)
• AD (Admin)      • CA (Caching/Redis)   • RG (RAG Pipelines)   • CM (Communication)  • RD (Reading Digests)
• IN (API/Events) • MS (Microservices)   • OP (Open Source OSS) • MG (Management)    • LF (Life Principles)
    │                  │                      │                      │                  │
    └──────────────────┴──────────────────────┴──────────────────────┴──────────────────┘
                                              │
                                              ▼
                        ==============================================
                         THE 5 FUNCTIONAL PILLARS (PER DOMAIN)
                         ├── 🚨 01_ERRORS         (Anti-Pattern Logs)
                         ├── 📖 02_LEARNING       (Mental Models & Theory)
                         ├── 💻 03_CODE_SAMPLES   (Verified Boilerplates)
                         ├── 🧪 04_NOTEBOOK       (Hands-on Drills & Labs)
                         └── 📝 05_ONENOTE_DIGEST (5-Min Cheat Sheets)
                        ==============================================
```

---

## 3. 🏷️ The Universal 6-Character #PINCODE Protocol

Every file, bug, drill, and architectural pattern across the entire universe of knowledge is addressed via a unique 6-character alphanumeric code: `[Domain: 2][Pillar: 1][ID: 3]`.

```text
     ┌── Domain (2 chars)      ┌── Pillar (1 char)      ┌── Unique ID (3 chars)
   ┌─┴─┐                      ┌┴┐                     ┌─┴─┐
   │ L │ W │                │ E │                   │ 0 │ 0 │ 1 │
   └───┬───┘                └──┬──┘                 └───┬───┘
       │                       │                        │
  LW = LWC UI             E = Errors               001 = Error #1 (Wire Immutability)
  AP = Apex Backend       L = Learning             024 = Code Sample #24
  AD = Admin Config       C = Code Samples
  IN = Integrations       N = Notebook/Drills
  SD = System Design      D = Digest/Cheat Sheets
```

### Complete Domain Index Table

| Domain Code | Full Domain Name | Core Focus & Responsibilities |
|---|---|---|
| `LW` | Lightning Web Components | Shadow DOM, Reactivity, Wire Adapters, Custom Events, LWS, LDS |
| `AP` | Enterprise Apex | Trigger Handlers, fflib patterns, Async Apex, Governor Limits, Security |
| `AD` | Salesforce Admin | Data Modeling, OWD, Sharing Rules, Permission Sets, Flow Architecture |
| `IN` | API & Integrations | REST/SOAP Callouts, Composite API, Platform Events, CDC, JWT, OAuth |
| `SD` | System Architecture | Microservices, Distributed Systems, Sharding, Message Queues, Caching |
| `AI` | AI & Agent Systems | Multi-Agent Swarms, Tool Calling, Vector DBs, Prompting, Fine-Tuning |
| `CL` | Career & Leadership | System Design Mock Interviews, Negotiation, Team Leadership, Strategy |
| `LF` | Life & Personal Growth | Financial Independence, Health Habits, Productivity, Book Summaries |

---

## 4. 🗂️ The 5 Functional Pillars Explained

Each domain contains the exact same 5 operational subfolders:

* **`01_ERRORS/` (E):** Personal bug journal. Logs exact error messages, the anti-pattern code that caused it, the verified fix, and root cause lessons.
* **`02_LEARNING/` (L):** Deep theory, lifecycle mental models, architecture flowcharts, and simplified explanations.
* **`03_CODE_SAMPLES/` (C):** Production-ready, bulkified, and linted templates ready to copy into projects.
* **`04_NOTEBOOK/` (N):** Interactive coding drills, active recall lab exercises, and challenge problems with verification steps.
* **`05_ONENOTE_DIGEST/` (D):** 5-minute executive summaries, cheat sheets, and flashcards for rapid review before meetings or interviews.

---

## 5. 📚 Comprehensive Curriculum & Topic Roadmap

### Domain 1: Lightning Web Components (LW)
* **Module 1.1 (Reactivity & Props):** `@api` (public reactive), `@track` (deep object mutation), `@wire` (reactive wire service), reactive getters.
* **Module 1.2 (Component Lifecycle):** `constructor()`, `connectedCallback()`, `renderedCallback()`, `disconnectedCallback()`, `errorCallback()`.
* **Module 1.3 (Data & LDS):** Lightning Data Service (`lightning-record-form`, `getRecord`, `getFieldValue`), wire adapters vs imperative Apex.
* **Module 1.4 (Communication):** Custom DOM events (`bubbles: true`, `composed: true`), Lightning Message Service (LMS) across LWC/Aura/VF.
* **Module 1.5 (Security & Testing):** Lightning Web Security (LWS), DOM virtualization, Jest unit testing.

### Domain 2: Enterprise Apex (AP)
* **Module 2.1 (Trigger Frameworks):** One Trigger Per Object, Trigger Handler Pattern, Context Variables, Recursion Control.
* **Module 2.2 (Enterprise Patterns):** Separation of Concerns (SoC), Service Layer, Domain Layer, Selector Layer, Unit of Work (fflib).
* **Module 2.3 (Asynchronous Apex):** Queueable Apex (chaining, transaction finalizers), Batch Apex (stateful vs stateless), Schedulable, `@future`.
* **Module 2.4 (Governor Limits & Optimization):** SOQL in loops prevention, Heap size control, CPU timeout reduction, Bulkification for 200+ records.
* **Module 2.5 (Modern Security):** `WITH USER_MODE`, `stripInaccessible()`, Object & Field Level Security (FLS) enforcement, `@AuraEnabled(cacheable=true)`.

### Domain 3: Salesforce Admin & Security (AD)
* **Module 3.1 (Security Model):** Organization-Wide Defaults (OWD), Role Hierarchy, Criteria & Ownership Sharing Rules, Manual Sharing.
* **Module 3.2 (Permissions):** Profiles vs Permission Sets & Permission Set Groups, Mutability, Session-based permissions.
* **Module 3.3 (Flow Automation Engine):** Record-Triggered Flows (Before vs After Save), Sub-Flows, Screen Flows, Flow Fault Paths, Invocable Apex.

### Domain 4: API & Integrations (IN)
* **Module 4.1 (REST & SOAP):** Apex REST Callouts, Named Credentials, External Credentials, Custom REST Services (`@RestResource`).
* **Module 4.2 (High-Volume & Real-Time):** Platform Events (High-Volume publish/subscribe), Change Data Capture (CDC), `lightning/empApi`.
* **Module 4.3 (Composite APIs):** Salesforce Composite Batch API, Composite Graphs, sObject Collections for mass ingestion.

### Domain 5: System Design & Architecture (SD)
* **Module 5.1 (Distributed Systems):** CAP Theorem, Horizontal vs Vertical Scaling, Load Balancing, Consistent Hashing.
* **Module 5.2 (Caching & Storage):** Redis / Memcached strategies, Cache-aside, Write-through, Write-behind, SQL vs NoSQL.
* **Module 5.3 (Message Brokers):** Event-driven architectures, Kafka, RabbitMQ, Idempotency, Dead Letter Queues (DLQ).

### Domain 6: AI & Agent Systems (AI)
* **Module 6.1 (Agent Foundations):** ReAct loop (Reason + Act), Function Calling, System Prompting, Short-term vs Long-term memory.
* **Module 6.2 (Multi-Agent Swarms):** Blackboard Pattern, Hierarchical Orchestration, Consensus Mechanisms, Agent-to-Agent protocols.
* **Module 6.3 (RAG & Vector Search):** Embeddings, Chunking strategies, Hybrid search (BM25 + Dense Vectors), Vector databases.

### Domain 7: Career & Leadership (CL)
* **Module 7.1 (System Design Interviews):** 45-minute breakdown rubric: Requirements → High-Level Design → Deep Dive → Bottlenecks.
* **Module 7.2 (Technical Leadership):** RFC (Request for Comments) authoring, Architectural review processes, Mentorship frameworks.

### Domain 8: Life & Personal Growth (LF)
* **Module 8.1 (Wealth & Finance):** Asset Allocation, Index Investing, Tax Optimization, Compound Interest Models.
* **Module 8.2 (Habit & Focus):** Spaced Repetition systems, Deep Work blocks, Daily standup reflection logs.

---

## 6. 🤝 Inter-Agent Communication & Contract Ledger

Sub-agents interact asynchronously through the **Blackboard Pattern** and log every agreement in:

📄 `00_SYSTEM/CONTRACT_LEDGER/contracts.jsonl`

### Standard Contract Entry Format

```json
{
  "contract_id": "CTR-2026-0822-001",
  "timestamp": "2026-08-22T00:00:00Z",
  "status": "FULFILLED",
  "requester_agent": "AGENT_MASTER_ORCHESTRATOR",
  "producer_agent": "AGENT_APEX_ARCHITECT",
  "consumer_agent": "AGENT_LWC_SPECIALIST",
  "pincode_artifacts": ["#APC001", "#LWC001"],
  "agreement": {
    "feature": "Account Duplicate Warning Service",
    "apex_method": "public static List<AccountDTO> checkDuplicates(String name, String email)",
    "lwc_binding": "@wire(checkDuplicates, { name: '$name', email: '$email' })",
    "known_gotchas_checked": ["#LWE001", "#APE001"]
  }
}
```

### Contract Lifecycle

1. **PROPOSAL:** Producing Agent drafts the interface specification (e.g. `#APC024`).
2. **VERIFICATION:** Master Orchestrator validates governor limits and type contracts.
3. **CONSUMPTION:** Consuming Agent binds the UI or client logic (e.g. `#LWC052`).
4. **AUDIT:** Transaction sealed with cryptographic timestamp in `contracts.jsonl`.

---

## 7. ⚡ Multi-Model Cost & Token Optimization Strategy

To maintain 95% $0 operating costs, tasks are mapped to optimal open-source and free tiers:

| Tier | Agent Role | Recommended Model | Free Provider |
|---|---|---|---|
| Tier 1: Master Orchestrator | Multi-domain reasoning & life planning | Gemini 2.0 Flash / Pro | Google AI Studio (Free Quota) |
| Tier 2: Apex Architecture | Concurrency, Governor limits, fflib | DeepSeek-R1 / Qwen 2.5 Coder | OpenRouter / Groq Free Tier |
| Tier 3: LWC Frontend & UI | Reactive event logic, DOM rendering | Qwen 2.5 Coder 32B | Groq (500+ tok/s Free) |
| Tier 4: Error Search & Indexing | Fast regex and PINCODE matching | Llama 3.1 8B / Flash-Lite | 100% Free / Local Ollama |
| Tier 5: 5-Min Drills & Flashcards | Active recall quiz evaluation | Llama 3.3 70B Versatile | Groq Cloud Free Tier |

---

## 8. 🔄 The Autonomous Self-Evolution Engine

* **Post-Session Auto-Harvesting:** After every debug session, agents auto-generate the `#PINCODE` markdown snippet.
* **Platform Release Ingestion:** Ingests Salesforce Spring/Winter releases and tech updates automatically.
* **Weekly Knowledge Defragmentation:** Identifies weak spots with high error recurrence and generates fresh drills.

---

## 9. 🌳 Complete Git Branch Tree Schema

```text
main (Global Orchestrator & Dashboard)
│
├── salesforce/
│   ├── lwc/      (main, errors, learning, code-samples, notebook, onenote)
│   ├── apex/     (main, errors, learning, code-samples, notebook, onenote)
│   ├── admin/    (main, errors, learning, code-samples)
│   └── api/      (main, errors, learning, code-samples)
│
├── system-design/
│   ├── microservices
│   ├── distributed-systems
│   ├── databases-and-caching
│   └── case-studies
│
├── ai-engineering/
│   ├── multi-agent-swarms
│   ├── llm-fine-tuning
│   ├── rag-and-vector-db
│   └── open-source-models
│
├── career-leadership/
│   ├── interview-prep
│   ├── system-design-drills
│   └── communication-and-management
│
└── life-growth/
    ├── finance-and-investing
    ├── habits-and-productivity
    └── reading-digests
```

---

## 10. 📝 Standardized Starter Blueprints

### Blueprint A: Error Log Template (`#LWE001`)

```markdown
# [LWE001] Mutating Immutable @wire Property Directly
- **PINCODE:** `#LWE001`
- **Domain:** Lightning Web Components (`LW`)
- **Pillar:** Errors (`E`)
- **Date Logged:** 2026-08-22
- **Frequency:** 1

## 🚨 The Error Message
`TypeError: 'set' on proxy: trap returned falsish for property 'name'`

## ❌ Anti-Pattern (Bad Code)
​```javascript
@wire(getAccounts) accounts;
handleUpdate() {
    // WRONG: Modifying wire proxy directly
    this.accounts.data[0].Name = 'Updated Name';
}
​```

## ✅ Solution (Fixed Code)
​```javascript
handleUpdate() {
    // CORRECT: Clone before modifying
    const clonedData = JSON.parse(JSON.stringify(this.accounts.data));
    clonedData[0].Name = 'Updated Name';
    this.editableAccounts = clonedData;
}
​```

## 🧠 Root Cause Lesson
Objects provisioned by @wire are immutable by design to protect LDS cache integrity.
```

### Blueprint B: Code Sample Template (`#APC001`)

```java
/**
 * @PINCODE #APC001
 * @description Enterprise Trigger Handler Template (One Trigger Per Object)
 */
public class AccountTriggerHandler {

    public void beforeInsert(List<Account> newAccounts) {
        // Bulkified validation logic here
    }

    public void afterInsert(List<Account> newAccounts, Map<Id, Account> newMap) {
        // Asynchronous queueable jobs or platform events here
    }
}
```

---

## 11. 🛠️ Command Quick Reference

### In PowerShell Terminal (`D:\salesforce-agent-brain`)

* `.\brain.ps1 status` → Display repository statistics, error counts, and branch health.
* `.\brain.ps1 sync` → Commit and push all 30+ branches to GitHub.
* `.\brain.ps1 branches` → List all active branches in the tree.

### In IDE Chat

* `@salesforce-brain Explain topic X and create note #LWL002` → Deep dive + auto-harvest.
* `@salesforce-brain Log this error as #LWE or #APE` → Creates new gotchas entry.
* `@salesforce-brain Give me a 5-minute morning quiz` → Active recall flashcard drill.
* `@devops-agent Sync all changes to GitHub` → Automates Git operations.

---

## 12. 💾 Save and Push to GitHub

After saving this file as `README.md` in your repo root:

```powershell
cd D:\salesforce-agent-brain
git add README.md
git commit -m "docs: complete universal architecture README"
git push
```