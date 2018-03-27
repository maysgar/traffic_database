set serveroutput on;

-- Amount for a ‘exceeding maximum speed’ radar sanction.
--SPEED SANCTION IS 10€ PER km/h ABOVE THE SPEED LIMITED ROUNDED HIGH

CREATE OR REPLACE FUNCTION exceeding_max_speed (vehicle_input VARCHAR2, road_input VARCHAR2,
 km_point_input NUMBER, direction_input VARCHAR2)
RETURN NUMBER
IS
  amount_fine INTEGER := 10;
  partial_amount NUMBER(4);
  total_amount NUMBER(4);

  CURSOR vehicle_fined (vehicle_input VARCHAR2, road_input VARCHAR2,
   km_point_input NUMBER, direction_input VARCHAR2) IS
    SELECT nPlate, speed, road, speed_limit, km_point, direction
    FROM OBSERVATIONS a JOIN ROADS b
    ON a.road = b.name
    WHERE nPlate = vehicle_input AND road = road_input AND km_point = km_point_input
      AND direction = direction_input;

BEGIN
    IF vehicle_fined %ISOPEN THEN
      CLOSE vehicle_fined;
    END IF;

    total_amount := 0;
    partial_amount := 0;

    FOR i IN vehicle_fined(vehicle_input,road_input,km_point_input,direction_input)
    LOOP
      IF i.speed > i.speed_limit THEN
        partial_amount := i.speed - i.speed_limit;
      END IF;
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
result:=exceeding_max_speed('3422AEU','M50',15,'ASC');
result:=exceeding_max_speed('9200IIA','M45',29,'DES');
result:=exceeding_max_speed('7919AEO','M50',75,'ASC');
result:=exceeding_max_speed('1479IUA','A6',171,'ASC');
end;
/

Results expected:
- 90€ ok
- 450€ ok
- 270€ ok
- 0€ ok

*/

-- Amount for a ‘exceeding section speed’ radar sanction.

CREATE OR REPLACE FUNCTION exceeding_section_speed ()
RETURN NUMBER
IS
BEGIN
END; /

-- Amount for a ‘safety distance’ radar sanction.

CREATE OR REPLACE FUNCTION safety_distance ()
RETURN NUMBER
IS
BEGIN
END; /

-- Observation immediately prior to a given observation (of the same radar)

CREATE OR REPLACE FUNCTION obs_right_after_radar ()
RETURN
IS
BEGIN
END; /

-- Observation immediately prior to a given observation (of the same vehicle)

CREATE OR REPLACE FUNCTION obs_right_after_vehicle ()
RETURN
IS
BEGIN
END; /
