# #DSL009: Linear Programming, Network Flow & Complexity Classes

- **PINCODE:** `#DSL009`
- **Topic:** LP Formulation, Max-Flow Min-Cut, P vs NP
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 11

---

## 📐 1. Linear Programming (LP)

Optimize (max or min) a linear objective, subject to linear constraints. **Formulation recipe:**
1. Define decision variables — what you're choosing the quantity of (e.g. "units of product X to make").
2. Write the objective as a linear combination of those variables.
3. Write every real-world limit (time, material, demand) as a linear inequality in the same variables.
4. Don't forget non-negativity (`x ≥ 0`).

**Turning a word problem into an LP:** underline every number and ask "what does this limit?" — that's a constraint. Underline what's being maximized (usually profit/revenue) — that's the objective. Derive the inequalities fresh each time rather than pattern-matching against a memorized template; word problems vary the phrasing specifically to catch memorization.

## 🌊 2. Network Flow

Model a system as a directed graph with edge **capacities**; find the maximum flow from source to sink without exceeding any capacity.

**Max-Flow Min-Cut theorem:** the maximum possible flow equals the minimum-capacity "cut" separating source from sink (a cut's capacity = sum of capacities of edges crossing from the source's side to the sink's side).

**Common trap:** minimum cut is about **total capacity crossing the cut**, never the number of edges cut. A 1-edge cut can have huge capacity; a 5-edge cut can have tiny total capacity if each edge is narrow.

**Modeling trick:** many assignment/matching/allocation problems (seat allocation, teacher-subject assignment) become network flow problems by choosing what source, sink, and edge capacities represent — e.g. a teacher-node connects to the source with capacity = number of subjects they can teach, and each subject-node connects to the sink with capacity 1.

## 🧩 3. Complexity Classes

| Class | Definition |
|---|---|
| **P** | Solvable in polynomial time |
| **NP** | Solution *verifiable* in polynomial time (not necessarily solvable quickly) |
| **NP-hard** | At least as hard as the hardest NP problems — every NP problem reduces to it. Doesn't have to be in NP itself. |
| **NP-complete** | In NP **and** NP-hard — the hardest problems that are still quickly verifiable |

**The trap that catches true/false questions:** if problem A is NP-hard and reduces to problem B in polynomial time, that tells you **B is at least as hard as A** — it does **not** automatically mean B is in NP, or that B is NP-complete. Reducibility only establishes a lower bound on difficulty, never membership in NP.

## 🧭 4. How to Recognize Which Applies

- "Maximize/minimize subject to linear limits" with clearly nameable decision variables → LP.
- "Assign/allocate limited resources between two groups" → check whether it maps to a flow network (source → group A → group B → sink) before reaching for a bespoke algorithm.
- Any true/false statement chaining NP-hardness and polynomial reductions → check specifically whether it claims NP *membership*, which reduction alone never proves.
