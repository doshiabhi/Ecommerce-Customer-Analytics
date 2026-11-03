/* ============================================================
   Project : E-commerce Customer Analytics
   File    : advanced_customer_analysis.sql
   Dialect : PostgreSQL (works in most engines with minor edits)
   Goal    : Segment customers with RFM scoring, track monthly
             revenue growth, and measure cohort retention.

    tables:
     customers(customer_id, signup_date, country)
     orders(order_id, customer_id, order_date, status)
     order_items(order_id, product_id, quantity, unit_price)
   ============================================================ */

WITH valid_orders AS (
    -- 1. Revenue per order, excluding cancelled/returned orders
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date::date AS order_date,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled', 'returned')
    GROUP BY o.order_id, o.customer_id, o.order_date
),

customer_metrics AS (
    -- 2. Recency, Frequency, Monetary values per customer
    SELECT
        customer_id,
        MAX(order_date)                             AS last_order_date,
        CURRENT_DATE - MAX(order_date)              AS recency_days,
        COUNT(DISTINCT order_id)                    AS frequency,
        ROUND(SUM(order_revenue)::numeric, 2)       AS monetary
    FROM valid_orders
    GROUP BY customer_id
),

rfm_scores AS (
    -- 3. Score each metric 1-5 using quintiles (5 = best)
    SELECT
        cm.*,
        NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM customer_metrics cm
),

rfm_segments AS (
    -- 4. Translate scores into business-friendly segments
    SELECT
        r.*,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2                  THEN 'New / Promising'
            WHEN r_score <= 2 AND f_score >= 4                  THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost'
            ELSE 'Needs Attention'
        END AS segment
    FROM rfm_scores r
),

monthly_revenue AS (
    -- 5. Monthly revenue with month-over-month growth
    SELECT
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(order_revenue)                    AS revenue,
        LAG(SUM(order_revenue)) OVER (
            ORDER BY DATE_TRUNC('month', order_date)
        )                                     AS prev_month_revenue
    FROM valid_orders
    GROUP BY DATE_TRUNC('month', order_date)
),

cohorts AS (
    -- 6. Assign each customer to their first-order month
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::date AS cohort_month
    FROM valid_orders
    GROUP BY customer_id
),

cohort_activity AS (
    -- 7. Months elapsed since first order, per active customer
    SELECT
        c.cohort_month,
        (EXTRACT(YEAR  FROM AGE(DATE_TRUNC('month', v.order_date), c.cohort_month)) * 12
       + EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', v.order_date), c.cohort_month)))::int
            AS months_since_first,
        COUNT(DISTINCT v.customer_id) AS active_customers
    FROM valid_orders v
    JOIN cohorts c ON c.customer_id = v.customer_id
    GROUP BY c.cohort_month, months_since_first
),

cohort_retention AS (
    -- 8. Retention rate relative to cohort size (month 0)
    SELECT
        cohort_month,
        months_since_first,
        active_customers,
        ROUND(
            100.0 * active_customers
            / FIRST_VALUE(active_customers) OVER (
                PARTITION BY cohort_month ORDER BY months_since_first
            ), 1
        ) AS retention_pct
    FROM cohort_activity
)

-- Final output: segment summary combined with overall revenue share
SELECT
    s.segment,
    COUNT(*)                                           AS customers,
    ROUND(AVG(s.monetary), 2)                          AS avg_lifetime_value,
    ROUND(AVG(s.frequency), 1)                         AS avg_orders,
    ROUND(AVG(s.recency_days), 0)                      AS avg_days_since_last_order,
    ROUND(100.0 * SUM(s.monetary)
          / SUM(SUM(s.monetary)) OVER (), 1)           AS pct_of_total_revenue,
    RANK() OVER (ORDER BY SUM(s.monetary) DESC)        AS revenue_rank
FROM rfm_segments s
GROUP BY s.segment
ORDER BY revenue_rank;
