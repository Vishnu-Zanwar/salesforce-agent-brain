# #DSL004: Shortest Paths & Minimum Spanning Trees

- **PINCODE:** `#DSL004`
- **Topic:** Graph Algorithms II — Weighted Graphs
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 5
- **Related:** [[DSL003]], [[DSL005]]

---

## 🛣️ 1. Shortest Path Algorithms

| Algorithm | Handles | Complexity | Notes |
|---|---|---|---|
| **Dijkstra** | Single-source, **non-negative weights only** | `O(V²)` array / `O((V+E) log V)` heap | Greedily picks the closest unvisited vertex each round, relaxes its neighbors |
| **Bellman-Ford** | Single-source, **negative weights OK**, detects negative cycles | `O(V·E)` always | Relaxes every edge `V-1` times. Always this cost, even on graphs Dijkstra could handle faster — that's the price of generality |
| **Floyd-Warshall** | **All-pairs**, negative weights OK, detects negative cycles | `O(V³)` | Dynamic programming; track a predecessor matrix to reconstruct actual paths, not just distances |

```python
def dijkstra(WList, s):
    infinity = float('inf')
    visited = {v: False for v in WList}
    distance = {v: infinity for v in WList}
    distance[s] = 0
    for _ in WList:
        u = min((v for v in WList if not visited[v]), key=lambda v: distance[v])
        visited[u] = True
        for (v, d) in WList[u]:
            if not visited[v]:
                distance[v] = min(distance[v], distance[u] + d)
    return distance
```

A **negative cycle** makes "shortest path" undefined — you could loop it forever getting cheaper. Only Bellman-Ford and Floyd-Warshall can detect one; Dijkstra assumes they don't exist.

## 🌲 2. Minimum Spanning Tree (MST)

The subset of edges connecting all vertices with minimum total weight, no cycles.

- **Kruskal's** — sort all edges by weight, greedily add each unless it creates a cycle (checked with Union-Find, see [[DSL005]]). `O(E log E)`.
- **Prim's** — grow a single tree outward, always adding the cheapest edge connecting the tree to a new vertex. `O(E log V)` with a heap.

**When Prim's and Kruskal's can disagree** on *which* MST they produce (both still find the *minimum* total weight): only when the graph has **edges with equal weights** — with all-distinct weights, the MST is unique and both algorithms find the identical tree.

## 🧭 3. How to Recognize Which Applies

- Single source, all weights known non-negative → Dijkstra.
- Any negative weight, or need to *detect* one → Bellman-Ford (single source) or Floyd-Warshall (all pairs).
- Need distances between *every* pair of vertices → Floyd-Warshall, don't run Dijkstra V times unless V is small.
- "Connect everything as cheaply as possible" → MST (Kruskal's if edge list is naturally available and sorted; Prim's if growing from a known starting point).
