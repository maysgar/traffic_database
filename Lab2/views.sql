
/* a) New sanction type: it is under study to set a new sanction for abnormally
reduced speed (half of the upper limit of the general speed limit on the road).
Do a view that provides the infringing vehicles, the date, and the speed difference
with the legal margin, to support the analysis of the convenience of this norm. */

CREATE OR REPLACE VIEW sanction_low_speed AS
  SELECT nPlate,odatetime,difference FROM(
    SELECT nPlate,speed,odatetime,speed_limit/2-speed AS difference FROM
    OBSERVATIONS NATURAL JOIN RADARS JOIN ROADS ON road = name
    WHERE speed_limit/2 >= speed)
  WHERE difference > 0;

/*
  Pruebas: --34 rows--

  SELECT nPlate,speed,road,speed_limit,difference FROM(
    SELECT nPlate,speed,speed,road,speed_limit,speed_limit/2-speed AS difference FROM
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
SELECT debtor, EXTRACT(MONTH from reg_date) AS month, COUNT(*) AS allegations
FROM(
    SELECT obs1_veh, obs1_date, tik_type FROM TICKETS AS A
    FULL OUTER JOIN
    SELECT obs1_veh, obs1_date, tik_type FROM ALLEGATIONS AS B
    ON A.obs1_veh = B.obs1_veh, A.obs1_date = B.obs1_date, A.tik_type = B.tik_type
)
WHERE status = 'R'
GROUP BY month
ORDER BY allegations DESC, month DESC;

/* c) Stretches: table that records each road section in which the speed is lower
than the general speed of the road (it contains the identification of the road,
start and end points, and speed limit in the section). */
CREATE OR REPLACE VIEW low_section AS
SELECT road, Km_point, (Km_point + 5) AS next_Km_point, speedlim
FROM(
    SELECT name FROM ROADS AS A
    NATURAL JOIN
    SELECT roads FROM RADARS AS B
    ON A.name = B.roads
)
WHERE speedlim < speed_limit;


/* d) Quick-Witted Drivers: the ten drivers whose average speed is closest to those
of the road without exceeding it. Tip: base the calculation on the percentage of
the maximum speed that each observation records. */
CREATE OR REPLACE VIEW quickWitted_drivers AS
SELECT DNI
FROM
WHERE ROWNUM = 10;
