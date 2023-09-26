/*

 
Author - Hemantgiri S. Goswami
Site: https://sqlservercitation.com 

Twitter: https://twitter.com/hemantgirig


Script Originally Written By: Dan Guzman | http://www.dbdelta.com/  
Modified by: Hemantgiri S. Goswami | http://www.sql-server-citation.com/ | Twitter: @Ghemant 
 
Reference: http://social.msdn.microsoft.com/Forums/en/transactsql/thread/226bbffc-2cfa-4fa8-8873-48dec6b5f17f 
VLF Count script is taken from :  http://gallery.technet.microsoft.com/scriptcenter/SQL-Script-to-list-VLF-e6315249 
Version 2.0 
Modification : 14th April 2014 
 
*/

--variables to hold each 'iteration'   
declare @query varchar(100)   
declare @dbname sysname   
declare @vlfs int   
   
--table variable used to 'loop' over databases   
declare @databases table (dbname sysname)   
insert into @databases   
--only choose online databases   
select name from sys.databases where state = 0   
   
--table variable to hold results   
declare @vlfcounts table   
    (dbname sysname,   
    vlfcount int)   
   
  
  
--table variable to capture DBCC loginfo output   
--changes in the output of DBCC loginfo from SQL2012 mean we have to determine the version  
  
declare @MajorVersion tinyint   
set @MajorVersion = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))-1)  
  
if @MajorVersion < 11 -- pre-SQL2012  
begin  
    declare @dbccloginfo table   
    (   
        fileid tinyint,   
        file_size bigint,   
        start_offset bigint,   
        fseqno int,   
        [status] tinyint,   
        parity tinyint,   
        create_lsn numeric(25,0)   
    )   
   
    while exists(select top 1 dbname from @databases)   
    begin   
   
        set @dbname = (select top 1 dbname from @databases)   
        set @query = 'dbcc loginfo (' + '''' + @dbname + ''') '   
   
        insert into @dbccloginfo   
        exec (@query)   
   
        set @vlfs = @@rowcount   
   
        insert @vlfcounts   
        values(@dbname, @vlfs)   
   
        delete from @databases where dbname = @dbname   
   
    end --while  
end  
else  
begin  
    declare @dbccloginfo2012 table   
    (   
        RecoveryUnitId int,  
        fileid tinyint,   
        file_size bigint,   
        start_offset bigint,   
        fseqno int,   
        [status] tinyint,   
        parity tinyint,   
        create_lsn numeric(25,0)   
    )   
   
    while exists(select top 1 dbname from @databases)   
    begin   
   
        set @dbname = (select top 1 dbname from @databases)   
        set @query = 'dbcc loginfo (' + '''' + @dbname + ''') '   
   
        insert into @dbccloginfo2012   
        exec (@query)   
   
        set @vlfs = @@rowcount   
   
        insert @vlfcounts   
        values(@dbname, @vlfs)   
   
        delete from @databases where dbname = @dbname   
   
    end --while  
end  
   
 
DECLARE 
    @SqlStatement NVARCHAR(MAX) 
    ,@DatabaseName SYSNAME; 
     
IF OBJECT_ID(N'tempdb..#DatabaseSpace') IS NOT NULL 
    DROP TABLE #DatabaseSpace; 
     
CREATE TABLE #DatabaseSpace 
( 
    SERVERNAME            SYSNAME, 
    DBID                INT, 
    DATABASE_NAME        SYSNAME, 
    Recovery_Model        VARCHAR(15), 
    IsAutoClose            VARCHAR(25), 
    IsAutoUpdStats        VARCHAR(25), 
    IsAutoShrink        VARCHAR(25), 
    DBOWNER                VARCHAR(25), 
    LOGICAL_NAME        SYSNAME, 
    FILE_PATH            SYSNAME, 
    FILE_SIZE_GB        DECIMAL(12, 2), 
    SPACE_USED_GB        DECIMAL(12, 2), 
    FREE_SPACE_GB        DECIMAL(12, 2), 
    GROWTH_OPTION        VARCHAR(15), 
    MAXIMUM_SIZE        INT, 
    AUTOGROWTH_Value    INT, 
    DB_STATUS            VARCHAR(100) 
);  
     
DECLARE DatabaseList CURSOR LOCAL FAST_FORWARD FOR 
    SELECT name FROM sys.databases WHERE STATE = 0 
    AND DATABASEPROPERTYEX(NAME,'Updateability') <> 'OFFLINE' 
    AND Database_ID NOT IN (db_ID('master'),db_ID('model'),db_ID('msdb'),db_ID('tempdb')); 
    --,db_ID('reportserver'),db_ID('reportservertempdb') 
