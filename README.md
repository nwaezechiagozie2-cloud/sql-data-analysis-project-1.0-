# SQL Data Analysis & Strategy: Retail Business Audit

## Project Overview
This project is a comprehensive strategic audit of a $29M retail dataset. The goal was to identify "Profit Leaks" and "Retention Opportunities" to increase the company's net profit margin.

The analysis follows a logical progression: **High-Level Health Check -> Root Cause Deep Dives -> Strategy Formulation -> Operationalization.**

---

## Project Structure & Workflow

### Phase 1: Foundation & Initial Audit
1.  **`00_init_database.sql`**: Database schema setup and data ingestion.
2.  **`business_analysis.sql`**: The "Pulse Check." Identified the margin gap between Accessories (63%) and Bikes (39%) and flagged a high customer churn rate.

### Phase 2: Profitability & Regional Deep Dives
3.  **`business_deep_dive.sql`**: Root cause analysis. Discovered the "Jersey Trap" (23% margin).
4.  **`regional_deep_dive.sql`**: **The Canada Secret.** Proved that Canada's high profit comes from a 5.2% accessory attachment rate, compared to Australia's 1.5%.

### Phase 3: Customer Retention & Loyalty
5.  **`customer_segmentation_rfm.sql`**: Advanced segmentation. Discovered that 53% of revenue ($15.6M) relies on a small group of "Whales."
6.  **`verify_accessory_behavior.sql`**: **The Strategic Pivot.** Disproved the theory that accessories drive loyalty; proved that **Bike Buyers** are the true loyalty anchor.
7.  **`correlation_analysis.sql`**: **The 80% Gap.** Discovered that 8 out of 10 bike buyers globally leave the store without a helmet.

### Phase 4: Senior Analytics & Trends
8.  **`official_cohort_retention.sql`**: Year-over-year cohort matrix. Uncovered a massive **550% performance spike in 2013** driven by a 90% reactivation rate of dormant customers.

### Phase 5: Operationalization & Strategy
9.  **`02_operational_views.sql`**: The "Gold Layer." Permanent SQL views designed to power BI dashboards for Sales, Marketing, and Finance teams.
10. **`executive_summary.md`**: The final deliverable for the CEO. Translates all technical findings into a professional recovery plan.

---

## Key Business Insights
*   **The Whale Dependency:** 53% of revenue is tied to just 3,600 customers.
*   **The Australia Gap:** $8.8M in bike sales with only 1.5% accessory attachment—a massive missed opportunity for high-margin profit.
*   **The Loyalty Anchor:** Bikes, not accessories, are the primary driver of long-term customer retention (55% repeat rate).
*   **The 2013 Blueprint:** Proved that a 90% reactivation rate of old customers is possible, providing a roadmap for current "At-Risk" revenue.
