# #DSL010: String Matching Algorithms

- **PINCODE:** `#DSL010`
- **Topic:** Finding a Pattern Inside a Text — Five Approaches
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 12

---

## 🎯 1. The Problem

Given a text of length `n` and a pattern of length `m`, find where the pattern occurs in the text.

## 📋 2. The Five Approaches

| Algorithm | Idea | Complexity |
|---|---|---|
| **Brute force** | Slide the pattern one position at a time, compare character by character | `O(n·m)` worst case |
| **Boyer-Moore** | Compare **right-to-left** at each position; on mismatch, use the "bad character" seen in the text to skip ahead by more than one position | Often much faster than brute force in practice, especially on natural-language text |
| **Rabin-Karp** | **Rolling hash** — hash the pattern and each length-`m` window of the text, compare hashes first (cheap), only do a full character comparison when hashes match (rules out collisions) | `O(n+m)` average case |
| **Knuth-Morris-Pratt (KMP)** | Precompute a "failure function" / prefix table for the pattern, so after a mismatch it never re-checks characters it already knows must match | `O(n+m)` guaranteed, no re-scanning |
| **Tries** | A tree where each root-to-node path spells out a string or prefix | Extremely fast for prefix-based lookups — autocomplete, dictionary lookups, searching for many patterns at once |

## 🧭 3. How to Recognize Which Applies

- Single pattern, single text, no guarantees needed, simplicity matters more than speed → brute force is fine for small inputs.
- Single pattern, natural-language text, want practical speed without implementation complexity → Boyer-Moore.
- Need to search for the *same* pattern across *many* texts, or want to detect a match cheaply before committing to full comparison → Rabin-Karp's rolling hash amortizes well.
- Need a **guaranteed** linear bound, no reliance on "usually fast" → KMP.
- Need to search for **many patterns at once**, or need prefix-based lookups (autocomplete) → Trie, not a per-pattern search algorithm at all.
