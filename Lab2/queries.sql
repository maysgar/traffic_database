/*----------------------------QUERY A--------------------------*/
/* The top 10 vehicles most 'observed' in the course of today. */

--NICEEEEEE (0)
SELECT * FROM(
SELECT nPlate, COUNT(nPlate) AS appearance
FROM OBSERVATIONS
WHERE odatetime = sysdate
GROUP BY nPlate
ORDER BY appearance DESC
)
WHERE ROWNUM <= 10;

/*
Algo asi pa chequear que la query se hace

SELECT * FROM(
SELECT a.nPlate, COUNT(a.nPlate) AS appearance
FROM OBSERVATIONS a, OBSERVATIONS b
WHERE a.odatetime = b.odatetime
GROUP BY a.nPlate
ORDER BY appearance DESC
)
WHERE ROWNUM <= 10;
*/

/*----------------------------QUERY B--------------------------*/
/* List of roads and their average speed limit, ordered from highest to lowest speed in the first instance and in alphabetical order of roads in second,
counting both directions. */

--NICEEEEEE (10)

SELECT name, speed_limit
FROM(
SELECT name, speed_limit
FROM ROADS
ORDER BY name ASC)
GROUP BY name, speed_limit
ORDER BY speed_limit DESC;

/*----------------------------QUERY C--------------------------*/
/* People who do not drive any of their vehicles (neither as a regular driver nor
as an additional driver). */

SELECT owner
FROM VEHICLES
WHERE reg_driver != owner;

/* cosas de Gabo */
/*
SELECT name, surn_1 FROM(
SELECT dni FROM drivers A
FULL OUTER JOIN
SELECT dni FROM persons B
ON A.dni = B.dni
WHERE A.dni IS NULL OR B.dni IS NULL
);
*/

/* Prueba Isma assignments */
/*
SELECT owner FROM(
SELECT owner FROM vehicles A
JOIN
SELECT driver FROM assignments B
ON A.nPlate = B.nPlate
WHERE A.owner != A.reg_driver AND A.owner != B.driver
GROUP BY owner
);
*/

/*----------------------------QUERY D--------------------------*/
/* Boss: owners of at least three cars they don’t drive. */



--NICEEEEEE (10)

/*
Prueba:

05511330R ok 4
56651407S ok 4
22649968M ok 3
60908146Y ok 3
17017996C ok 3
48906593Z ok 3
49806223E ok 3
19425545K ok 3
82883718K ok 3
48272209Q ok 3

select owner, reg_driver, nPlate, count(nPlate)
from vehicles
where owner = ' dni de los de arriba '
group by owner, reg_driver, nPlate;

*/

SELECT owner, COUNT(nPlate) AS v_owned
FROM VEHICLES
WHERE reg_driver != owner
GROUP BY owner
HAVING COUNT(nPlate) >= 3
ORDER BY v_owned DESC;

/*----------------------------QUERY E--------------------------*/
/* Evolution: indicates the difference of income due to tickets fines between the
last month and the same month of the previous year. */

SELECT actual_income-last_income as diff_income FROM(
SELECT SUM(A.amount) as actual_income, SUM(B.amount) as last_income
FROM tickets A, tickets B
WHERE EXTRACT(MONTH from A.pay_date) = EXTRACT(MONTH FROM sysdate) AND EXTRACT(MONTH from B.pay_date) = EXTRACT(MONTH FROM sysdate)
AND EXTRACT(YEAR from A.pay_date) = EXTRACT(YEAR FROM sysdate) AND EXTRACT(YEAR from B.pay_date) = EXTRACT(YEAR FROM sysdate)-1
);

/*
TESTING:
We insert values into table TICKETS 2 fines on April 2017 & 2018, to see if the query works
April 2017: total income of 1000 €
April 2018: total income of 2000 €
-- Difference of income: 1000 € ---
 */

/*
INSERTIONS:

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

--deletes *******************************************

delete from tickets where obs1_veh = '1234XWE';
delete from tickets where obs1_veh = '4444ABC';

delete from observations values('1234XWE');
delete from observations values('1234XWF');
delete from observations values('4444ABC');
delete from observations values('4444ACC');

delete from vehicles values('1234XWE');
delete from vehicles values('1234XWF');
delete from vehicles values('4444ABC');
delete from vehicles values('4444ACC');

*/
