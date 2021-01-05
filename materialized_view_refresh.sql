CREATE OR REPLACE FUNCTION public.refresh_materialized_view(mview text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$


DECLARE 
    query TEXT := '';

BEGIN 
    query = 'REFRESH MATERIALIZED VIEW ' || mview;
    EXECUTE query;
    RETURN 'Executado com Sucesso.';
    
    EXCEPTION WHEN OTHERS THEN 
        RETURN SQLERRM;
    
END

$function$
;
