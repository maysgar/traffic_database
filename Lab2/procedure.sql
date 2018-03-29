--Daily sanctions

CREATE OR REPLACE PROCEDURE daily_sanctions(today DATE) IS

  total_amount INTEGER := 0;

  CURSOR fines(today DATE) IS
    SELECT nPlate, dni, odatetime, speed, road, speed_limit, km_point, direction
    FROM RADARS JOIN OBSERVATIONS ON road = name
    NATURAL JOIN VEHICLES JOIN PERSONS ON owner = dni;

BEGIN
    IF fines %ISOPEN THEN
      CLOSE fines;
    END IF;

    FOR i IN fines(today)
    LOOP
      --calling function already created--
      total_amount := exceeding_max_speed(i.nPlate,i.road,i.km_point,i.direction);
      IF total_amount > 0 THEN
        --Revisar bien todos los campos
        INSERT INTO TICKETS VALUES(i.nPlate,,i.odatetime,'','','',sysdate,sysdate+20,'',total_amount,i.dni,'R');
      END IF;
    END LOOP;
END;
