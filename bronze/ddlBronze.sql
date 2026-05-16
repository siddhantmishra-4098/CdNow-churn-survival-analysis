use CdNow

if not exists (select * from sys.schemas where name = 'bronze')
begin
	exec('CREATE SCHEMA bronze')
END
GO

if OBJECT_ID('bronze.cdNow','U') is Not Null
	DROP TABLE bronze.cdNow
Create Table bronze.cdNow(
	index_id Int,
	customer_id int,
	date date,
	quantity int,
	price float
);
go