OPEN DatabaseList; 
WHILE 1 = 1 
BEGIN 
    FETCH NEXT FROM DatabaseList INTO @DatabaseName; 
    IF @@FETCH_STATUS = -1 BREAK; 
    SET @SqlStatement = N'USE ' 
        + QUOTENAME(@DatabaseName) 
        + CHAR(13)+ CHAR(10) 
        + N'INSERT INTO #DatabaseSpace 
                SELECT 
                [ServerName]         = @@ServerName 
                ,[DBID]             = SD.DBID 
                ,[DATABASE_NAME]    = DB_NAME() 
                ,[Recovery_Model]    = d.recovery_model_desc 
                ,IsAutoClose        = 
                                    CASE Databasepropertyex(sd.name,''IsAutoClose'')  
                                        WHEN 0 THEN ''Auto Close False'' 
                                        WHEN 1 THEN ''Auto Close True'' 
                                    END 
                ,IsAutoUpdateStats = 
                                    CASE DAtabasepropertyex(sd.name,''isautoupdatestatistics'') 
                                        WHEN 0 THEN ''Auto Update Stats False'' 
                                        WHEN 1 THEN ''Auto Update Stats True'' 
                                    END 
                ,IsAutoShrink        = 
                                    CASE DAtabasepropertyex(sd.name,''IsAutoShrink'') 
                                        WHEN 0 THEN ''Auto Shrink False'' 
                                        WHEN 1 THEN ''Auto Shrink True'' 
                                    END 
                ,[DBOwner]             = SUSER_SNAME(sd.sid) 
                ,[LOGICAL_NAME]     = f.name 
                ,[File_Path]         = sf.filename 
                ,[FILE_SIZE_GB]     = (CONVERT(decimal(12,2),round(f.size/128.000,2))/1024) 
                ,[SPACE_USED_GB]     = (CONVERT(decimal(12,2),round(fileproperty(f.name,''SpaceUsed'')/128.000,2))/1024) 
                ,[FREE_SPACE_GB]     = (CONVERT(decimal(12,2),round((f.size-fileproperty(f.name,''SpaceUsed''))/128.000,2))/1024) 
                ,[Growth_Option]     = case sf.status  
                                        & 0x100000 
                                        WHEN 1048576    THEN    ''Percentage''                                         
                                        WHEN 0            THEN    ''MB'' 
                                      END 
                ,[Maximum_Size]     = SF.MaxSize 
                ,[AutoGrowth(MB)]     = (SF.Growth*8/1024) 
                ,[DB_Status]        = 
                                    CASE SD.STATUS 
                                        WHEN 0 THEN ''Normal'' 
                                        WHEN 1 THEN ''autoclose''  
                                        WHEN 2 THEN ''2 not sure''  
                                        WHEN 4 THEN ''select into/bulkcopy''  
                                        WHEN 8 THEN ''trunc. log on chkpt''  
                                        WHEN 16 THEN ''torn page detection''  
                                        WHEN 20 THEN ''Normal''  
                                        WHEN 24 THEN ''Normal''  
                                        WHEN 32 THEN ''loading''  
                                        WHEN 64 THEN ''pre recovery''  
                                        WHEN 128 THEN ''recovering''  
                                        WHEN 256 THEN ''not recovered''  
                                        WHEN 512 THEN ''offline''  
                                        WHEN 1024 THEN ''read only''  
                                        WHEN 2048 THEN ''dbo use only''  
                                        WHEN 4096 THEN ''single user''  
                                        WHEN 8192 THEN ''8192 not sure''  
                                        WHEN 16384 THEN ''16384 not sure''  
                                        WHEN 32768 THEN ''emergency mode''  
                                        WHEN 65536 THEN ''online''  
                                        WHEN 131072 THEN ''131072 not sure''  
                                        WHEN 262144 THEN ''262144 not sure''  
                                        WHEN 524288 THEN ''524288 not sure''  
                                        WHEN 1048576 THEN ''1048576 not sure''  
                                        WHEN 2097152 THEN ''2097152 not sure''  
                                        WHEN 4194304 THEN ''autoshrink''  
                                        WHEN 1073741824 THEN ''cleanly shutdown'' 
                                    END 
             
            FROM SYS.DATABASE_FILES F 
            JOIN  
            MASTER.DBO.SYSALTFILES SF 
            ON F.NAME = SF.NAME COLLATE DATABASE_DEFAULT 
            JOIN  
            MASTER.SYS.SYSDATABASES SD 
            ON  
            SD.DBID = SF.DBID 
            JOIN 
            MASTER.SYS.DATABASES D 
            ON  
            D.DATABASE_ID = SD.DBID 
            AND DATABASEPROPERTYEX(SD.NAME,''Updateability'') <> ''OFFLINE'' 
            AND SD.DBID NOT IN (db_ID(''master''),db_ID(''model''),db_ID(''msdb''),db_ID(''tempdb'')) 
            --,db_ID(''reportserver''),db_ID(''reportservertempdb'') 
            ORDER BY [File_Size_GB] DESC'; 
    EXECUTE(@SqlStatement); 
     
END 
CLOSE DatabaseList; 
DEALLOCATE DatabaseList; 
 
SELECT d.*,v.vlfcount FROM #DatabaseSpace D 
join @vlfcounts V 
on D.DATABASE_NAME = v.dbname ; 
 
DROP TABLE #DatabaseSpace; 
GO