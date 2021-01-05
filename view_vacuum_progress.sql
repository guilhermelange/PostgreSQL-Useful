create view vacuum_progress as 
  select pspc.pid,
  		 psa.backend_start,
         command,
         pspc.datname,
         relname,
         phase,
         round((heap_blks_scanned::numeric/case heap_blks_total when 0 then 1 else heap_blks_total end )*100,2) as pct_table,
         index_rebuild_count||' / '||pi.count as idx_done
    from pg_stat_progress_cluster pspc
         join pg_stat_user_tables psut on pspc.relid = psut.relid
         left join pg_stat_activity psa on psa.pid = pspc.pid
         left join (select count(*), indrelid
                      from pg_index
                    group by 2) as pi on pi.indrelid = pspc.relid
union all
  select pspc.pid,
  	     psa.backend_start,
         'VACUUM ANALYZE',
         pspc.datname,
         relname,
         phase,
         round((heap_blks_scanned::numeric/case heap_blks_total when 0 then 1 else heap_blks_total end )*100,2) as pct_table,
         0||' / '||0
    from pg_stat_progress_vacuum pspc
         join pg_stat_user_tables psut on pspc.relid = psut.relid
         left join pg_stat_activity psa on psa.pid = pspc.pid
         left join (select count(*), indrelid
                      from pg_index
                    group by 2) as pi on pi.indrelid = pspc.relid