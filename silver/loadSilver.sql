Create or Alter procedure silver.load_silver as
Begin
	Truncate Table silver.CdNow
	;with base as(
			Select 
		index_id,
		customer_id,
		date,
		quantity,
		price,
		DATEDIFF(MONTH,min(date)over(partition by customer_id),max(date) over(partition by customer_id)) as duration,
		DATEDIFF(MONTH,Max(date)over(partition by customer_id),max(date) over()) as inactivity
		from bronze.cdNow
	)
	Insert into silver.CdNow(
		index_id,
		customer_id,
		date,
		quantity,
		price,
		duration,
		inactivity,
		event
	) 
	 SELECT
			index_id,
			customer_id,
			date,
			quantity,
			price,
			duration,
			inactivity,
			CASE
				WHEN inactivity>=06 then '1'
				ELSE '0'
			END AS event
		FROM base
end
go

exec silver.load_silver

exec bronze.load_bronze
select * from silver.CdNow
select * from bronze.CdNow