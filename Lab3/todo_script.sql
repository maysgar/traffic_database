ALTER SESSION SET nls_numeric_characters=',.';
set serveroutput on;
set timing on;
set autotrace on;
set linesize 1500;

@'\\tsclient\C\Users\NitroPC\Desktop\creation.sql'
@'\\tsclient\C\Users\NitroPC\Desktop\solution.sql'
@'\\tsclient\C\Users\NitroPC\Desktop\script_statistics.sql'
@'\\tsclient\C\Users\NitroPC\Desktop\insert.sql'

begin
pkg_costes.run_test;
end;
/

--INSERTIONS
INSERT INTO OBSERVATIONS (nPlate,odatetime,road,km_point,direction,speed)
	       SELECT DISTINCT matricula, TO_TIMESTAMP(to_char(84+to_number(substr(fecha_foto,1,4)))||substr(fecha_foto,5)||hora_foto,'YYYY-MM-DDHH24:MI:SS.FF2'),
	                       carretera_foto,pto_km_radar,sentido_radar, velocidad_foto
	       FROM FSDB.MEGATABLE
	       WHERE ROWNUM <= 10000;



-- QUERY 1
SELECT * FROM (
  SELECT nplate, count('x') veces
  FROM observations
  WHERE TO_CHAR(odatetime,'YYYYMMDD')=TO_CHAR(sysdate,'YYYYMMDD')
  GROUP BY nplate
  ORDER BY veces DESC
  )
WHERE rownum<11;

--UPDATE TICKETS
 UPDATE TICKETS SET state='F', pay_type='B', pay_date = to_date(to_char(obs1_date+1,'YYYYMMDD'),'YYYYMMDD');



-- QUERY 2
WITH
  A AS (SELECT TO_CHAR(TO_DATE(TO_CHAR(sysdate,'YYYYMM'),'YYYYMM')-1,'MM') mmonth, TO_NUMBER(TO_CHAR(TO_DATE(TO_CHAR(sysdate,'YYYYMM'),'YYYYMM')-1,'YYYY')) yyear FROM DUAL),
  B AS (SELECT NVL(SUM(amount),0) present FROM tickets JOIN A ON(TO_CHAR(pay_date,'YYYYMM')=TO_CHAR(A.yyear)||A.mmonth)),
  C AS (SELECT NVL(SUM(amount),0) past FROM tickets JOIN A ON(TO_CHAR(pay_date,'YYYYMM')=TO_CHAR(A.yyear-1)||A.mmonth))
SELECT B.present-C.past evolution FROM B, C;



-- QUERY 3
SELECT * FROM new_ticket;

-- QUERY 4
SELECT * FROM qw_drivers;

--Delete observations
/*
 FOR I IN (SELECT * FROM (SELECT * FROM observations ORDER BY DBMS_RANDOM.VALUE)WHERE ROWNUM<=10000) LOOP
  DELETE FROM OBSERVATIONS WHERE nplate=i.nplate AND odatetime=i.odatetime;
 END LOOP;
   --DELETE FROM (SELECT * FROM observations ORDER BY DBMS_RANDOM.VALUE) WHERE rownum <=10000;
*/

  DELETE FROM observations
  WHERE rowid in(
    select r from(
      select rowid r, ROW_NUMBER() OVER (ORDER BY null) n from observations
    )
   where mod(n,6)=3
   );
