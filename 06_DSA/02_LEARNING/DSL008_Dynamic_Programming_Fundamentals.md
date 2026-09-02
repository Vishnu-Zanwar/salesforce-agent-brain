# #DSL008: Dynamic Programming Fundamentals

- **PINCODE:** `#DSL008`
- **Topic:** Optimal Substructure, Overlapping Subproblems, and the Classic Problems
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 9
- **Related:** [[DSL006]], [[DSL007]]

---

## 🎯 1. When DP Applies

A problem qualifies when it has both:
- **Optimal substructure** — the best solution to the whole problem is built from best solutions to its subproblems.
- **Overlapping subproblems** — naive recursion would solve the *same* subproblem repeatedly.

DP fixes the repetition by solving each subproblem **once** and storing the answer — top-down (recursion + memoization) or bottom-up (filling a table iteratively).

## 📋 2. The Classic Problems

- **Grid paths** — count paths through a grid, moving only right/up, avoiding blocked cells: `paths(i,j) = paths(i-1,j) + paths(i,j-1)`.
- **Longest Common Subsequence (LCS)** — longest sequence of characters (not necessarily contiguous) common to two strings, preserving relative order.
- **Longest Common Substring (LCW)** — like LCS, but must be *contiguous*.
- **Edit distance** — minimum insertions/deletions/substitutions to turn one string into another.
- **Matrix chain multiplication** — given a chain of matrices, find the parenthesization minimizing total scalar multiplications (grouping order changes the multiplication count substantially, even though the mathematical result is identical).

```python
def lcs_len(X, Y):
    m, n = len(X), len(Y)
    dp = [[0]*(n+1) for _ in range(m+1)]
    for i in range(1, m+1):
        for j in range(1, n+1):
            if X[i-1] == Y[j-1]:
                dp[i][j] = dp[i-1][j-1] + 1
            else:
                dp[i][j] = max(dp[i-1][j], dp[i][j-1])
    return dp[m][n]
```

## 🧮 3. Filling a DP Table by Hand

1. Draw the grid (rows = one input, columns = the other, for 2D problems like LCS).
2. Fill the base-case row/column first (usually zeros).
3. Fill every other cell using the recurrence — it only ever looks at *already-filled* cells (above, left, or diagonally above-left). If a rule seems to need a cell you haven't computed, you have the fill order wrong.
4. The answer is almost always in the bottom-right corner once the table is full.

## 🧭 4. How to Recognize This Applies

- A greedy approach ([[DSL006]]) provably fails on the problem (e.g. non-canonical coin change) → DP considers all combinations instead of committing early.
- The problem asks for a count, a minimum/maximum, or an optimal grouping over a sequence or grid, and a brute-force recursive solution would visibly re-solve identical subproblems → memoize it.
- Two-string problems (LCS, edit distance) almost always resolve to a 2D table with one string per axis.
