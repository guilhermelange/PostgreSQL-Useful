CREATE OR REPLACE FUNCTION public.random_between(low bigint, high bigint)
 RETURNS bigint
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
BEGIN
   RETURN floor(random()* (high-low + 1) + low)::bigint;
END;
$function$
;
