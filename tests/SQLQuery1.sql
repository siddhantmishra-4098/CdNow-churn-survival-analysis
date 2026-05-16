with base as (
	select
	DATEDIFF (month,min(date) over(partition by customer_id),max(date) over(partition by customer_id)) as durations
	from bronze.cdNow
	)

select * from base 
where durations<6