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
CREATE OR REPLACE FUNCTION exceeding_section_speed (vehicle_input VARCHAR2, road_input VARCHAR2,
 km_point_input_1 NUMBER, direction_input VARCHAR2, km_point_input_2 NUMBER)
RETURN NUMBER
IS
  date_1 VARCHAR2(28);
  date_2 VARCHAR2(28);
  amount_fine INTEGER := 10;
  partial_amount NUMBER(4);
  total_amount NUMBER(4);
  begin_section INTEGER := 0;
  end_section INTEGER := 0;
  section_km INTEGER := 0;
  boolean_aux INTEGER := 0;
  max_speed INTEGER := 0;

  --Two radars are input as we want a section to be observed
  --Same car has been observed in two radars, likely in the same section
  CURSOR vehicle_fined_radar_1 (vehicle_input VARCHAR2, road_input VARCHAR2,
   km_point_input_1 NUMBER, direction_input VARCHAR2) IS
    SELECT nPlate, speed, road, speedlim, km_point, direction, odatetime
    FROM OBSERVATIONS NATURAL JOIN RADARS
    WHERE nPlate = vehicle_input AND road = road_input AND km_point = km_point_input_1
      AND direction = direction_input;

  CURSOR vehicle_fined_radar_2 (vehicle_input VARCHAR2, road_input VARCHAR2,
   km_point_input_2 NUMBER, direction_input VARCHAR2) IS
    --SELECT nPlate, speed, road, speed_limit, km_point, direction, odatetime
    SELECT nPlate, speed, road, speedlim, km_point, direction, odatetime
    FROM OBSERVATIONS NATURAL JOIN RADARS
    --FROM OBSERVATIONS a JOIN ROADS b
    --ON a.road = b.name
    WHERE nPlate = vehicle_input AND road = road_input AND km_point = km_point_input_2
      AND direction = direction_input;

BEGIN

    IF vehicle_fined_radar_1 %ISOPEN THEN
      CLOSE vehicle_fined_radar_1;
    END IF;
    IF vehicle_fined_radar_2 %ISOPEN THEN
      CLOSE vehicle_fined_radar_2;
    END IF;

    total_amount := 0;

    FOR i IN vehicle_fined_radar_1(vehicle_input,road_input,km_point_input_1,direction_input)
    LOOP
      begin_section := i.km_point;
      date_1 := TO_CHAR(i.odatetime,'MM-DD-YY HH24.MI');
      FOR j IN vehicle_fined_radar_2(vehicle_input,road_input,km_point_input_2,direction_input)
      LOOP
        end_section := j.km_point;
        date_2 := TO_CHAR(j.odatetime,'MM-DD-YY HH24.MI');
        section_km := ABS(begin_section-end_section);
        section_km := LEAST(5,section_km);
        --Section is delimited by 5 km or by any radar is set after/before that mark
        --If the observations has been made the same exact day varying only on the seconds
        --And if the two radars delimite a section or just one, then proceed to calculate the fine
        IF date_1 = date_2 THEN
          --Select the maximum speed of both radars
          IF section_km > 5 OR section_km < 5 THEN
            max_speed := GREATEST(i.speed,j.speed);
          ELSE
            --In the section there is only one radar
            max_speed := i.speed;
          END IF;
          IF max_speed > i.speedlim THEN
            boolean_aux := 1;
            partial_amount := max_speed - i.speedlim;
            EXIT WHEN boolean_aux = 1;
          END IF;
        EXIT WHEN boolean_aux = 1;
        END IF;
      END LOOP;
      EXIT WHEN boolean_aux = 1;
    END LOOP;

    total_amount := CEIL(partial_amount*amount_fine);

    DBMS_OUTPUT.PUT_LINE(total_amount);
    RETURN total_amount;

END;

/*
PRUEBAS:


*/

-- Amount for a ‘safety distance’ radar sanction.

CREATE OR REPLACE FUNCTION safety_distance (vehicle_input_1 VARCHAR2, vehicle_input_2 VARCHAR2,
 road_input VARCHAR2, km_point_input NUMBER, direction_input VARCHAR2)
