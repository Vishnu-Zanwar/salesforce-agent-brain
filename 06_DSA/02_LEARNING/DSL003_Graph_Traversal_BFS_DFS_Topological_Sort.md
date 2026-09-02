# #DSL003: Graph Traversal — BFS, DFS, DAGs & Topological Sort

- **PINCODE:** `#DSL003`
- **Topic:** Graph Algorithms I
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 4
- **Related:** [[DSL004]]

---

## 🎯 1. Representation

A graph is vertices connected by edges (directed or undirected). Two representations:
- **Adjacency list** — each vertex stores its neighbors. Compact, fast to iterate. The usual default.
- **Adjacency matrix** — a `V×V` grid of 0/1. Fast "is there an edge?" check, wasteful on sparse graphs.

## 🌊 2. BFS (Breadth-First Search)

Explore level by level using a **queue**: all neighbors of the start, then all neighbors-of-neighbors. `O(V+E)`. Produces the **shortest path in number of edges** on an unweighted graph.

**Key invariant:** in the resulting BFS tree, every non-tree edge connects vertices whose levels differ by **at most 1** — never more. This is a fast way to spot an impossible BFS-tree edge in a problem: if two vertices are 3+ levels apart, an edge between them could not exist in a graph that produced that tree.

## 🕳️ 3. DFS (Depth-First Search)

Explore as deep as possible before backtracking, using a **stack** (or recursion). `O(V+E)`. Each vertex gets a discovery time and a finish time; edges classify into 4 buckets by comparing `u`/`v`'s times:

- **Tree edge** — leads to an undiscovered vertex.
- **Back edge** — leads to an ancestor still "in progress" → **means there's a cycle**.
- **Forward/cross edge** — leads to an already-finished vertex in a different branch (directed graphs, more common there).

## 📐 4. DAGs & Topological Sort

A **DAG** (Directed Acyclic Graph) has no cycles. Only DAGs have a valid **topological sort** — an ordering where every edge points from earlier to later. Used for scheduling with prerequisites (e.g. course/module dependencies). A DAG can have **multiple** valid topological orderings when some vertices have no ordering constraint relative to each other.

## 🔍 5. Related Structural Concepts

- **Articulation points (cut vertices)** — a node whose removal disconnects the graph. Identifiable via DFS discovery/low-link values.
- **Vertex cover / independent set** — for many graph problems these have a direct complementary relationship (a formula connecting the two sizes) rather than needing separate computation.

## 🧭 6. How to Recognize Which Applies

- "Shortest path, unweighted" or "explore level by level" → BFS.
- "Detect a cycle," "classify edges," or "explore as deep as possible" → DFS.
- "Schedule tasks with prerequisites," "order these dependencies" → check it's a DAG first, then topological sort.
- Any BFS-tree-edge or DFS-edge-classification question → compare levels/discovery-finish times rather than trying to eyeball the graph.
