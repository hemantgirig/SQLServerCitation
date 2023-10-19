/* 
-- Created By: Hemantgiri S. Goswami
-- Date: 29th April 2011
-- Updated: 20th November 2018
-- Version: 1.1
-- Updated by Brent Ozar to take care weird database names; he added square braces

*/

-- Creating the table to capture temporary data
IF EXISTS(SELECT name FROM sys.sysobjects WHERE name = N'ConfigAutoGrowth' AND xtype='U')
	DROP TABLE ConfigAutoGrowth
GO	
CREATE TABLE DBO.ConfigAutoGrowth
(
iDBID		INT,
sDBName		SYSNAME,
vFileName	VARCHAR(max),
vGrowthOption	VARCHAR(12)
)
PRINT 'Table ConfigAutoGrowth Created'
GO
-- Inserting data into staging table
INSERT INTO DBO.ConfigAutoGrowth
SELECT 
	SD.database_id, 
	SD.name,
	SF.name,
	--sf.fileid, 
	--SUSER_NAME(owner_sid),
	--recovery_model_desc,
	CASE SF.status & 0x100000
	WHEN 1048576 THEN 'Percentage'
	WHEN 0 THEN 'MB'
	END AS 'GROWTH Option'
FROM SYS.SYSALTFILES SF
JOIN 
SYS.DATABASES SD
ON 
SD.database_id = SF.dbid
GO

-- Dynamically alters the file to set auto growth option to fixed mb 
DECLARE @name VARCHAR ( max ) -- Database Name
DECLARE @dbid INT -- DBID
DECLARE @vFileName VARCHAR ( max ) -- Logical file name
DECLARE @vGrowthOption VARCHAR ( max ) -- Growth option
DECLARE @Query VARCHAR(max) -- Variable to store dynamic sql


DECLARE db_cursor CURSOR FOR
SELECT 
idbid,sdbname,vfilename,vgrowthoption
FROM configautogrowth
WHERE sdbname NOT IN ('model') 
AND vGrowthOption  = 'Percentage'

-- Corrected to take care of weirdo db and file name at Line 62
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @dbid,@name,@vfilename,@vgrowthoption  
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'Changing AutoGrowth option for database:- '+ UPPER(@name)
	-- This line is edited by Brent Ozar to take care weird database names; he added square braces
	SET @Query  = 'ALTER DATABASE 9'+ @name +'] MODIFY FILE (NAME = ['+@vFileName+'],FILEGROWTH = 500MB)'
	EXECUTE(@Query)

FETCH NEXT FROM db_cursor INTO @dbid,@name,@vfilename,@vgrowthoption  
END
CLOSE db_cursor -- Closing the curson
DEALLOCATE db_cursor  -- deallocating the cursor

GO
-- Querying system views to see if the changes are applied
SELECT 
SD.database_id, 
SD.name,
SF.name,
--sf.fileid, 
--SUSER_NAME(owner_sid),
--recovery_model_desc,
CASE SF.STATUS 
& 0x100000
WHEN 1048576 THEN 
'Percentage'
WHEN 0 THEN 'MB'
END AS 'Growth_Option'
FROM SYS.SYSALTFILES SF
JOIN 
SYS.DATABASES SD
ON 
SD.database_id = SF.dbid
GO

--Dropping the staging table
DROP TABLE ConfigAutoGrowth 
GO
