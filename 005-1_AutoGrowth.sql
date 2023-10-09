-- Let's create a test database  
CREATE DATABASE dAutoGrowthDemo
        ON 
        ( NAME = dAutoGrowthDemo_Data,
            FILENAME = 'C:\SQLDATA\DEMODBS\dAutoGrowthDemo_data.mdf',
            SIZE = 10MB,
            MAXSIZE = 500MB,
            FILEGROWTH = 1MB 
        )
        LOG ON
        ( NAME = dAutoGrowthDemo_log,
            FILENAME = 'C:\SQLDATA\DEMODBS\dAutoGrowthDemo_log.ldf',
            SIZE = 5MB,
            MAXSIZE = 500MB,
            FILEGROWTH = 1MB 
        )
GO
USE dAutoGrowthDemo
GO

-- Let's create a test table
CREATE TABLE dbo.ConvertTest 
(
	BigIntColumn BIGINT NOT NULL,
	IntColumn INT NOT NULL,
	DateColumn VARCHAR(30)
);

-- Let's create a few indexes 
CREATE INDEX BigIntIndex  ON dbo.ConvertTest (BigIntColumn);

CREATE INDEX IntIndex ON dbo.ConvertTest (IntColumn);

CREATE INDEX DateIndex ON dbo.ConvertTest(DateColumn);

-- Let's insert a few thousand records and it will abruptly error out

WITH    Nums
AS (SELECT TOP (1000000)
ROW_NUMBER() OVER (ORDER BY (SELECT 1
)) AS n
FROM      master.sys.all_columns ac1
CROSS JOIN master.sys.all_columns ac2
)
INSERT  INTO dbo.ConvertTest
(BigIntColumn,
IntColumn,
DateColumn
)
SELECT  Nums.n,
Nums.n,
DATEADD(HOUR, Nums.n, '1/1/1900')
FROM    Nums

--select * from ConvertTest