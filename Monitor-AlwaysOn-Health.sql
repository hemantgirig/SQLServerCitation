/*
Author - Hemantgiri S. Goswami
Site: https://sqlservercitation.com 

Twitter: https://twitter.com/hemantgirig

Date: 29th April 2010
*/

SELECT 
@@SERVERNAME as ServerName 
,d.name as DBName 
,d.database_id as DBID 
,d.state_desc as DBStatus 
,CASE M.mirroring_role 
    WHEN 2 THEN 'Mirrored' 
    WHEN 1 THEN 'PRINCIPAL' 
    ELSE 'Log Shipped' 
 END      
as MirroringRole  
,  
CASE M.mirroring_state   
    WHEN 0 THEN 'Suspended' 
    WHEN 1 THEN 'Disconnected from the other partner' 
    WHEN 2 THEN 'Synchronizing' 
    WHEN 3 THEN 'Pending Failover' 
    WHEN 4 THEN 'Synchronized' 
    WHEN 5 THEN 'Failover is not possible now' 
    WHEN 6 THEN 'Failover is potentially possible' 
    ELSE 'Is Not Mirrored' 
END 
as MirroringState, 
M.mirroring_partner_instance as 'Partner', 
M.mirroring_partner_name as 'Endpoint', 
M.mirroring_safety_level_desc as 'SaftyLevel', 
E.state_desc as 'Endpoint State', 
SUSER_SNAME(owner_sid) as DBOwner, 
compatibility_level as CompatibilityLevel 
from master.sys.databases d  
JOIN master.sys.database_mirroring M 
ON d.database_id = M.database_id,sys.database_mirroring_endpoints E 
WHERE d.database_id NOT IN (db_id('test')) 
AND d.state_desc <> 'OFFLINE' 
AND M.mirroring_state IS NOT NULL 
order by d.name  