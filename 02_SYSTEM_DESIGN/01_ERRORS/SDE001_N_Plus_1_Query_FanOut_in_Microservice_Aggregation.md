# #SDE001: N+1 Query Fan-Out in Microservice Aggregation

- **PINCODE:** `#SDE001`
- **Topic:** Distributed Systems / Service-to-Service Fan-Out
- **Domain:** System Design
- **Created Date:** 2026-08-29
- **Last Verified:** 2026-08-29
- **Status:** Active

---

## 🛑 1. The Problem

An aggregation/BFF (backend-for-frontend) service calls a downstream service once per item in a list it just fetched, instead of once for the whole batch:

```
GET /orders                    -> 1 call, returns 50 orders
for each order:
    GET /customers/{order.customerId}   -> 50 calls
```

50 orders means 51 network round-trips instead of 2. Under load this multiplies: 100 concurrent requests to `/orders` can produce 5,000+ downstream calls, exhausting the downstream service's connection pool and causing cascading latency or timeouts — the exact same shape as the SOQL-in-a-loop anti-pattern in Apex ([[APL001]]), just at the network layer instead of the database layer.

## 🔎 2. Root Cause

The aggregation layer was written assuming each downstream call is cheap, without accounting for the multiplicative cost of doing it per-item rather than per-batch. This is easy to miss in development (list size = 3, looks fine) and only shows up under production data volume.

## ✅ 3. Fix

Batch the downstream call using whatever bulk-fetch endpoint the service exposes:

```
GET /orders                              -> 1 call, 50 orders
GET /customers?ids=1,2,3,...,50          -> 1 call, all 50 customers
```

If the downstream service has no batch endpoint, that's the actual thing to fix — not working around it with concurrency limiting, which caps the damage but doesn't remove the multiplicative call count.

## 🧭 4. How to Recognize This Before It Happens

- Any `for`/`map` loop that makes a network call per iteration is a candidate, the same way any loop with a SOQL query inside it is in Apex.
- Load-test with realistic list sizes (hundreds, not the 3-item list used during development) before shipping an aggregation endpoint.
