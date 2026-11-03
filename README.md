# E-commerce Customer Analytics | SQL Project

An advanced SQL project using PostgreSQL to analyze e-commerce customer behavior through RFM segmentation, monthly revenue growth, and cohort retention analysis.

## Project Overview

This project demonstrates how SQL can transform transactional e-commerce data into meaningful business insights.

It focuses on three key analytical areas:

1. **RFM Customer Segmentation** – Identify valuable, loyal, new, at-risk, and lost customers.
2. **Monthly Revenue Analysis** – Track revenue trends and calculate month-over-month growth.
3. **Cohort Retention Analysis** – Understand customer retention based on their first purchase month.

## SQL Concepts & Techniques

- Common Table Expressions (CTEs)
- Multi-table JOINs
- Aggregate Functions
- Window Functions (`NTILE`, `LAG`, `FIRST_VALUE`, `RANK`)
- Conditional Logic (`CASE WHEN`)
- Date and Time Functions
- Customer Segmentation
- Revenue and Retention Calculations

## 1. RFM Customer Segmentation

RFM analysis evaluates customers based on three dimensions:

| Metric | Description | Business Interpretation |
|---|---|---|
| Recency | Days since last purchase | How recently did the customer buy? |
| Frequency | Number of orders | How often does the customer buy? |
| Monetary | Total customer revenue | How much does the customer spend? |

Each metric receives a score between 1 and 5 using the `NTILE(5)` window function.

### Customer Segments

| Segment | Description |
|---|---|
| Champions | Recent, frequent, high-value customers |
| Loyal Customers | Customers with consistent purchasing behavior |
| New / Promising | Recently active customers with lower purchase frequency |
| At Risk | Previously frequent customers who haven't purchased recently |
| Lost | Customers with low recency and frequency scores |
| Needs Attention | Customers who do not fit other segment definitions |

The final output summarizes each segment using:

- Number of customers
- Average lifetime value
- Average number of orders
- Average days since last order
- Percentage contribution to total revenue
- Revenue ranking

## 2. Monthly Revenue Growth Analysis

Analyze monthly revenue trends and calculate month-over-month (MoM) growth using the `LAG()` window function.

**Key Metrics:**
- Monthly Revenue
- Previous Month Revenue
- Month-over-Month Growth (%)

This analysis helps identify revenue trends and changes in business performance over time.

## 3. Cohort Retention Analysis

Cohort analysis groups customers based on their first purchase month and tracks their purchasing activity over subsequent months.

**Key Metrics:**
- Cohort Month
- Months Since First Purchase
- Active Customers
- Customer Retention (%)

Retention is calculated relative to the active customer count in the cohort's first purchase month.

## Database Schema

The analysis assumes three relational tables:

**1. customers**
- customer_id
- signup_date
- country

**2. orders**
- order_id
- customer_id
- order_date
- status

**3. order_items**
- order_id
- product_id
- quantity
- unit_price

Cancelled and returned orders are excluded from revenue calculations.

## SQL Implementation

The complete SQL implementation is available in:

[`sql/advanced_customer_analysis.sql`](advanced_customer_analysis.sql)

The script includes:

- Valid order identification and revenue calculation
- Customer-level RFM metrics
- Quintile-based RFM scoring
- Customer segment classification
- Monthly revenue and growth calculation
- Cohort assignment
- Cohort retention calculation
- Final customer segment summary

It also includes two additional queries for monthly revenue growth and cohort retention analysis.

## Business Applications

This analysis can help e-commerce businesses:

- Identify and retain high-value customers.
- Develop targeted marketing campaigns for different customer segments.
- Re-engage customers who are at risk of becoming inactive.
- Monitor monthly revenue performance.
- Understand repeat purchasing behavior.
- Evaluate long-term customer retention.



**Note:** The SQL script assumes the database tables and data already exist. It does not include table creation or sample data.

---

*This project demonstrates advanced SQL capabilities for customer analytics, revenue intelligence, and data-driven business decision-making.*
