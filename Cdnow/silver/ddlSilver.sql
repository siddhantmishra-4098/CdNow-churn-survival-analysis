If not exists (select * from sys.schemas where name = 'silver')
Begin
	exec('CREATE SCHEMA silver')
end
if OBJECT_ID('silver.CdNow') is not NULL 
DROP Table silver.CdNow
go

CREATE TABLE silver.CdNow(
	index_id int,
	customer_id int,
	date date,
	quantity int,
	price float,
	duration int,
	inactivity int,
	event int,	
)

