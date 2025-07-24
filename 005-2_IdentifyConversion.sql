/*
	This query will return the Query Text which cause implicit conversion
	Implicit = In direct
	Explicit = Direct
	Data Precedence
	--https://learn.microsoft.com/en-us/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-ver17&redirectedfrom=MSDN 
*/
select top(50) db_name(SQLText.dbid) as [Database Name],
SQLText.text as [Query Text],
QueryStats.total_worker_time as [Total Worker Time],
QueryStats.total_worker_time/QueryStats.execution_count as [Avg Worker Time],
QueryStats.max_worker_time as [Max Worker Time],
QueryStats.total_elapsed_time as [Total Elapsed Time],
QueryStats.max_elapsed_time as [Max Elapsed Time],
QueryStats.total_logical_reads/QueryStats.execution_count as [Avg Logical Reads],
QueryStats.max_logical_reads as [Max Logical Reads],
QueryStats.execution_count as [Execution Count],
QueryStats.creation_time as [Creation Time],
QueryPlan.query_plan as [Query Plan]
from sys.dm_exec_query_stats as QueryStats with (nolock)
cross apply sys.dm_exec_sql_text(plan_handle) as SQLText
cross apply sys.dm_exec_query_plan(plan_handle) as QueryPlan
where cast(query_plan as nvarchar(max)) like ('%convert_implicit%')
and SQLText.dbid = db_id()
order by QueryStats.total_worker_time desc option(recompile)