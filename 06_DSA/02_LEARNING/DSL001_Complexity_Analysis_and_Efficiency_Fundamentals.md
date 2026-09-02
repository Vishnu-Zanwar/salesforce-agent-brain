# #DSL001: Complexity Analysis & Efficiency Fundamentals

- **PINCODE:** `#DSL001`
- **Topic:** Big-O Notation, Searching, and the Four Basic Sorts
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Weeks 1-2

---

## 🎯 1. Why Efficiency Matters

The same problem can take wildly different amounts of work depending on approach. **GCD** is the canonical example: brute-force checking every number up to `min(a,b)` works but is slow; **Euclid's algorithm** — `gcd(a,b) = gcd(b, a % b)` until `b == 0` — runs in `O(log(min(a,b)))`, dramatically faster.

```python
def gcd(a, b):
    while b:
        a, b = b, a % b
    return a
```

**Checking primality** only needs divisors up to `√n`: if `n = a×b` with both `a,b > √n`, then `a×b > n` — a contradiction. Never check beyond `√n`.

## 📏 2. Big-O Notation

Measures how work grows as input size `n` grows, ignoring constant factors, focused on the trend for large `n`. The standard ladder, slowest to fastest-growing:

```
O(1) < O(log n) < O(n) < O(n log n) < O(n²) < O(n³) < O(2ⁿ) < O(n!)
```

## 🔍 3. Searching

- **Linear search** — check every element. `O(n)` worst case. Works on *any* list, sorted or not.
- **Binary search** — repeatedly halve the range by comparing the middle. `O(log n)`, but **requires a sorted list with random access** (a linked list can't jump to the middle in one step, so binary search's whole advantage disappears there).

Linear search wins when: the list is unsorted, tiny, changes constantly (expensive to keep sorted), or has no random access (e.g. a linked list) — binary search's `O(log n)` only pays off when the list is *both* sorted *and* randomly-accessible.

## 🔀 4. The Four Basic Sorts

| Sort | Worst Case | Best Case | Notes |
|---|---|---|---|
| **Selection sort** | `O(n²)` | `O(n²)` | Always scans the full unsorted tail every pass — never "notices" if already sorted |
| **Insertion sort** | `O(n²)` | `O(n)` | Fast on nearly-sorted data — the one sort whose best case actually differs from worst case |
| **Merge sort** | `O(n log n)` | `O(n log n)` | Split, recursively sort halves, merge — consistent regardless of input order |
| **Quick sort** | `O(n²)` | `O(n log n)` avg | Worst case hits on already-sorted/reverse-sorted input with a naive (first/last-element) pivot — **both** first-element and last-element pivot choices degrade to `O(n²)` on such input, since one side of the partition ends up empty every time. Real implementations use a randomized or median-of-three pivot to avoid this. |

**Cost-swap trick:** if elements being compared aren't plain numbers (e.g. sorting `n` strings of length `k`), multiply in the real per-comparison cost — merge sort on strings is `O(nk log n)`, not `O(n log n)`, because each comparison costs `O(k)` instead of `O(1)`.

## 🧭 5. How to Recognize Which Applies

- Given a fixed, known dataset that's queried once: any search is fine. Given a dataset queried repeatedly: sort once, then binary search.
- Nearly-sorted data arriving incrementally → insertion sort's `O(n)` best case is a real advantage, not just a curiosity.
- Already-sorted or reverse-sorted input feeding a naive quicksort → expect `O(n²)`, not the "expected" `O(n log n)`.
