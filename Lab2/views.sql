
/* a) New sanction type: it is under study to set a new sanction for abnormally
reduced speed (half of the upper limit of the general speed limit on the road).
Do a view that provides the infringing vehicles, the date, and the speed difference
with the legal margin, to support the analysis of the convenience of this norm. */

CREATE OR REPLACE VIEW sanction_low_speed AS
  SELECT nPlate,odatetime,difference FROM(
    SELECT nPlate,speed,odatetime,speed_limit/2-speed AS difference FROM
    OBSERVATIONS JOIN ROADS ON road = name
    WHERE speed_limit/2 >= speed)
  WHERE difference > 0;

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
    WHERE status = 'R' AND debtor = dni
)
GROUP BY debtor, reg_date
ORDER BY month DESC;

/* c) Stretches: table that records each road section in which the speed is lower
than the general speed of the road (it contains the identification of the road,
start and end points, and speed limit in the section). */
--HECHA
--181 rows
CREATE OR REPLACE VIEW Stretches AS
SELECT DISTINCT R1.km_point AS start_point, CASE WHEN ABS(R1.km_point-R2.km_point) > 5 THEN R1.km_point+5
        ELSE R2.km_point END AS end_point, R1.road, R1.speedlim
  FROM RADARS R1, RADARS R2 JOIN ROADS ON name = road
  WHERE R1.km_point < R2.km_point AND R1.road = R2.road AND R1.direction = R2.direction AND R1.km_point != R2.km_point AND R1.speedlim < speed_limit ;

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
