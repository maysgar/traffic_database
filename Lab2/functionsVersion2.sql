set serveroutput on;
/*
  All "amount sanctions" have been made with the thought that a vehicle(s) and a radar(s)
  are involved and have to be given as an input
*/

CREATE OR REPLACE FUNCTION exceeding_max_speed (obs OBSERVATIONS%ROWTYPE)
RETURN NUMBER
IS
  amount_fine INTEGER := 10;
  partial_amount INTEGER := 0;
  total_amount INTEGER := 0;

  CURSOR speedlimOfRadar(obs OBSERVATIONS%ROWTYPE) IS
    SELECT speedlim
    FROM OBSERVATIONS NATURAL JOIN RADARS
    WHERE nPlate = obs.nPlate AND road = obs.road AND km_point = obs.km_point
      AND direction = obs.direction AND odatetime = obs.odatetime;

BEGIN

    IF speedlimOfRadar %ISOPEN THEN
      CLOSE speedlimOfRadar;
    END IF;

    FOR i IN speedlimOfRadar(obs)
    LOOP
      IF obs.speed > i.speedlim THEN
        partial_amount := partial_amount + (obs.speed - i.speedlim);
      END IF;
    END LOOP;

    total_amount := CEIL(partial_amount*amount_fine);

    DBMS_OUTPUT.PUT_LINE(total_amount);
    RETURN total_amount;
END;

/*
PRUEBAS:

declare
  a OBSERVATIONS%ROWTYPE;
  result number;
begin
  a.nPlate := '3422AEU';
  a.speed := 110;
  a.road := 'M50';
  a.direction := 'ASC';
  a.km_point := 15;
  a.odatetime := TO_TIMESTAMP('2009-07-21 21.47.40.780000','YYYY-MM-DD HH24.MI.SS.FF');
  result := exceeding_max_speed(a);
end;

declare
  a OBSERVATIONS%ROWTYPE;
  result number;
begin
  a.nPlate := '9200IIA';
  a.speed := 145;
  a.road := 'M45';
  a.direction := 'DES';
  a.km_point := 29;
  a.odatetime := TO_TIMESTAMP('2010-05-07 01.15.30.290000','YYYY-MM-DD HH24.MI.SS.FF');
  result := exceeding_max_speed(a);
end;

declare
  a OBSERVATIONS%ROWTYPE;
  result number;
begin
  a.nPlate := '7919AEO';
  a.speed := 147;
  a.road := 'M50';
  a.direction := 'ASC';
  a.km_point := 75;
  a.odatetime := TO_TIMESTAMP('2010-09-03 23.24.33.540000','YYYY-MM-DD HH24.MI.SS.FF');
  result := exceeding_max_speed(a);
end;

declare
  a OBSERVATIONS%ROWTYPE;
  result number;
begin
  a.nPlate := '1479IUA';
  a.speed := 280; --Any speed  in this especific case
  a.road := 'A6';
  a.direction := 'ASC';
  a.km_point := 171;
  a.odatetime := TO_TIMESTAMP('2009-07-21 21.47.40.780000','YYYY-MM-DD HH24.MI.SS.FF');
  result := exceeding_max_speed(a);
end;

Results expected:
- 100€ ok
- 650€ ok
- 470€ ok
- 0€ ok
*/

-- Amount for a ‘exceeding section speed’ radar sanction.
CREATE OR REPLACE FUNCTION exceeding_section_speed (obs OBSERVATIONS%ROWTYPE)
RETURN NUMBER
IS
BEGIN
--Call of obs_right_after_vehicle
END;

/*
PRUEBAS:

*/

-- Amount for a ‘safety distance’ radar sanction.
CREATE OR REPLACE FUNCTION safety_distance (obs OBSERVATIONS%ROWTYPE)
RETURN NUMBER
IS
BEGIN
--Call of obs_right_after_radar
END;

/*
PRUEBAS:

*/

-- Observation immediately prior to a given observation (of the same radar)
CREATE OR REPLACE FUNCTION obs_right_after_radar (obs OBSERVATIONS%ROWTYPE)
RETURN OBSERVATIONS%ROWTYPE
IS
  bool NUMBER := 0;
  obs2 OBSERVATIONS%ROWTYPE;
  CURSOR aux (obs OBSERVATIONS%ROWTYPE) IS
    SELECT *
    FROM OBSERVATIONS
    WHERE road = obs.road AND direction = obs.direction AND km_point = obs.km_point
    ORDER BY odatetime ASC;
BEGIN
    IF aux %ISOPEN THEN
      CLOSE aux;
    END IF;
    FOR i IN aux(obs)
    LOOP
      IF obs.odatetime < i.odatetime THEN
        bool := 1;
        --Set the immediate observation
        obs2.nPlate := i.nPlate;
        obs2.odatetime := i.odatetime;
        obs2.road := i.road;
        obs2.km_point := i.km_point;
        obs2.direction := i.direction;
        obs2.speed := i.speed;
      END IF;
      EXIT WHEN bool = 1;
    END LOOP;
    RETURN obs2;
END;

/*
PRUEBAS:

declare
  a OBSERVATIONS%ROWTYPE;
  result OBSERVATIONS%ROWTYPE;
begin
  a.road := 'M50';
  a.km_point := 15;
  a.direction := 'ASC';
  a.odatetime := TO_TIMESTAMP('2012-01-14 13.09.00.360000','YYYY-MM-DD HH24.MI.SS.FF');
  result:=obs_right_after_radar(a);
end;

Results expected:
  SELECT odatetime
  FROM OBSERVATIONS
  WHERE road = 'M50' AND direction = 'ASC' AND km_point = '15'
  ORDER BY odatetime ASC;

  -Input: 14-JAN-12 13:09:00.36
  -Next observation (same radar): 14-JAN-12 23:12:26.67
  ok
*/

-- Observation immediately prior to a given observation (of the same vehicle)
CREATE OR REPLACE FUNCTION obs_right_after_vehicle (obs OBSERVATIONS%ROWTYPE)
RETURN OBSERVATIONS%ROWTYPE
IS
  obs2 OBSERVATIONS%ROWTYPE;
  bool INTEGER := 0;
  CURSOR aux (obs OBSERVATIONS%ROWTYPE) IS
    SELECT *
    FROM OBSERVATIONS
    WHERE nPlate = obs.nPlate
    ORDER BY odatetime ASC;
BEGIN
    IF aux %ISOPEN THEN
      CLOSE aux;
    END IF;
    FOR i IN aux(obs)
    LOOP
      IF obs.odatetime < i.odatetime THEN
        bool := 1;
        --Set the immediate observation
        obs2.nPlate := i.nPlate;
        obs2.odatetime := i.odatetime;
        obs2.road := i.road;
        obs2.km_point := i.km_point;
        obs2.direction := i.direction;
        obs2.speed := i.speed;
      END IF;
      EXIT WHEN bool = 1;
    END LOOP;
    RETURN obs2;
END;

/*
PRUEBAS:

declare
  a OBSERVATIONS%ROWTYPE;
  result OBSERVATIONS%ROWTYPE;
begin
  a.nPlate := '3422AEU';
  a.odatetime := TO_TIMESTAMP('2011-12-29 08.53.30.400000','YYYY-MM-DD HH24.MI.SS.FF');
  result:=obs_right_after_vehicle(a);
end;

Results expected:
  SELECT odatetime
  FROM OBSERVATIONS
  WHERE nPlate = '3422AEU'
  ORDER BY odatetime ASC;

  -Input: 29-DEC-11 08:53:30.40
  -Next observation (same vehicle): 29-DEC-11 10:36:26.33
  ok
*/
