/*
Object: T-SQL Script
Author: Hemantgiri Goswami
Script Date: 2nd March 2020
Description: This is a Demo Script to understand why to choose Data Types wisely.
This script is part of my blog series and presentation Common Mistakes in SQL Server.

*/

EXECUTE 
(
    'CREATE DATABASE dDataTypes
        ON 
        ( NAME = Sales_dat,
            FILENAME = ''C:\SQLDATA\DEMODBS\dDataTypes_data.mdf'',
            SIZE = 10,
            MAXSIZE = 50,
            FILEGROWTH = 5MB 
        )
        LOG ON
        ( NAME = Sales_log,
            FILENAME = ''C:\SQLDATA\DEMODBS\dDataTypes_log.ldf'',
            SIZE = 5MB,
            MAXSIZE = 25MB,
            FILEGROWTH = 5MB 
        )'
);
GO

use dDataTypes
go

-- Let's create a table with two column. Both uses variable length data type. 
-- However, one uses UTF-8 and other uses UTF-16 (Unicode) data type.
create table TblTestDataType
(
FirstName	varchar(12),
LastName	nvarchar(12)
)


-- Now, let's insert 4 records here
insert into TblTestDataType values ('Hemantgiri', 'Goswami')
go
insert into TblTestDataType values ('Brijalkumar','Patel')
go
insert into TblTestDataType values ('Jagatrey','Patel')
go
insert into TblTestDataType values ('Manish','Jariwala')
go


-- checking the length and size of records the column FirstName(varchar(12))
select 'checking the length and size of records the column FirstName(varchar(12))'
select FirstName,LEN(FirstName) as '#ofCharacters',DataLength(FirstName) as 'SizeOccupied' from TblTestDataType 


-- checking the length and size of records the column LastName(nvarchar(12))
select 'checking the length and size of records the column LastName(nvarchar(12))'
-- checking the length of the characters 
select LastName,LEN(LastName) as '#ofCharacters',DataLength(LastName) as 'SizeOccupied' from TblTestDataType 
go


use master 
go
drop database dDataTypes
go