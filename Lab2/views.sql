
/* a) New sanction type: it is under study to set a new sanction for abnormally
reduced speed (half of the upper limit of the general speed limit on the road).
Do a view that provides the infringing vehicles, the date, and the speed difference
with the legal margin, to support the analysis of the convenience of this norm. */

CREATE OR REPLACE VIEW sanction_low_speed AS
SELECT nPlate, odatetime, ((speedlim/2) - speed) AS speed_difference
FROM(
    SELECT road, Km_point, direction FROM OBSERVATIONS A
    NATURAL JOIN
    SELECT road, km_point, direction FROM RADARS B
    ON A.road = B.road, A.Km_point = B.Km_point, A.direction = B.direction
)
WHERE speed <= (speedlim/2);

/* b) Monthly Whinger: drivers with more allegations rejected for each month. */
CREATE OR REPLACE VIEW monthly_whinger AS
SELECT debtor, month, COUNT(reg_date)
FROM(
    SELECT debtor FROM TICKETS AS A
    NATURAL JOIN
    SELECT month, reg_date FROM ALLEGATIONS AS B
)
WHERE status = 'R';

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