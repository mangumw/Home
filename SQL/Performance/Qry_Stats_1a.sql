SELECT DB_NAME(st.dbid) DBName
      ,OBJECT_SCHEMA_NAME(objectid,st.dbid) SchemaName
      ,OBJECT_NAME(objectid,st.dbid) StoredProcedure
      ,last_logical_reads
      ,last_worker_time
      ,total_worker_time/usecounts as AvgWorkerTime
      ,last_execution_time
      ,CAST(last_elapsed_time as decimal(24,8))/1000000 as elapsed_time_secs
      ,CAST(CAST(total_elapsed_time as decimal(24,8))/usecounts/1000000 as decimal(24,8)) as avg_time_secs
      ,CAST(max_elapsed_time as decimal(24,8))/1000000 as max_time_secs
 FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
   join sys.dm_exec_cached_plans cp on qs.plan_handle = cp.plan_handle
  where DB_NAME(st.dbid) is not null and cp.objtype = 'proc'
  and OBJECT_NAME(objectid,st.dbid) = 'usp_Build_CARD'
 order by last_execution_time desc