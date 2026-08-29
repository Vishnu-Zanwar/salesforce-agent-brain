# #SDL001: Consistent Hashing Fundamentals for Sharded Systems

- **PINCODE:** `#SDL001`
- **Topic:** Distributed Systems / Sharding & Load Distribution
- **Domain:** System Design
- **Created Date:** 2026-08-29
- **Last Verified:** 2026-08-29
- **Status:** Active
- **Related:** [[SDE001]]

---

## 🎯 1. The Problem It Solves

Naive sharding assigns a key to a node with `hash(key) % N` where `N` is the number of nodes. This works until `N` changes (a node is added or removed) — then almost every key remaps to a different node, because the modulo of nearly every key shifts. For a cache, that's a near-total cache wipe; for a data store, it's a massive, unnecessary rebalance.

## 🔎 2. How Consistent Hashing Fixes It

Both nodes and keys are hashed onto the same fixed-size ring (e.g. 0 to 2^32-1). A key belongs to the first node found walking clockwise from the key's position on the ring.

```
        node_A
       /        \
  key_1          node_C
       \        /
        node_B
```

Adding or removing a node only reassigns the keys between that node and its neighbor on the ring — roughly `1/N` of all keys, not nearly all of them. This is the property that makes horizontal scaling and node failure recovery cheap instead of catastrophic.

## ⚡ 3. Virtual Nodes (the practical refinement)

Plain consistent hashing can still distribute keys unevenly if node hash positions happen to cluster. The fix used in real systems (DynamoDB, Cassandra, many Redis Cluster-like setups) is **virtual nodes**: each physical node is hashed onto the ring multiple times (e.g. 100–200 virtual positions per physical node) under different labels (`node_A#0`, `node_A#1`, ...). More points on the ring per node smooths out the distribution and makes load rebalancing on node add/remove proportionally even across the remaining nodes, not dumped onto one neighbor.

## 🧭 4. When This Comes Up

- Sharding a cache or database horizontally across N nodes where N changes over time.
- Client-side load balancing across a dynamic pool of backend replicas.
- Distributed hash tables (DHTs) generally — this is the mechanism underneath them.
