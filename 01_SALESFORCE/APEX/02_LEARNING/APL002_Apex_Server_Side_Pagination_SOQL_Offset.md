# #APL002: Apex Server-Side Pagination: SOQL OFFSET, Dynamic Filtering & DTO Pagination Patterns

- **PINCODE:** #APL002
- **Topic:** Apex Server-Side Pagination, SOQL LIMIT & OFFSET, and Reactive LWC Integration
- **Domain:** Apex / SOQL / High-Volume Data Architecture / Enterprise Design Patterns
- **Created Date:** 2026-08-24
- **Status:** Active
- **Related:** #APL001, #LWL002, #APC001

---

## 🎯 1. Executive Summary

When querying large Salesforce datasets ( > 100$ records up to ,000$ rows), client-side in-memory slicing can cause browser memory bloat and cold-start latency. 

**Server-Side Pagination** delegates the pagination math to the database using SOQL LIMIT and OFFSET, retrieving only the active slice of data per request while returning structured metadata (	otalRecords, 	otalPages, ecords) via a composite **Data Transfer Object (DTO)**.

---

## 🏗️ 2. The Pagination Architecture & Math

`
[ LWC UI ] ──── Sends { pageNumber: 2, pageSize: 5, instructor: 'Ross' } ────► [ Apex Controller ]
                                                                                       │
[ LWC UI ] ◄─── Returns { totalRecords: 25, totalPages: 5, records: [5] } ◄─────────┘
`

### The OFFSET Formula
\text{offset} = (\text{pageNumber} - 1) \times \text{pageSize}

| Page Number | pageSize | offset | Records Returned from Database |
| :--- | :--- | :--- | :--- |
| **Page 1** | 5 | 0 \times 5 = 0$ | Rows 1 to 5 |
| **Page 2** | 5 | 1 \times 5 = 5$ | Rows 6 to 10 |
| **Page 3** | 5 | 2 \times 5 = 10$ | Rows 11 to 15 |

---

## 💻 3. Reference Apex Implementation

### Step 1: The Pagination DTO Wrapper
`pex
public class PaginatedResult {
    @AuraEnabled public Integer totalRecords { get; set; }
    @AuraEnabled public Integer totalPages   { get; set; }
    @AuraEnabled public Integer pageNumber   { get; set; }
    @AuraEnabled public Integer pageSize     { get; set; }
    @AuraEnabled public List<SObject> records { get; set; }
}
`

### Step 2: The Apex Controller Method
`pex
public without sharing class CourseController {

    @AuraEnabled(cacheable=true)
    public static PaginatedResult getPaginatedOfferings(
        Id courseId, 
        String instructorName, 
        Integer pageNumber, 
        Integer pageSize
    ) {
        try {
            if (courseId == null) return null;

            // 1. Guard against null or invalid bounds
            if (pageNumber == null || pageNumber < 1) pageNumber = 1;
            if (pageSize == null || pageSize < 1) pageSize = 5;

            PaginatedResult result = new PaginatedResult();
            result.pageNumber = pageNumber;
            result.pageSize = pageSize;

            // 2. Build Dynamic WHERE Filter
            String whereClause = 'WHERE LearningCourseId = :courseId ';
            if (String.isNotBlank(instructorName) && instructorName != 'ALL') {
                whereClause += 'AND PrimaryFaculty.Name = :instructorName ';
            }

            // 3. Count Total Records Matching Filter
            String countQuery = 'SELECT count() FROM CourseOffering ' + whereClause;
            result.totalRecords = Database.countQuery(countQuery);
            result.totalPages = (Integer)Math.ceil((Decimal)result.totalRecords / pageSize);

            // 4. Calculate Offset
            Integer offset = (pageNumber - 1) * pageSize;

            // 5. Query Specific Slice with LIMIT & OFFSET
            String dataQuery = 'SELECT Id, Name, Description, AvailabilityStatus, ' +
                               '       PrimaryFaculty.Name, PrimaryFaculty.Title ' +
                               'FROM CourseOffering ' + 
                               whereClause + 
                               'ORDER BY Name ASC ' + 
                               'LIMIT :pageSize OFFSET :offset';

            result.records = Database.query(dataQuery);

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error loading offerings: ' + e.getMessage());
        }
    }
}
`

---

## ⚡ 4. Client-Side Reactive Integration (LWC)

Because @wire is **reactive**, binding parameters with $ automatically triggers a re-query whenever currentPage or selectedInstructor changes:

`javascript
import { LightningElement, api, wire } from 'lwc';
import getPaginatedOfferings from '@salesforce/apex/CourseController.getPaginatedOfferings';

export default class CourseOfferings extends LightningElement {
    @api recordId;
    selectedInstructor = 'ALL';
    currentPage = 1;
    pageSize = 5;

    @wire(getPaginatedOfferings, {
        courseId: '',
        instructorName: '',
        pageNumber: '',
        pageSize: ''
    })
    wiredResult({ error, data }) {
        if (data) {
            this.offerings = data.records;
            this.totalPages = data.totalPages;
            this.totalRecords = data.totalRecords;
        }
    }

    handleNext() { if (this.currentPage < this.totalPages) this.currentPage++; }
    handlePrevious() { if (this.currentPage > 1) this.currentPage--; }
    handleFilterChange(event) {
        this.selectedInstructor = event.detail.value;
        this.currentPage = 1; // Always reset to page 1 on filter modification
    }
}
`

---

## ⚠️ 5. Salesforce Governor Limits & Scalability Notes

1. **SOQL OFFSET Maximum Limit = 2,000 Rows**:
   - Salesforce enforces a strict maximum OFFSET of **2,000**.
   - If querying $> 2,000$ records, transition to **Keyset / Cursor Pagination** (WHERE CreatedDate < :lastSeenTimestamp or WHERE Id > :lastSeenId ORDER BY Id ASC LIMIT :pageSize).
2. **Indexing Requirements**:
   - Always include indexed fields in ORDER BY (e.g. Id, CreatedDate, or Indexed Custom External IDs) when using OFFSET to prevent slow table scans.
3. **Database.countQuery() Efficiency**:
   - Always run the countQuery before the data query to dynamically compute 	otalPages without retrieving sObject records.
