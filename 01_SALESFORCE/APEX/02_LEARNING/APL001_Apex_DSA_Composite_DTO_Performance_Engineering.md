# #APL001: Apex & LWC Performance Engineering: DSA Bucketing, N+1 Wire Prevention, and Composite DTO Pattern

- **PINCODE:** #APL001
- **Topic:** Apex Performance, Data Structures & Algorithms (DSA), and Full-Stack LWC Optimization
- **Domain:** Apex / LWC / High-Scale Architecture / System Design
- **Created Date:** 2026-08-24
- **Status:** Active
- **Related:** #LWE001, #LWL002, #APC001

---

## 🎯 1. Executive Summary

In enterprise Salesforce applications, poorly structured component hierarchies and un-optimized Apex queries often introduce the **N+1 Wire Anti-Pattern**, where child components instantiated in a loop fire dozens of independent Apex queries.

This guide details how to apply **fundamental Data Structures & Algorithms (DSA)** in Apex — specifically **Hash Map Grouping ((N)$)**, **Hash Sets ((1)$ Lookups)**, and the **Composite DTO (Data Transfer Object) Pattern** — to reduce network round-trips by 75% and optimize CPU execution time.

---

## 🛑 2. Anti-Patterns Identified

### Anti-Pattern 1: The N+1 Child @wire Execution
* **Scenario:** <c-course-offerings> renders a list of 10 offerings. Inside its or:each loop, each row contains <c-course-schedule record-id={Course.Id}>.
* **Problem:** Each <c-course-schedule> independently runs @wire(getCourseSchedules).
* **Impact:** 10 offerings = 10 simultaneous Apex network calls, saturating browser connection limits and overloading the Salesforce application tier.

### Anti-Pattern 2: Multi-Wire Page Initialization Jitter
* **Scenario:** A page component independently wires Course Details, User Registration Status, and Course Offerings across 3 separate Apex methods.
* **Problem:** 3 asynchronous Apex round-trips resolve at different timestamps, causing progressive layout shifts and multiple UI re-renders.

---

## ⚡ 3. DSA Optimizations in Apex

`
[ Traditional Multiple Calls ] ──> 4 Apex Trips, N Child Queries (High Latency)
             ▼
[ DSA Composite DTO + Hash Map ] ──> 1 Apex Trip, O(1) Hash Map Grouping (10x Faster)
`

### 🔹 1. Hash Map Bucketing ((N)$ Linear Time Complexity)
Instead of searching schedules in a nested loop ((N \times M)$) or querying inside a loop (SOQL 101 governor error):

`pex
// Single SOQL query across all children
List<CourseOfferingSchedule> allSchedules = [
    SELECT Id, CourseOfferingId, StartTime, EndTime, IsMonday, IsTuesday, IsWednesday, IsThursday, IsFriday 
    FROM CourseOfferingSchedule 
    WHERE CourseOffering.LearningCourseId = :courseId
    WITH SYSTEM_MODE
];

// O(N) Hash Map Bucket Grouping
Map<Id, List<CourseOfferingSchedule>> schedulesByOfferingId = new Map<Id, List<CourseOfferingSchedule>>();
for (CourseOfferingSchedule s : allSchedules) {
    if (!schedulesByOfferingId.containsKey(s.CourseOfferingId)) {
        schedulesByOfferingId.put(s.CourseOfferingId, new List<CourseOfferingSchedule>());
    }
    schedulesByOfferingId.get(s.CourseOfferingId).add(s);
}
`

### 🔹 2. Hash Set for Constant Time (1)$ Membership
Checking if a contact is already registered in a course offering:
`pex
Set<Id> registeredOfferingIds = new Set<Id>();
for (CourseOfferingParticipant p : [
    SELECT CourseOfferingId 
    FROM CourseOfferingParticipant 
    WHERE ParticipantContactId = :contactId
]) {
    registeredOfferingIds.add(p.CourseOfferingId);
}

// O(1) constant-time check instead of scanning a List in O(N)
if (!registeredOfferingIds.contains(offeringId)) {
    // Proceed with registration
}
`

