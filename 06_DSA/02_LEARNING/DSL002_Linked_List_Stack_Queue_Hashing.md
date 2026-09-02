# #DSL002: Linked List, Stack, Queue & Hashing

- **PINCODE:** `#DSL002`
- **Topic:** Core Linear Data Structures
- **Domain:** DSA (Data Structures & Algorithms)
- **Created Date:** 2026-09-02
- **Last Verified:** 2026-09-02
- **Status:** Active
- **Source:** IITM BS "Programming, Data Structures & Algorithms" course, Week 3
- **Related:** [[LWE004]]

---

## 🔗 1. Linked List

A chain of nodes, each holding a value and a pointer to the next node.

```python
class Node:
    def __init__(self, value, next=None):
        self.value = value
        self.next = next
```

| Operation | Complexity | Why |
|---|---|---|
| Insert at front | `O(1)` | No shifting — just repoint the head |
| Insert at end | `O(1)` *only with a maintained tail pointer* — else `O(n)` to find the end |
| Delete first node | `O(1)` | Move head to `head.next` |
| Delete last node | `O(n)` even with a tail pointer | Singly-linked lists can't jump backward — must walk from head to find the new second-to-last node. A doubly-linked list makes this `O(1)` too. |
| Access by index | `O(n)` | No random access, unlike arrays |

**Sorted-list trick:** in a sorted linked list, any duplicate sits immediately next to the original — walk once, compare each node to its immediate successor. `O(n)`, no extra memory. A nested loop (`O(n²)`) or a hash table (extra space) both do more work than the sorted order requires.

## 📚 2. Stack (LIFO)

`push()` / `pop()`, both `O(1)`. Used for: undo/redo, matching brackets, DFS, the function call stack itself.

## 🚶 3. Queue (FIFO)

`enqueue()` / `dequeue()`, both `O(1)` with the right implementation. Used for: BFS, task scheduling, print queues.

## #️⃣ 4. Hashing

A hash function maps a key to an array index for near-`O(1)` average lookup/insert. Two collision-resolution strategies:

- **Chaining** — each slot holds a small list; colliding keys append to it.
- **Open addressing (linear probing)** — on collision, check the *next* slot (wrapping around) until an empty one is found.

**Tracing linear probing by hand:** for each key, compute `slot = key % table_size`. Empty → place it. Occupied → check `slot+1`, `slot+2`, ... wrapping to 0, until empty. **Order matters** — inserting keys in a different order can produce a different final table when collisions occur.

## 🧭 5. How to Recognize Which Applies

- Need `O(1)` insert/delete at the front, and traversal is always sequential (never random-access by index)? Linked list.
- Need "undo the last thing" or "match nested pairs"? Stack.
- Need "process in the order received" or "explore level by level"? Queue.
- Need near-`O(1)` lookup by key, with no ordering requirement? Hash table — but remember insertion order affects collision placement under open addressing.
