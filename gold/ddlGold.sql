If not exists (select * from sys.schemas where name = 'gold')
Begin
	exec('CREATE SCHEMA GOLD')
end
go

if Object_id('gold.cdnow') is not NULL
drop table gold.cdnow
go

CREATE  TABLE gold.cdnow(
customer_id int,
duration int,
event int,
total_spent float,
total_orders int
)