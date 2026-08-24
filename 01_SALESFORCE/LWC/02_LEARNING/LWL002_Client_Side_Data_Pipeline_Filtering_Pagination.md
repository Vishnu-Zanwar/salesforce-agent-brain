# #LWL002: Client-Side Reactive Data Pipeline: Filtering, Slicing & Pagination Pattern in LWC

- **PINCODE:** #LWL002
- **Topic:** Lightning Web Components (LWC) — In-Memory Reactive Data Pipeline
- **Domain:** LWC / JavaScript Architecture / UI-UX Patterns
- **Created Date:** 2026-08-24
- **Status:** Active
- **Related:** #LWE001, #LWL001

---

## 🎯 1. Executive Summary

When dealing with moderate client-side datasets (5 to 100 sObject records) returned by Apex @wire, fetching all records once and managing **dynamic filtering, picklist generation, and pagination entirely in JavaScript** provides zero-latency UI interactions without consuming extra Salesforce API limits or server round-trips.

This document outlines the standard 5-stage reactive data pipeline pattern for Salesforce LWC.

---

## 🏗️ 2. The 5-Stage Data Pipeline Architecture

`
[ Stage 1: Apex @wire ] 
          │ (Raw sObjects from Database)
[ Stage 2: Normalization Getter (coursedetails) ] 
          │ (Extracts nested lookup fields, sets UI flags)
[ Stage 3: Picklist Options Builder (instructorOptions) ] 
          │ (Builds dynamic label/value array with counts using Set)
[ Stage 4: Filtering Getter (ilteredOfferings) ] 
          │ (Applies active filter criteria: 'ALL' or specific value)
[ Stage 5: Pagination Slicing Getter (displayedOfferings) ] 
          │ (Slices [(currentPage - 1) * pageSize, startIndex + pageSize])
[ Stage 6: HTML Template UI Rendering ]
`

---

## ⚠️ 3. Critical Architectural Rules

### Rule A: Filtering MUST Precede Pagination Slicing
* **Anti-Pattern (Slice First, Filter Second):** Slicing page 1 (items 1-2) and then filtering by Instructor X results in **0 items displayed** if Instructor X's records are physically on page 2 or 3 of the raw array.
* **Best Practice (Filter First, Slice Second):** Slicing only from 	his.filteredOfferings guarantees Page 1 always displays the filtered results immediately.

### Rule B: Reset Page Index on Criteria Change
* Whenever the user modifies a filter (e.g. handleInstructorChange), **always reset 	his.currentPage = 1**.
* If a user is on Page 4 of All Instructors and switches to an instructor with only 1 offering, staying on Page 4 causes an out-of-bounds blank page.

### Rule C: Clamping Bounds with Math.min()
* For user-facing counter labels (e.g. Showing 5–5 of 5 offerings), calculate endIndex as:
  `javascript
  const end = Math.min(this.currentPage * this.pageSize, totalRecords);
  `
  This prevents displaying invalid ranges like Showing 5–6 of 5.

---

## 💻 4. Reference Code Implementation

### JavaScript (component.js):
`javascript
import { LightningElement, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/CourseController.getCourseOfferings';

export default class CourseOfferings extends LightningElement {
    @api recordId;

    // State Variables
    selectedInstructor = 'ALL';
    pageSize = 3;
    currentPage = 1;

    @wire(getRecords, { recordId: '' })
    rawDataWire;

    // Stage 1: Data Normalization
    get coursedetails() {
        const raw = this.rawDataWire?.data || [];
        return raw.map(item => ({
            ...item,
            facultyName: item.PrimaryFaculty ? item.PrimaryFaculty.Name : 'Staff'
        }));
    }

    // Stage 2: Dynamic Combobox Options with Set & Counts
    get instructorOptions() {
        const data = this.coursedetails || [];
        const unique = new Set();
        data.forEach(c => { if (c.facultyName) unique.add(c.facultyName); });

        const options = [{ label: All Instructors (), value: 'ALL' }];
        unique.forEach(name => {
            const count = data.filter(c => c.facultyName === name).length;
            options.push({ label: ${name} (), value: name });
        });
        return options;
    }

    get showInstructorFilter() {
        return this.instructorOptions.length > 2; // Only show if >= 2 distinct instructors
    }

    // Stage 3: Criteria Filtering
    get filteredOfferings() {
        if (!this.selectedInstructor || this.selectedInstructor === 'ALL') {
            return this.coursedetails || [];
        }
        return (this.coursedetails || []).filter(c => c.facultyName === this.selectedInstructor);
    }

    // Stage 4: Pagination Slicing
    get totalPages() {
        return Math.ceil(this.filteredOfferings.length / this.pageSize) || 1;
    }

    get displayedOfferings() {
        const start = (this.currentPage - 1) * this.pageSize;
        return (this.filteredOfferings || []).slice(start, start + this.pageSize);
    }

    get isFirstPage() { return this.currentPage <= 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }
    get showPagination() { return this.filteredOfferings.length > this.pageSize; }

    get recordRangeLabel() {
        const total = this.filteredOfferings.length;
        const start = (this.currentPage - 1) * this.pageSize + 1;
        const end = Math.min(this.currentPage * this.pageSize, total);
        return Showing – of  offerings;
    }

    get pageNumbers() {
        const pages = [];
        for (let i = 1; i <= this.totalPages; i++) {
            pages.push({
                number: i,
                btnClass: i === this.currentPage ? 'page-btn page-btn--active' : 'page-btn'
            });
        }
        return pages;
    }

    // Event Handlers
    handleInstructorChange(event) {
        this.selectedInstructor = event.detail.value;
        this.currentPage = 1;
    }

    handlePrevious() { if (this.currentPage > 1) this.currentPage--; }
    handleNext() { if (this.currentPage < this.totalPages) this.currentPage++; }
    handlePageClick(event) {
        const page = parseInt(event.target.dataset.page, 10);
        if (page && page !== this.currentPage) this.currentPage = page;
    }
}
`

---

## 🔍 5. Verification & Testing Checklist
- [x] Combobox correctly displays counts next to each instructor name.
- [x] Selecting an instructor recalculates total pages and resets active page to 1.
- [x] Pagination previous/next buttons disable correctly at boundaries.
- [x] Numbered page pills reflect active selection state.
- [x] Filter automatically hides if total distinct instructors <= 1.
