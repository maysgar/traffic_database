/*----------------------------QUERY A--------------------------*/
SELECT n_plate, COUNT(n_plate) AS appearance
FROM OBSERVATIONS
WHERE ROWNUM = 10 AND date = sysdate
ORDER BY appearance DESC
WITH READ ONLY CONSTRAINT R_ONLY;

/*----------------------------QUERY B--------------------------*/
SELECT speed_limit, name
FROM(
SELECT speed_limit
FROM ROADS
ORDER BY speed_limit DESC
??
SELECT name
FROM ROADS
ORDER BY name ASC
)
WITH READ ONLY CONSTRAINT R_ONLY;

/*----------------------------QUERY C--------------------------*/
SELECT name, surname
FROM(
  PERSONS NATURAL JOIN (SELECT DISTINCT person FROM DRIVERS DISJOINT VEHICLES)
);

/*----------------------------QUERY D--------------------------*/
SELECT name, surname, COUNT(n_plate) AS vehicles_owned
FROM PEOPLE
WHERE vehicles_owned >= 3 AND
WITH READ ONLY CONSTRAINT R_ONLY;

/*----------------------------QUERY E--------------------------*/