RETURN NUMBER
IS
  date_1 VARCHAR2(28);
  date_2 VARCHAR2(28);
  date_aux_1 TIMESTAMP;
  date_aux_2 TIMESTAMP;
  distance NUMBER(3);
  time_elapsed INTEGER := 0;
  total_amount NUMBER(4);
  boolean_aux INTEGER := 0;
  amount_fine INTEGER := 10;
  partial_amount INTEGER := 0;

  --  Two queries for two different vehicles observed by the same radar

  CURSOR vehicle_to_be_fined (vehicle_input_1 VARCHAR2, vehicle_input_2 VARCHAR2, road_input VARCHAR2,
   km_point_input NUMBER, direction_input VARCHAR2) IS
    SELECT nPlate, speed, road, speedlim, km_point, direction
    FROM OBSERVATIONS NATURAL JOIN RADARS
    WHERE nPlate = vehicle_input_1 AND road = road_input AND km_point = km_point_input
      AND direction = direction_input;

  CURSOR vehicle_2 (vehicle_input_1 VARCHAR2, vehicle_input_2 VARCHAR2, road_input VARCHAR2,
   km_point_input NUMBER, direction_input VARCHAR2) IS
    --SELECT nPlate, speed, road, speed_limit, km_point, direction, odatetime
    SELECT nPlate, speed, road, speedlim, km_point, direction
    FROM OBSERVATIONS NATURAL JOIN RADARS
    --FROM OBSERVATIONS a JOIN ROADS b
    --ON a.road = b.name
    WHERE nPlate = vehicle_input_2 AND road = road_input AND km_point = km_point_input
      AND direction = direction_input;

BEGIN
    IF vehicle_to_be_fined %ISOPEN THEN
      CLOSE vehicle_to_be_fined;
    END IF;
    IF vehicle_2 %ISOPEN THEN
      CLOSE vehicle_2;
    END IF;

    total_amount := 0;

    FOR i IN vehicle_to_be_fined(vehicle_input_1,vehicle_input_2,road_input,km_point_input,direction_input)
    LOOP
      date_1 := TO_CHAR(i.odatetime,'MM-DD-YY HH24.MI');
      date_aux_1 := i.odatetime;
      FOR j IN vehicle_2(vehicle_input_1,vehicle_input_2,road_input,km_point_input,direction_input)
      LOOP
        date_2 := TO_CHAR(j.odatetime,'MM-DD-YY HH24.MI');
        date_aux_2 := j.odatetime;
        time_elapsed := ABS(TO_NUMBER(EXTRACT(SECOND FROM date_aux_1)) - TO_NUMBER(EXTRACT(SECOND FROM date_aux_2)));
        /*
          If the the day, month and year side by side with the hour and the minutes
          are the same for two observations of a different vehicle, and the time_elapsed
          between two observations is less than the legal time, then a fine is produced
        */
        IF date_1 = date_2 AND time_elapsed < 3.6 THEN
          boolean_aux := 1;
          partial_amount := 3.6-time_elapsed;
          EXIT WHEN boolean_aux = 1;
        END IF;
      END LOOP;
      EXIT WHEN boolean_aux = 1;
    END LOOP;

    total_amount := CEIL(partial_amount*amount_fine);
    DBMS_OUTPUT.PUT_LINE(total_amount);
    RETURN total_amount;

END;

/*
PRUEBAS:

declare
result number;
begin
result:=safety_distance('0716AUU','7607OAA','M50',66,'ASC');
end;
/

Results expected:
- 0€ ok, no observation between the two vehicles has been made in <3.6 seconds apart.
*/

-- Observation immediately prior to a given observation (of the same radar)

CREATE OR REPLACE FUNCTION obs_right_after_radar ()
RETURN OBSERVATIONS%ROWTYPE AS obs_row_f1%ROWTYPE;
BEGIN
END;

-- Observation immediately prior to a given observation (of the same vehicle)

CREATE OR REPLACE FUNCTION obs_right_after_vehicle ()
RETURN OBSERVATIONS%ROWTYPE AS obs_row_f2%ROWTYPE;
BEGIN
END;
