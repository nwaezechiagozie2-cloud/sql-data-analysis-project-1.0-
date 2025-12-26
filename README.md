# SQL Data Analysis & Strategy: Retail Business Audit

## Project Overview
This project is a comprehensive strategic audit of a $29M retail dataset. The goal was to identify "Profit Leaks" and "Retention Opportunities" to increase the company's net profit margin.

The analysis follows a logical progression: **High-Level Health Check -> Root Cause Deep Dives -> Strategy Formulation -> Operationalization.**

---

## Project Structure & Workflow

### Phase 1: Foundation & Initial Audit
1.  **`00_init_database.sql`**: Database schema setup and data ingestion.
2.  **`business_analysis.sql`**: The "Pulse Check." Identified the margin gap between Accessories (63%) and Bikes (39%) and flagged a high customer churn rate.
    *   *Next Step:* Deep dive into why margins are low in `business_deep_dive.sql`.

### Phase 2: Profitability Deep Dives
3.  **`business_deep_dive.sql`**: Root cause analysis. Discovered the "Jersey Trap" (23% margin) and the "Australia Anomaly" (Failure to cross-sell accessories in our #1 bike market).
    *   *Next Step:* Analyze if these low-margin customers are at least loyal in `customer_segmentation_rfm.sql`.

### Phase 3: Customer Retention & Loyalty
4.  **`customer_segmentation_rfm.sql`**: Advanced segmentation. Discovered that 53% of revenue ($15.6M) relies on a small group of "Whales."
5.  **`retention_proof.sql`**: Validated that Repeat Buyers have a 100% retention rate, making them the most valuable asset to protect.
6.  **`verify_accessory_behavior.sql`**: **The Strategic Pivot.** Disproved the theory that accessories drive loyalty; proved that **Bike Buyers** are 45% more likely to be repeat customers.
    *   *Next Step:* Track long-term trends using Cohort Analysis in `official_cohort_retention.sql`.

### Phase 4: Senior Analytics & Trends
7.  **`official_cohort_retention.sql`**: Year-over-year cohort matrix. Uncovered a massive **550% performance spike in 2013** driven by a 90% reactivation rate of dormant customers.

### Phase 5: Operationalization & Strategy
8.  **`02_operational_views.sql`**: The "Gold Layer." Permanent SQL views designed to power BI dashboards for Sales, Marketing, and Finance teams.
9.  **`executive_summary.md`**: The final deliverable for the CEO. Translates all technical findings into a 3-point recovery plan targeting a 12-15% profit increase.

---

## Key Business Insights
*   **The Whale Dependency:** 53% of revenue is tied to just 3,600 customers.
*   **The Australia Gap:** $8.8M in bike sales with only 1.5% accessory attachment—a massive missed opportunity for high-margin profit.
*   **The Loyalty Anchor:** Bikes, not accessories, are the primary driver of long-term customer retention (55% repeat rate).
