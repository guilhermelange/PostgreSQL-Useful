CREATE OR REPLACE FUNCTION EOM(data_base date)
 RETURNS date
 LANGUAGE sql
AS $function$

SELECT ((date_trunc('month',data_base::date)+ INTERVAL '1 month') - INTERVAL '1 day')::Date


$function$
;
