/*----------------------------QUERY A--------------------------*/
/* The top 10 vehicles most 'observed' in the course of today. */
SELECT nPlate, COUNT(nPlate) AS appearance
FROM OBSERVATIONS
WHERE ROWNUM = 10 AND odatetime = sysdate
GROUP BY nPlate, appearance
ORDER BY appearance DESC;
-- WITH READ ONLY CONSTRAINT R_ONLY;

/*----------------------------QUERY B--------------------------*/
/* List of roads and their average speed limit, ordered from highest to lowest speed in the first instance and in alphabetical order of roads in second,
counting both directions. */

SELECT name, speed_limit
FROM(
SELECT name, speed_limit
FROM ROADS
ORDER BY name ASC;
)
GROUP BY name
ORDER BY speed_limit DESC;



/*----------------------------QUERY C--------------------------*/
/* People who do not drive any of their vehicles (neither as a regular driver nor
as an additional driver). */

SELECT name, surname
FROM(
  PERSONS NATURAL JOIN (SELECT DISTINCT person FROM DRIVERS DISJOINT VEHICLES)
);

/*----------------------------QUERY D--------------------------*/
/* Boss: owners of at least three cars they don’t drive. */

SELECT name, surname, COUNT(n_plate) AS vehicles_owned
FROM PEOPLE
WHERE vehicles_owned >= 3 AND
WITH READ ONLY CONSTRAINT R_ONLY;

/*----------------------------QUERY E--------------------------*/
/* Evolution: indicates the difference of income due to tickets fines between the
last month and the same month of the previous year. */

