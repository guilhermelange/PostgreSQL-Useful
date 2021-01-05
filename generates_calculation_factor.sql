CREATE OR REPLACE FUNCTION public.fator_parc(qtd integer, juros numeric)
 RETURNS SETOF record
 LANGUAGE plpgsql
AS $function$
  declare
  i record;
  base numeric;
  soma numeric := 0;
  contador integer   := 0;
  
  /*
   
   WITH RECURSIVE tbl AS (
    SELECT 0             AS contador, 
           NULL::numeric AS base,
           0::numeric    AS soma
  UNION ALL
    SELECT contador+1, 
           COALESCE(base,100/(contador+1))::numeric * 1.08, 
           soma+(COALESCE(base,100/(contador+1))::numeric * 1.08)
          FROM tbl
         WHERE contador+1 <= 12
    )
    SELECT contador, 
           round((soma/100) / contador,12), 
           round(((soma/100) / contador) / contador,12)
      FROM tbl 
     WHERE contador > 0

   
   
   
   * */
 
  begin
	  juros = 1 + (juros / 100);
	    
	  for i in 1..qtd	
	   loop
	   
	   contador = contador +1;
	   
	   if COALESCE(base,0) = 0 then 
	   	  base = (100::numeric / contador::numeric);
	   end if;
	   
	   base := (base::numeric * juros::NUMERIC);
	   soma := (soma::numeric + base::NUMERIC);
	  
	 
	   return query select contador, (soma/100) / contador, ((soma/100) / contador) / contador;
	 
	   end loop;
			  
  end;
	 
  $function$
;