### 🔹 3. The Composite DTO (Single-Trip Payload Pattern)
Bundle the entire page requirement into one structured Apex Data Transfer Object (DTO):

`pex
public without sharing class CourseController {

    public class CoursePageDTO {
        @AuraEnabled public LearningCourse course { get; set; }
        @AuraEnabled public Boolean isRegistered { get; set; }
        @AuraEnabled public List<OfferingDTO> offerings { get; set; }
    }

    public class OfferingDTO {
        @AuraEnabled public CourseOffering offering { get; set; }
        @AuraEnabled public List<CourseOfferingSchedule> schedules { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static CoursePageDTO getCoursePageData(Id courseId) {
        if (courseId == null) return null;
        
        CoursePageDTO dto = new CoursePageDTO();
        
        // 1. Fetch Course Details
        dto.course = [SELECT Id, Name, Description, Duration, DurationUnit FROM LearningCourse WHERE Id = :courseId LIMIT 1];
        
        // 2. Fetch User Registration Status
        Id contactId = getCurrentUserContactId();
        dto.isRegistered = (contactId != null) && [SELECT count() FROM CourseOfferingParticipant 
            WHERE ParticipantContactId = :contactId AND CourseOffering.LearningCourseId = :courseId] > 0;
            
        // 3. Fetch Offerings & Map-Grouped Schedules
        List<CourseOffering> offerings = [SELECT Id, Name, PrimaryFaculty.Name FROM CourseOffering WHERE LearningCourseId = :courseId];
        List<CourseOfferingSchedule> schedules = [SELECT Id, CourseOfferingId, StartTime, EndTime FROM CourseOfferingSchedule WHERE CourseOffering.LearningCourseId = :courseId];
        
        Map<Id, List<CourseOfferingSchedule>> scheduleMap = new Map<Id, List<CourseOfferingSchedule>>();
        for (CourseOfferingSchedule sch : schedules) {
            if (!scheduleMap.containsKey(sch.CourseOfferingId)) {
                scheduleMap.put(sch.CourseOfferingId, new List<CourseOfferingSchedule>());
            }
            scheduleMap.get(sch.CourseOfferingId).add(sch);
        }
        
        dto.offerings = new List<OfferingDTO>();
        for (CourseOffering off : offerings) {
            OfferingDTO offDto = new OfferingDTO();
            offDto.offering = off;
            offDto.schedules = scheduleMap.containsKey(off.Id) ? scheduleMap.get(off.Id) : new List<CourseOfferingSchedule>();
            dto.offerings.add(offDto);
        }
        
        return dto;
    }
}
`

---

## 📊 4. Data Scalability Matrix (Client vs. Server-Side)

| Metric | Client-Side Slicing (Current) | Server-Side Pagination (Large Data) |
| :--- | :--- | :--- |
| **Dataset Size** | ** \le 100$ records** | ** > 100$ records** |
| **UI Filter Latency** | **\text{ ms}$ (Instant In-Memory)** | \text{--}500\text{ ms}$ (Server Round-Trip) |
| **Initial Load Payload** | Entire array serialized | Page chunk only (LIMIT :pageSize OFFSET :offset) |
| **Memory Footprint** | Low ($< 50\text{ KB}$) | Minimal ($< 10\text{ KB}$) |
| **Best For** | Cohort selection, course offerings, catalogs | Global student ledgers, enterprise transaction logs |

---

## 🔍 5. Verification Checklist
- [x] Child components receive pre-fetched schedule collections via @api properties instead of firing independent @wire queries.
- [x] Parent-child relationships in Apex are processed via Map<Id, List<SObject>> in (N)$ single passes.
- [x] Lookups utilize Set<Id>.contains() for (1)$ constant-time membership checks.
- [x] Page initialization uses a consolidated composite DTO to cut round-trips.
