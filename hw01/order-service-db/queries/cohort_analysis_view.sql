-- Описание:
--   Аналогично `cohort_analysis.sql` только с созданием VIEW
--
-- Использование:
--   psql "postgresql://postgres:postgres@localhost:5433/postgres" -f <PATH_TO>/cohort_analysis_view.sql


DROP VIEW IF EXISTS cohort_analysis_view;

-- Создаем VIEW на основе логики когортного анализа
CREATE VIEW cohort_analysis_view AS
WITH 
-- 1.1: Определяем месяц первой покупки для каждого клиента
first_purchase AS (
    SELECT 
        user_external_id,
        DATE_TRUNC('month', MIN(order_date))::DATE as cohort_month,
        MIN(order_date) as first_order_date
    FROM ORDERS
    WHERE order_date IS NOT NULL
    GROUP BY user_external_id
),

-- 1.2: Считаем размер каждой когорты
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_external_id) as cohort_size
    FROM first_purchase
    GROUP BY cohort_month
),

-- 2.0: Определяем активность клиентов по периодам
user_activity AS (
    SELECT 
        o.user_external_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_date)::DATE as order_month,
        
        EXTRACT(YEAR FROM AGE(o.order_date, fp.first_order_date))::INTEGER * 12 +
        EXTRACT(MONTH FROM AGE(o.order_date, fp.first_order_date))::INTEGER as period_number,
        o.total_amount
    FROM ORDERS o
    INNER JOIN first_purchase fp ON o.user_external_id = fp.user_external_id
    WHERE o.order_date >= fp.first_order_date
        AND o.order_date IS NOT NULL
        AND o.total_amount IS NOT NULL
),

-- 2.1 и 3.1: Считаем активных клиентов и выручку по периодам
cohort_activity AS (
    SELECT 
        cohort_month,
        period_number,
        COUNT(DISTINCT user_external_id) as active_users,
        SUM(total_amount) as period_revenue
    FROM user_activity
    WHERE period_number BETWEEN 0 AND 5
    GROUP BY cohort_month, period_number
),

-- Агрегируем выручку по когортам
cohort_revenue AS (
    SELECT 
        cohort_month,
        SUM(period_revenue) as total_cohort_revenue
    FROM cohort_activity
    GROUP BY cohort_month
)

-- Формируем итоговую таблицу
SELECT 
    cs.cohort_month,
    cs.cohort_size,
    
    -- 2.2: Retention Rate по периодам (процент от размера когорты)
    COALESCE(ROUND(100.0 * MAX(CASE WHEN ca.period_number = 0 THEN ca.active_users END) / cs.cohort_size, 2), 0) as period_0_pct,
    COALESCE(ROUND(100.0 * MAX(CASE WHEN ca.period_number = 1 THEN ca.active_users END) / cs.cohort_size, 2), 0) as period_1_pct,
    COALESCE(ROUND(100.0 * MAX(CASE WHEN ca.period_number = 2 THEN ca.active_users END) / cs.cohort_size, 2), 0) as period_2_pct,
    COALESCE(ROUND(100.0 * MAX(CASE WHEN ca.period_number = 3 THEN ca.active_users END) / cs.cohort_size, 2), 0) as period_3_pct,
    COALESCE(ROUND(100.0 * MAX(CASE WHEN ca.period_number = 4 THEN ca.active_users END) / cs.cohort_size, 2), 0) as period_4_pct,
    COALESCE(ROUND(100.0 * MAX(CASE WHEN ca.period_number = 5 THEN ca.active_users END) / cs.cohort_size, 2), 0) as period_5_pct,
    
    -- 3.1 и 3.2: Метрики выручки
    COALESCE(cr.total_cohort_revenue, 0) as total_cohort_revenue,
    COALESCE(ROUND(cr.total_cohort_revenue / cs.cohort_size, 2), 0) as avg_revenue_per_customer

FROM cohort_sizes cs
LEFT JOIN cohort_activity ca ON cs.cohort_month = ca.cohort_month
LEFT JOIN cohort_revenue cr ON cs.cohort_month = cr.cohort_month
GROUP BY cs.cohort_month, cs.cohort_size, cr.total_cohort_revenue
ORDER BY cs.cohort_month;

COMMENT ON VIEW cohort_analysis_view IS 'Когортный анализ клиентов: retention rate и метрики выручки по месяцам первой покупки';