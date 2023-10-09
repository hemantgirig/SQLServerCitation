-- Get the name of the current default trace file
DECLARE @filename NVARCHAR(1000)
 
SELECT @filename = CAST(value AS NVARCHAR(1000))
FROM sys.fn_trace_getinfo(DEFAULT)
WHERE traceid = 1 AND property = 2
 
-- separate file name into pieces
DECLARE @bc INT,
@ec INT,
@bfn VARCHAR(1000),
@efn VARCHAR(10)
 
SET @filename = REVERSE(@filename)
SET @bc = CHARINDEX('.',@filename)
SET @ec = CHARINDEX('_',@filename)+1
SET @efn = REVERSE(SUBSTRING(@filename,1,@bc))
SET @bfn = REVERSE(SUBSTRING(@filename,@ec,LEN(@filename)))
 
-- set filename without rollover number
SET @filename = @bfn + @efn
 
-- Let's see the number of events for Data and Log file growth */
-- (92 = Date File Auto-grow, 93 = Log File Auto-grow)

SELECT 
trace_event_id,
name,
DatabaseName
FROM fn_trace_gettable(@filename, DEFAULT) AS ftg 
INNER JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id
WHERE 
(
	ftg.EventClass = 92 OR ftg.EventClass = 93
	
) 
AND DatabaseID = DB_ID('dAutoGrowthDemo')

/*
datepart(mm,starttime)=6
and datepart(yy,starttime)=2018
and datepart(dd,starttime)=21
*/