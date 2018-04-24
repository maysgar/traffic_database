CREATE OR REPLACE PACKAGE PKG_COSTES AS

-- auxiliary function converting an interval into a number (milliseconds)
	FUNCTION interval_to_seconds(x INTERVAL DAY TO SECOND) RETURN NUMBER;

-- WORKLOAD definition
	PROCEDURE PR_WORKLOAD(N NUMBER);

-- RE-STABLISH DB STATE
	PROCEDURE PR_RESET(N NUMBER);

-- Execution of workload (10 times) displaying some measurements
	PROCEDURE RUN_TEST;

END PKG_COSTES;

/
CREATE OR REPLACE PACKAGE BODY PKG_COSTES AS FUNCTION interval_to_seconds(x INTERVAL DAY TO SECOND ) RETURN NUMBER IS
  BEGIN
    return (((extract( day from x)*24 + extract( hour from x))*60 + extract( minute from x))*60 + extract( second from x))*1000;
  END interval_to_seconds;


PROCEDURE PR_WORKLOAD(N NUMBER) IS
-- iteration N is not taken into account
BEGIN

-- INSERTS
INS_OBS(10000);

-- QUERY 1
  FOR f IN (SELECT *
            FROM (SELECT nplate, count('x') veces
                    FROM observations
                    WHERE TO_CHAR(odatetime,'YYYYMMDD')=TO_CHAR(sysdate,'YYYYMMDD')
                    GROUP BY nplate
                    ORDER BY veces DESC)e
            WHERE rownum<11
          ) LOOP NULL;
  END LOOP;

-- Paying tickets

  UPDATE TICKETS SET state='F', pay_type='B', pay_date = to_date(to_char(obs1_date+1,'YYYYMMDD'),'YYYYMMDD');

-- QUERY 2
  FOR f IN (WITH
      A AS (SELECT TO_CHAR(TO_DATE(TO_CHAR(sysdate,'YYYYMM'),'YYYYMM')-1,'MM') mmonth, TO_NUMBER(TO_CHAR(TO_DATE(TO_CHAR(sysdate,'YYYYMM'),'YYYYMM')-1,'YYYY')) yyear FROM DUAL),
      B AS (SELECT NVL(SUM(amount),0) present FROM tickets JOIN A ON(TO_CHAR(pay_date,'YYYYMM')=TO_CHAR(A.yyear)||A.mmonth)),
      C AS (SELECT NVL(SUM(amount),0) past FROM tickets JOIN A ON(TO_CHAR(pay_date,'YYYYMM')=TO_CHAR(A.yyear-1)||A.mmonth))
     SELECT B.present-C.past evolution FROM B, C
           ) LOOP NULL;
  END LOOP;

-- QUERY 3
  FOR f IN (SELECT * FROM new_ticket) LOOP NULL;
  END LOOP;


-- QUERY 4
  FOR f IN (SELECT * FROM qw_drivers) LOOP NULL;
  END LOOP;

-- DELETES
DEL_OBS(10000);

END PR_WORKLOAD;



PROCEDURE PR_RESET(N NUMBER) IS
  BEGIN
     NULL;

-- Realize that your design could be degenerating
-- To test only initial state's performance, you can restablish initial state
-- In this case, this can only be attained by truncating observations table, and uploading it again
--   TRUNCATING ...;
--   ...
-- IF you don't, the 'logical' state is almost the same (same amount of data), while physical state could be worse
-- You can test 'real' working by doing nothing in this procedure, but taking into account degeneration while analyzing

END PR_RESET;



PROCEDURE RUN_TEST IS
	t1 TIMESTAMP;
	t2 TIMESTAMP;
	auxt NUMBER;
	g1 NUMBER;
	g2 NUMBER;
	auxg NUMBER;
	localsid NUMBER;
    BEGIN
  PKG_COSTES.PR_WORKLOAD(0);  -- first run for preparing db_buffers
	select distinct sid into localsid from v$mystat;
	SELECT SYSTIMESTAMP INTO t1 FROM DUAL;
	select S.value into g1 from (select * from v$sesstat where sid=localsid) S join (select * from v$statname where name='consistent gets') using(STATISTIC#);
    	--- EXECUTION OF THE WORKLOAD -----------------------------------
	FOR i IN 1..10 LOOP
	    PKG_COSTES.PR_WORKLOAD (i);
	END LOOP;
    	-----------------------------------
	SELECT SYSTIMESTAMP INTO t2 FROM DUAL;
	select S.value into g2 from (select * from v$sesstat where sid=localsid) S join (select * from v$statname where name='consistent gets') using(STATISTIC#);
	auxt:= interval_to_seconds(t2-t1);
	auxg:= (g2-g1) / 10;
    	--- DISPLAY RESULTS -----------------------------------
	DBMS_OUTPUT.PUT_LINE('RESULTS AT '||SYSDATE);
	DBMS_OUTPUT.PUT_LINE('TIME CONSUMPTION: '|| auxt ||' milliseconds.');
	DBMS_OUTPUT.PUT_LINE('CONSISTENT GETS: '|| auxg ||' blocks');

	FOR J IN 0..10 LOOP
	    PKG_COSTES.PR_RESET (J);
	END LOOP;

END RUN_TEST;


BEGIN
   DBMS_OUTPUT.ENABLE (buffer_size => NULL);
END PKG_COSTES;

/

   
