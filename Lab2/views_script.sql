
/* a) New sanction type: it is under study to set a new sanction for abnormally
reduced speed (half of the upper limit of the general speed limit on the road).
Do a view that provides the infringing vehicles, the date, and the speed difference
with the legal margin, to support the analysis of the convenience of this norm. */

CREATE OR REPLACE VIEW sanction_low_speed AS
  SELECT nPlate,odatetime,difference FROM(
    SELECT nPlate,speed,odatetime,speed_limit/2-speed AS difference FROM
    OBSERVATIONS JOIN ROADS ON road = name
    WHERE speed_limit/2 >= speed)
  WHERE difference > 0
  WITH READ ONLY CONSTRAINT sanction_low_speed;

/*
  Pruebas: --34 rows--

  SELECT nPlate,speed,road,speed_limit,difference FROM(
    SELECT nPlate,speed,road,speed_limit,speed_limit/2-speed AS difference FROM
    OBSERVATIONS NATURAL JOIN RADARS JOIN ROADS ON road = name
    WHERE speed_limit/2 >= speed)
  WHERE difference > 0;

  Observing the speed of the vehicle and the speed limit of the road is easy to
  verify the correct functioning of the query.
  All cars in the view are below the speed_limit of the road.

    nPlate = 7283OOE | 3797UOE
    speed = 31 km/h | 23 km/h
    road = M30 | M30
    speed_limit(road) = 70 km/h | 70 km/h
    difference = 4 km/h | 12 km/h
    ok - If the reglamentary difference on speed is 0, the observation is neglected.
*/

/* b) Monthly Whinger: drivers with more allegations rejected for each month. */
CREATE OR REPLACE VIEW monthly_whinger AS
SELECT debtor, EXTRACT(MONTH from reg_date) AS month, allegations
FROM(
  SELECT status, debtor, reg_date, COUNT(*) AS allegations FROM ALLEGATIONS NATURAL JOIN TICKETS
  JOIN PERSONS dni = debtor NATURAL JOIN DRIVERS
  WHERE status = 'R' AND debtor = dni;
)
GROUP BY debtor, reg_date
ORDER BY month DESC
WITH READ ONLY CONSTRAINT monthly_whinger;

select debtor, extract(YEAR from reg_date), extract(MONTH from reg_date), COUNT(extract(MONTH from reg_date)) AS allegations
from tickets natural join allegations
where status='R'
group by debtor, extract(YEAR from reg_date), extract(MONTH from reg_date)
order by extract(YEAR from reg_date) DESC, extract(MONTH from reg_date) DESC
WITH READ ONLY CONSTRAINT monthly_whinger;

/*
MIERDAS PARA INTENTAR CONSEGUIR SOLO EL MAX NUMBER OF DRIVERS FOR EACH MONTH

select COUNT(obs_veh), extract(YEAR from A.reg_date), extract(MONTH from A.reg_date), extract(YEAR from B.reg_date), extract(MONTH from B.reg_date)
from tickets A, tickets B
where a.year = b.year AND a.month = b.month AND status='R'
GROUP BY extract(YEAR from A.reg_date), extract(MONTH from A.reg_date)
ORDER BY extract(YEAR from reg_date) DESC, extract(MONTH from reg_date) DESC;
*/



