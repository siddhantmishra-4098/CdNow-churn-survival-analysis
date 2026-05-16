Create or Alter procedure gold.load_gold as
Begin
Truncate Table gold.cdnow
Insert into gold.cdnow(
customer_id,
duration,
event,
total_spent,
total_orders
)
select 
    customer_id,
    MAX(duration)       AS duration,
    MAX(CAST(event AS INT)) AS event,
    SUM(quantity * price)   AS total_spent,
    COUNT(*)                AS total_orders
from silver.CdNow
GROUP BY customer_id;
END
go