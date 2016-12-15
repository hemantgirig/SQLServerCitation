--==================================================================================
-- Author - Hemantgiri S. Goswami
-- http://www.sql-server-citation.com 
-- Created: Somewhere in 2005
-- This Script will list all the database, backup file name, type of backup, and 
-- size of backup file that has been backed up today except Read-Only, and Mirrored. 
-- Feel free to modify the script per need.
--===========================================================================
select distinct 
bs.database_name AS "DB Name",
bmf.physical_device_name AS "Backup File Name",
((bs.backup_size/1024)/1024) as 'Backup Size(MB)',
CASE bs.type 
WHEN 'D' THEN 'FULL'
WHEN 'L' THEN 'LOG'
WHEN 'I' THEN 'Differential'
END 
as "Backup Type",
bs.backup_finish_date AS "Backup Date",
datediff(mi, bs.backup_start_date,bs.backup_finish_date) as 'Duration(minute)'
from
msdb..backupmediafamily bmf
join 
msdb..backupset bs
on
bs.media_set_id=bmf.media_set_id
join
master..sysdatabases sd
on
sd.name = bs.database_name
where convert(varchar,bs.backup_finish_date,112) = convert (varchar(12),GETDATE(),112)
and sd.status NOT IN (1024, 1040)
order by bs.database_name,bs.backup_finish_date ASC