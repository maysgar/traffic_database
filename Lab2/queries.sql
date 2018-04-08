/*----------------------------QUERY A--------------------------*/
/* The top 10 vehicles most 'observed' in the course of today. */

--NICEEEEEE (0)

SELECT nPlate, COUNT(nPlate) AS appearance
FROM OBSERVATIONS
WHERE ROWNUM = 10 AND odatetime = sysdate
GROUP BY nPlate
ORDER BY appearance DESC;

/*
Algo asi pa chequear que la query se hace

SELECT * FROM(
SELECT nPlate, COUNT(nPlate) AS appearance
FROM OBSERVATIONS a, OBSERVATIONS b
WHERE a.odatetime = b.odatetime
GROUP BY nPlate
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

SELECT name, surn_1 FROM(
SELECT dni FROM drivers A
FULL OUTER JOIN
SELECT dni FROM persons B
ON A.dni = B.dni
WHERE A.dni IS NULL OR B.dni IS NULL
);

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
SELECT EXTRACT(MONTH from pay_date) AS actual_month, EXTRACT(YEAR from pay_date) AS actual_year, COUNT(amount) as actual_income
FROM tickets
WHERE EXTRACT(MONTH from pay_date) = EXTRACT(MONTH FROM sysdate)
AND EXTRACT(YEAR from pay_date) = EXTRACT(YEAR FROM sysdate)
GROUP BY pay_date
)
WHERE actual_year = last_year-1 AND actual_month = last_month;
