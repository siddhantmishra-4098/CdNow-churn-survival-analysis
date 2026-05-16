SELECT 
    event,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct
FROM (
    SELECT customer_id, MAX(CAST(event AS INT)) AS event
    FROM silver.CdNow
    GROUP BY customer_id
) AS customer_level
GROUP BY event;--data set is imbalanced