/*
Author - Hemantgiri S. Goswami
Site: https://sqlservercitation.com 
Twitter: https://twitter.com/hemantgirig
Object: T-SQL Script

Script Date: 2nd March 2020
Description: This is a Demo Script to understand why to Avoid using Identity column and in which use cases.
This script is part of my blog series and presentation Common Mistakes in SQL Server.
An example of auto incremental value for primary key
*/
EXECUTE 
(
    'CREATE DATABASE dIdentityDB
        ON 
        ( NAME = Sales_dat,
            FILENAME = ''C:\SQLDATA\DEMODBS\dIdentityDB_data.mdf'',
            SIZE = 10,
            MAXSIZE = 50,
            FILEGROWTH = 5MB 
        )
        LOG ON
        ( NAME = Sales_log,
            FILENAME = ''C:\SQLDATA\DEMODBS\dIdentityDB_log.ldf'',
            SIZE = 5MB,
            MAXSIZE = 25MB,
            FILEGROWTH = 5MB 
        )'
);
GO

USE dIdentityDB
GO

-- Let's create a table with an IDENTITY Property
DECLARE @iVal INT
CREATE TABLE tblIdentityDemo2
(
	iId			INT,
	vFirstName	VARCHAR(11),
	vLastName	VARCHAR(10)
)



SET @iVal = (SELECT ISNULL(MAX(iID),0) FROM tblIdentityDemo2)+1

-- Let's insert a couple of values
insert into tblIdentityDemo2 values (@iVal,'Hemantgiri', 'Goswami');

SET @iVal = (SELECT ISNULL(MAX(iID),0) FROM tblIdentityDemo2)+1
insert into tblIdentityDemo2 values (@iVal,'Brijalkumar','Patel');

SET @iVal = (SELECT ISNULL(MAX(iID),0) FROM tblIdentityDemo2)+1
insert into tblIdentityDemo2 values (@iVal,'Jagatrey','Patel');

SET @iVal = (SELECT ISNULL(MAX(iID),0) FROM tblIdentityDemo2)+1
insert into tblIdentityDemo2 values (@iVal,'Manish','Jariwala');

-- Let's check the values and the sequence of iId column
SELECT * FROM tblIdentityDemo2
GO

--Drop Demo Database
USE MASTER
GO
DROP DATABASE dIdentityDB
GO