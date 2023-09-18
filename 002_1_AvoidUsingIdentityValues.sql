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

CREATE TABLE tblIdentityDemo
(
	iId			INT	IDENTITY(1,1),
	vFirstName	VARCHAR(11),
	vLastName	VARCHAR(10)
)

-- Let's insert a couple of values
insert into tblIdentityDemo values ('Hemantgiri', 'Goswami')
go
insert into tblIdentityDemo values ('Brijalkumar','Patel')
go
insert into tblIdentityDemo values ('Jagatrey','Patel')
go
insert into tblIdentityDemo values ('Manish','Jariwala')
go

-- Let's check the values and the sequence of iId column
SELECT * FROM tblIdentityDemo
GO

-- Let's try to insert a few more values here
insert into tblIdentityDemo values ('Kiyanshgiri', 'Goswami')
go
insert into tblIdentityDemo values ('Prathamkumar','Patel')
go
insert into tblIdentityDemo values ('Shashwatkumar','Patel')
go

-- Let's check the sequence of iId column agin
SELECT * FROM tblIdentityDemo
GO

-- It's okay, that would fail because I've intentionally tried to insert oversize data
insert into tblIdentityDemo values ('Kiyansh', 'Goswami')
go
insert into tblIdentityDemo values ('Pratham','Patel')
go
insert into tblIdentityDemo values ('Shashwat','Patel')
go


-- Let's check the sequence of iId column agin
SELECT * FROM tblIdentityDemo
GO

--Dropping a Demo Database
USE MASTER
GO
DROP DATABASE dIdentityDB
GO