# #DSL005: Union-Find, Priority Queue, Heap & Binary Search Tree

- **PINCODE:** `#DSL005`
- **Topic:** Set & Priority Structures, Ordered Trees
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 6
- **Related:** [[DSL004]], [[DSL006]]

---

## 🔗 1. Union-Find (Disjoint Set)

Tracks a collection of disjoint sets, supporting `Find(x)` (which set is x in?) and `Union(x, y)` (merge two sets). With union-by-size/rank, both operations are `O(log n)` amortized. Backs Kruskal's cycle check: before adding an edge, `Find` both endpoints — same set means adding the edge would create a cycle, skip it.

**Kruskal's overall complexity, worked out:** a spanning tree has `n-1` edges, so at most `n-1` `Union()` calls, each `O(log n)` amortized. Sorting the `E` edges costs `O(E log E)`, which dominates → **Kruskal's is `O(E log E)` overall**, not the Union-Find cost.

## ⛰️ 2. Priority Queue & Heap

A **heap** is the standard priority-queue implementation: a complete binary tree stored as an array, satisfying the heap property (max-heap: every parent ≥ its children; min-heap: every parent ≤).

| Operation | Complexity | Trap to know |
|---|---|---|
| `insert()` | `O(log n)` | New element starts at the last array slot, "floats up" swapping with its parent until it stops winning — it can only move straight upward, never sideways to a different branch |
| `delete_max()` / `delete_min()` | `O(log n)` | Swap root with last element, remove last, "sift down" the new root |
| `build_heap()` (bottom-up heapify) | `O(n)` | **Not** `O(n log n)` — a favorite trap. Heap sort overall is `O(n log n)`, in place. |

**"Could this value have been inserted last?"** trick: trace backward from where it sits — a value that just floated up can only have come from the last array position, moving straight up through its ancestors. If a candidate isn't reachable by that path, it couldn't have been last inserted.

## 🌳 3. Binary Search Tree (BST)

Left subtree < node < right subtree, recursively.

```python
# find/insert/delete all walk a single root-to-leaf path
```

`find()`, `insert()`, `delete()` are all `O(height)`. An unbalanced tree (e.g. inserting an already-sorted sequence, which degenerates into a linked list) can hit `O(n)` height; a balanced tree keeps `O(log n)` — the entire motivation for AVL trees ([[DSL006]]).

**Two facts worth memorizing rather than re-deriving:**
- In-order traversal of a BST always yields the values in sorted order.
- The same *set* of values can produce different tree *shapes* depending on insertion order — some insertion orders happen to produce an identical tree, others don't. When asked "which insertion orders produce this exact tree," simulate each candidate rather than reasoning abstractly.

## 🧭 4. How to Recognize Which Applies

- Need to track "which group is this in" with frequent merges → Union-Find.
- Need "always the biggest/smallest, fast" → heap/priority queue.
- Need ordered data with fast lookup/insert/delete, and don't need worst-case guarantees → BST (upgrade to AVL, [[DSL006]], if insertion order might be adversarial/sorted).
