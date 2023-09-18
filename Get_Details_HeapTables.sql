--/**************************************************************
--Created 2014-03-04
--Created by : Hemantgiri Goswami
--This script will return table size,# of records,total space, 
--used space and free space for heap tables for given database
--**************************************************************/
SELECT 
db_name() AS DBName,
SCHEMA_NAME(s.schema_id) AS SchemaName,
s.name AS TableName,
p.rows AS Records,
SUM(a.total_pages) * 8 AS "TotalSpace (KB)",
SUM(a.used_pages) * 8 AS "UsedSpace (KB)",
(SUM(a.total_pages)*8) - (SUM(a.used_pages)* 8) AS "UnusedSpace (KB)"
INTO #HeapTables
FROM sys.tables s
INNER JOIN sys.partitions p
on s.object_id=p.object_id
INNER JOIN sys.allocation_units a 
ON p.partition_id = a.container_id
WHERE OBJECTPROPERTY(s.object_id,'TableHasPrimaryKey') = 0
and a.total_pages > 0
group by s.schema_id,s.name,p.rows
ORDER BY SchemaName, TableName
GO
select * from #HeapTables
GO
drop table #HeapTables
GO
