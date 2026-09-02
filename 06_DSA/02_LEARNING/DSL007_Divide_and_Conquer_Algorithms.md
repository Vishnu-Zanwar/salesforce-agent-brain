# #DSL007: Divide & Conquer Algorithms

- **PINCODE:** `#DSL007`
- **Topic:** Counting Inversions, Median of Medians, Classic D&C Wins
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 8
- **Related:** [[DSL001]]

---

## 🔢 1. Counting Inversions

A pair `(i,j)` with `i<j` is an **inversion** if `L[i] > L[j]` — it measures "how far from sorted" a list is. Naive: check every pair, `O(n²)`. **The divide-and-conquer win:** a modified merge sort counts *cross-inversions* during the merge step itself (when taking from the right half before the left half is exhausted, every remaining element in the left half forms an inversion with it) — `O(n log n)`, reusing the merge-sort structure entirely rather than adding separate logic.

## 🎯 2. Median of Medians (MoM)

Finds an **approximate median in guaranteed `O(n)` time** — unlike naive "sort then pick the middle" (`O(n log n)`). Method: split the list into groups of 5, find each group's median (fast — tiny groups), then recursively find the median *of those medians*. This guarantees a "good enough" pivot, which is what lets **Quickselect** (finding the k-th smallest element) run in worst-case linear time instead of quicksort's `O(n²)` worst case — MoM removes quickselect's dependence on lucky pivot choices.

## 📏 3. Other Classic Divide-and-Conquer Wins

- **Closest pair of points** — naive check-every-pair is `O(n²)`; divide-and-conquer (split by x-coordinate, recurse, then check only a thin strip near the dividing line) drops it to `O(n log n)`.
- **Karatsuba integer multiplication** — grade-school multiplication of two `n`-digit numbers is `O(n²)`; recursively splitting each number in half drops it to about `O(n^1.585)`.

## 🧭 4. How to Recognize Which Applies

- "Count pairs satisfying some order-violating condition" → check whether a merge-sort-style pass can count them during the merge, rather than an `O(n²)` nested loop.
- "Find the k-th smallest/largest with a guaranteed bound, not just average case" → Median of Medians + Quickselect.
- Any problem where the naive solution checks all pairs (`O(n²)`) and the data has spatial or numeric structure that can be split → ask whether a divide-and-conquer split beats it, the way it does for closest-pair and Karatsuba.
