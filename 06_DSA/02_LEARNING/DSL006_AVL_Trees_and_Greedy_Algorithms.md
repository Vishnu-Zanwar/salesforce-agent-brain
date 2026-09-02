# #DSL006: AVL Trees & Greedy Algorithms

- **PINCODE:** `#DSL006`
- **Topic:** Self-Balancing Trees, Greedy Strategy & Its Limits
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 7
- **Related:** [[DSL005]]

---

## 🌲 1. AVL Tree

A self-balancing BST. Every node tracks a **balance factor** = `height(left) − height(right)`, which must stay in `{-1, 0, 1}`. Whenever an insertion pushes a node's balance factor to `+2` or `-2`, a **rotation** restores balance — apply it immediately after the insertion that caused it, not at the end of a sequence of inserts, since a later insertion's rotation logic depends on the tree already being valid.

**Node count bounds by height** (with single-node = height 1):
- **Maximum** nodes at height `h`: a completely full tree — `2^h − 1`.
- **Minimum** nodes at height `h`: governed by the AVL balance constraint itself — grows slower than the max case, which is exactly why AVL guarantees `O(log n)` height even in the worst case (unlike a plain BST, [[DSL005]]).

## 🎯 2. Greedy Algorithms

Build a solution piece by piece, always taking the locally-best option, hoping — and for the right problems, provably guaranteed — that this leads to a globally optimal solution.

**Huffman coding** is the canonical example: repeatedly merge the two lowest-frequency nodes into a new parent, building an optimal prefix-free encoding tree bottom-up. This genuinely produces the global optimum (minimum weighted path length) because of the specific structure of the problem.

**Where greedy provably fails:** greedy coin-change (always take the largest coin that fits) only works for "canonical" coin systems (like standard currency denominations). Give it a denomination set where the greedy choice at one step forecloses a better combination later, and it produces a suboptimal answer — the fix is dynamic programming ([[DSL008]]), which considers all combinations rather than committing early.

**Scheduling to minimize maximum lateness** is another greedy-friendly problem: sort by *deadline*, not by job length or arrival order — a case where the correct greedy criterion isn't the intuitive one.

## 🧭 3. How to Recognize Which Applies

- Need `O(log n)` guaranteed even under adversarial (e.g. sorted-order) insertion? AVL tree, not a plain BST.
- A problem where committing to the locally-best choice never has to be undone (matroid-like structure, e.g. Huffman, MST, interval scheduling by earliest deadline)? Greedy is likely provably correct.
- A problem where an early "obviously good" choice can block a better global solution (e.g. non-canonical coin systems, knapsack)? Don't reach for greedy — that's dynamic programming's territory.
