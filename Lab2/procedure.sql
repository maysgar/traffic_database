--Daily sanctions
/*
whenever the car speed is higher than allowed, or when we acquire two observations
of the same vehicle on the same road in different mile markers more distant than
what can be legally covered in that lapse of time, or even when the safety distance
is not observed.
The amount of the fine is 10 € for each km/h above the speed limit (rounded
high). The minimum safety distance is one meter for every km/h of
speed. Safety lapse is the time required to cover the safety distance (regardless of
the speed, the time between any two vehicles has to be equal or above 3.6 seconds).
Therefore, it is considered that any vehicle does not observe the safety distance if
there is a previous observation of the same radar in less than that time. The fine
is 10€ for each tenth of a second less than the minimum during this period (rounded
high).
and the penalty applied if the payment fulfilled later than due (the fine is doubled).
*/

CREATE OR REPLACE PROCEDURE daily_sanctions IS

  total_amount INTEGER := 0;

  CURSOR fines IS
    SELECT nPlate, owner, odatetime, speed, a.road, speedlim, a.Km_point, a.direction
    FROM RADARS a JOIN OBSERVATIONS b ON a.road = b.road AND a.Km_point = b.Km_point AND a.direction = b.direction
    NATURAL JOIN VEHICLES JOIN PERSONS ON owner = dni;

  CURSOR aux IS
    SELECT nPlate, owner, odatetime, speed, a.road, speedlim, a.Km_point, a.direction
    FROM RADARS a JOIN OBSERVATIONS b ON a.road = b.road AND a.Km_point = b.Km_point AND a.direction = b.direction
    NATURAL JOIN VEHICLES JOIN PERSONS ON owner = dni;

BEGIN
    IF fines %ISOPEN THEN
      CLOSE fines;
    END IF;

    FOR i IN fines
    LOOP
      total_amount := exceeding_max_speed(i.nPlate,i.road,i.km_point,i.direction,i.odatetime);
      /*
        Segundo if para delimitar secciones y safety distance
      */
      FOR j IN aux
      LOOP
        total_amount := total_amount + exceeding_section_speed(i.nPlate,i.road,i.km_point,i.direction,j.km_point);
        total_amount := total_amount + safety_distance(i.nPlate,j.nPlate,i.road,i.km_point,i.direction);
      END LOOP;
      --INSERT
      IF total_amount > 0 THEN
        --Revisar bien todos los campos
        INSERT INTO TICKETS VALUES(i.nPlate,i.odatetime,'','','',sysdate,sysdate+20,'',total_amount,i.owner,'R');
      END IF;
      total_amount := 0;
    END LOOP;
END daily_sanctions;
/******************************************************************************/
/*
Va a haber peleas porque deberemos de ir acumulando la cantidad en dinero
  de cada owner
*/
/******************************************************************************/

/*
total_amount := exceeding_section_speed(i.nPlate,i.road,i.km_point,i.direction, km_point_input_2);
total_amount := safety_distance(i.nPlate, vehicle_input_2, i.road, i.km_point, i.direction);
*/
