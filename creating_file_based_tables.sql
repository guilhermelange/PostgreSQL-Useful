CREATE OR REPLACE FUNCTION public.read_file_(file_name text, delimitador text)
 RETURNS TABLE(temp_table text, colummns text, query_sql text)
 LANGUAGE plpgsql
AS $function$
 
 DECLARE 
    w_crosstab_query TEXT := 'select linha::text, 
                                 (row_number() over(PARTITION BY linha))::text AS coluna, 
                                 regexp_split_to_table(xs.reg, '''''||delimitador||''''') AS conteudo
                            from (SELECT (row_number() over()) AS linha,
                                         regexp_split_to_table(linha, '''';'''') AS reg 
                                    FROM regexp_split_to_table(pg_read_file('''''||file_name||'''''), E''''[\\n\\r\\t\\u2028]+'''') tab(linha))xs';
    table_return    record;
    columm          TEXT := '';
    table_name      TEXT := '';
    w_query_create  TEXT := '';
    w_query_drop    TEXT := '';
    w_query         TEXT := '';
    cabecalho       TEXT := '';
    file_name_      TEXT := substring(file_name, length(file_name) - POSITION('/' IN reverse(file_name))+2);
    qtd_colunas  integer := 1;

 BEGIN 
     /*Funciona a partir da versão 8.3 do Postgres*/
     CREATE EXTENSION IF NOT EXISTS tablefunc;
     
     SELECT length(val) - length(REPLACE(val, delimitador, '')) + 1,
             val 
       INTO  qtd_colunas,
             cabecalho
       FROM (SELECT (row_number() over()) AS linha, 
                    val
               FROM regexp_split_to_table(pg_read_file(file_name), E'[\\n\\r\\t\\u2028]+') tab(val)
              ORDER BY 1 LIMIT 1)xs;
     
     w_query = $$
        SELECT *
          FROM crosstab('[CROSSTAB]') as ct([TAG_QTD_COLUNA])
         WHERE reg::int > 1   -- Não conta o cabeçalho
         ORDER BY reg::int  $$;

    SELECT 'reg TEXT, '||string_agg(''||split_part(cabecalho,delimitador,seqq) ||' TEXT', ', ') 
      INTO columm
      FROM generate_series(1,qtd_colunas) tab(seqq);
 
    w_query = REPLACE(w_query, '[TAG_QTD_COLUNA]', columm);
    w_query = REPLACE(w_query, '[CROSSTAB]', w_crosstab_query);    

    table_name = 'readfile_'||substring(file_name_, 1, length(file_name_) - POSITION('.' IN reverse(file_name_)));
    
    w_query_drop   = 'DROP TABLE IF EXISTS '||table_name;
    EXECUTE w_query_drop;

    w_query_create = 'CREATE TEMPORARY TABLE '|| table_name ||' AS '|| w_query;
    EXECUTE w_query_create;

    RETURN query SELECT table_name,columm, w_query;
    
 END
  $function$
;