/*
Pruebas:

insert into vehicles values('1234XWE','abcasdasadasdbasd','Seta','Cardus','black',to_date('10-JUL-97','DD-MON-YY'),to_date('10-JUL-97','DD-MON-YY'),'65871451A','48906593Z');
insert into vehicles values('1234XWF','abcasdasadasdbase','Seta','Cardus','black',to_date('10-JUL-97','DD-MON-YY'),to_date('10-JUL-97','DD-MON-YY'),'65871451A','48906593Z');
insert into vehicles values('4444ABC','abcasdasadasdbasf','Seta','Cardus','black',to_date('10-JUL-97','DD-MON-YY'),to_date('10-JUL-97','DD-MON-YY'),'65871451A','48906593Z');
insert into vehicles values('4444ACC','abcasdasadasdbasg','Seta','Cardus','black',to_date('10-JUL-97','DD-MON-YY'),to_date('10-JUL-97','DD-MON-YY'),'65871451A','48906593Z');

insert into observations values('1234XWE',TO_TIMESTAMP('08-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
insert into observations values('1234XWF',TO_TIMESTAMP('08-APR-18 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
insert into observations values('4444ABC',TO_TIMESTAMP('08-APR-17 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
insert into observations values('4444ACC',TO_TIMESTAMP('08-APR-17 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);

insert into tickets values('1234XWE',TO_TIMESTAMP('08-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'D','1234XWF',TO_TIMESTAMP('08-APR-18 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),to_date('08-APR-18','DD-MON-YY'),to_date('28-APR-18','DD-MON-YY'),'C','2000','64997574B','F');
insert into tickets values('4444ABC',TO_TIMESTAMP('08-APR-17 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'D','4444ACC',TO_TIMESTAMP('08-APR-17 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),to_date('08-APR-17','DD-MON-YY'),to_date('28-APR-17','DD-MON-YY'),'C','1000','83880461J','F');
insert into tickets values('1234XWF',TO_TIMESTAMP('08-APR-18 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'D','1234XWE',TO_TIMESTAMP('08-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),to_date('08-APR-18','DD-MON-YY'),to_date('28-APR-18','DD-MON-YY'),'C','2000','64997574B','F');
insert into tickets values('4444ACC',TO_TIMESTAMP('08-APR-17 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'D','4444ABC',TO_TIMESTAMP('08-APR-17 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),to_date('08-APR-17','DD-MON-YY'),to_date('28-APR-17','DD-MON-YY'),'C','1000','83880461J','F');


insert into allegations values('1234XWE',TO_TIMESTAMP('08-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'D',TO_TIMESTAMP('08-APR-18 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'48906593Z','R',TO_TIMESTAMP('08-APR-18 09.00.00.000002','DD-MON-YY HH24.MI.SS.FF'));
insert into allegations values('4444ABC',TO_TIMESTAMP('08-APR-17 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'D',TO_TIMESTAMP('08-APR-17 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'48906593Z','R',TO_TIMESTAMP('08-APR-17 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'));
insert into allegations values('1234XWF',TO_TIMESTAMP('08-APR-18 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'D',TO_TIMESTAMP('08-APR-18 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'48906593Z','R',TO_TIMESTAMP('08-APR-18 09.00.00.000002','DD-MON-YY HH24.MI.SS.FF'));
insert into allegations values('4444ACC',TO_TIMESTAMP('08-APR-17 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'D',TO_TIMESTAMP('08-APR-17 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'),'48906593Z','R',TO_TIMESTAMP('08-APR-17 09.00.00.000001','DD-MON-YY HH24.MI.SS.FF'));

delete from allegations values('1234XWE');
delete from allegations values('4444ABC');
delete from allegations values('1234XWF');
delete from allegations values('4444ACC');

*/




/* c) Stretches: table that records each road section in which the speed is lower
than the general speed of the road (it contains the identification of the road,
start and end points, and speed limit in the section). */
--HECHA
--181 rows
CREATE OR REPLACE VIEW Stretches AS
SELECT DISTINCT R1.km_point AS start_point, CASE WHEN ABS(R1.km_point-R2.km_point) > 5 THEN R1.km_point+5
        ELSE R2.km_point END AS end_point, R1.road, R1.speedlim
  FROM RADARS R1, RADARS R2 JOIN ROADS ON name = road
  WHERE R1.km_point < R2.km_point AND R1.road = R2.road AND R1.direction = R2.direction AND R1.km_point != R2.km_point AND R1.speedlim < speed_limit
  WITH READ ONLY CONSTRAINT Stretches;

/*
TESTS: we do a query where we also select the speed limit of the road in order to see the difference and make sure the result is correct

SELECT DISTINCT R1.km_point AS start_point, CASE WHEN ABS(R1.km_point-R2.km_point) > 5 THEN R1.km_point+5
ELSE R2.km_point END AS end_point, R1.road, R1.speedlim, speed_limit AS road_speed_limit
FROM RADARS R1, RADARS R2 JOIN ROADS ON name = road
WHERE R1.km_point < R2.km_point AND R1.road = R2.road AND R1.direction = R2.direction AND R1.km_point != R2.km_point AND R1.speedlim < speed_limit;
*/

/* d) Quick-Witted Drivers: the ten drivers whose average speed is closest to those
of the road without exceeding it. Tip: base the calculation on the percentage of
the maximum speed that each observation records. */ 
CREATE OR REPLACE VIEW quickWitted_drivers AS
SELECT DNI
FROM
WHERE ROWNUM = 10;
