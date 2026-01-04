# Dashboard Strategy: Turning Insights into Action

Based on our analysis, we should build **three distinct dashboards**, each serving a different stakeholder and answering a specific set of questions.

## 1. The Executive Command Center (For the CEO/CFO)
**Goal:** High-level health check of the business.
*   **Key Metrics:**
    *   Total Revenue & Net Profit Margin (The "39% vs 63%" Gap).
    *   Global Accessory Attachment Rate (The "80% Helmet Gap").
    *   Revenue at Risk (The $3.4M "Hibernating" Segment).
*   **Visuals:**
    *   **Map:** Sales by Country (Highlighting Australia's low attachment).
    *   **Trend:** Monthly Revenue vs. Profit Margin.
    *   **Donut Chart:** Revenue by Customer Segment (Champions vs. Others).

## 2. The Customer Loyalty Dashboard (For Marketing)
**Goal:** Monitor retention and reactivate dormant customers.
**Source:** `view_dashboard_customers` (The view we created).
*   **Key Metrics:**
    *   Repeat Customer Rate (Global vs. Regional).
    *   Reactivation Rate (Tracking the "2013 Blueprint").
    *   Average Days Since Last Purchase.
*   **Visuals:**
    *   **Cohort Matrix:** Retention rates by join year (The "Heatmap").
    *   **Bar Chart:** Customer Count by RFM Segment.
    *   **List:** Top 100 "At Risk" Champions (Actionable list for email campaigns).

## 3. The Product Performance Dashboard (For Sales/Inventory)
**Goal:** Optimize product mix and attachment.
**Source:** `view_dashboard_sales`.
*   **Key Metrics:**
    *   Attachment Rate by Bike Category (Mountain vs. Road).
    *   Average Order Value (AOV).
    *   Top 10 High-Margin Accessories.
*   **Visuals:**
    *   **Scatter Plot:** Product Volume vs. Profit Margin (Identify "Jersey Traps").
    *   **Bar Chart:** "Naked Bike" Rate by Store/Region.
    *   **Table:** Inventory levels of "Universal Essentials" (Helmets/Tubes).

---

## Implementation Guide
*   **Data Source:** Connect your BI tool (Tableau/PowerBI) directly to the `DataWarehouseAnalytics` database.
*   **Tables to Use:**
    *   Use `view_dashboard_sales` for Dashboards 1 & 3.
    *   Use `view_dashboard_customers` for Dashboard 2.
