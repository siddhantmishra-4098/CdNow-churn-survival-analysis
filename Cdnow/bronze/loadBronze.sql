Create or alter procedure bronze.load_bronze as
begin
	Truncate table bronze.cdNow;
	Bulk insert bronze.cdNow
	from "D:\Cdnow\cdnow.csv\cdnow.csv"
	with(
	first_row = 2,
	Fieldterminator = ',',
	rowterminator = '0x0a',
	TABLOCK
	);
END

exec bronze.load_bronze
