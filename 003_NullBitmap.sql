/*
Object: T-SQL Script
Author: Hemantgiri Goswami
Script Date: 2nd March 2020
Description: This is a Demo Script to understand how Null Bitmap is calculated. And, if this is not considered at the time of estimates
we may end up having incorrect size storage configuration
This script is part of my blog series and presentation Common Mistakes in SQL Server.

*/

create database DustBin
GO
use DustBin
go
create table TblEmployee
(
Id	int identity(1,1) not null,
FirstName	char(15),
LastName	char(15),
EmpId		int,
Add1		char(25),
Add2		char(25),
City		char(10),
Country		char(10),
BlodGroup	char(3),
HomeNum		int,
CellNum		int,
email		char(35),
website		char(35)
)
go
insert into TblEmployee
values(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
--values ('Hemantgiri','Goswami',1,'Saiyed Para Tunki','Varis Takero','Surat','India','B',1234,0987,'someone@somedomain.com','http://www.somedomain.com')
go 150000
sp_spaceused 'tblEmployee'
go

drop table TblEmployee
go

create table TestDataType
(
cFname		char(255),
vLname		varchar(255),
ncAddress	nchar(255),
nvCity		nvarchar(255)
)
go
-- Inserting record 
insert into TestDataType values ('Hemantgiri','Goswami','Saiyed Para Tunki','Surat')
go
-- Lenght of the data entered (in Bytes)
select len('Hemantgiri')+len('Goswami')+len('Saiyed Para Tunki')+LEN('Surat')
go
-- Length of the data stored in the table (in Bytes)
select 255+LEN('Goswami')+(255*2)+(LEN('Surat')*2)
go

print 'Space occupy to store 25,00,000 records (in MB)'
print (((255+LEN('Goswami')+(255*2)+(LEN('Surat')*2))*2500000) /1024) /1024





drop table TestDataType
go
use master
go
drop database DustBin
go