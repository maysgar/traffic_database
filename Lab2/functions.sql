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

--Es cumulativo, por cada observacion realizada en dicho radar ???

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

CREATE OR REPLACE FUNCTION safety_distance (vehicle_input_1 VARCHAR2, vehicle_input_2 VARCHAR2,
 road_input VARCHAR2, km_point_input NUMBER, direction_input VARCHAR2)
RETURN NUMBER
IS
  date_1 VARCHAR2(28);
  date_2 VARCHAR2(28);
  distance NUMBER(3);
  time_elapsed INTEGER := 0;
  total_amount NUMBER(4);
  boolean_aux INTEGER := 0;
  amount_fine INTEGER := 10;

  CURSOR vehicle_to_be_fined (vehicle_input_1 VARCHAR2, vehicle_input_2 VARCHAR2, road_input VARCHAR2,
   km_point_input NUMBER, direction_input VARCHAR2) IS
    SELECT nPlate, speed, road, speed_limit, km_point, direction, odatetime
    FROM OBSERVATIONS a JOIN ROADS b
    ON a.road = b.name
    WHERE nPlate = vehicle_input_1 AND road = road_input AND km_point = km_point_input
      AND direction = direction_input;

  CURSOR vehicle_2 (vehicle_input_1 VARCHAR2, vehicle_input_2 VARCHAR2, road_input VARCHAR2,
   km_point_input NUMBER, direction_input VARCHAR2) IS
    SELECT nPlate, speed, road, speed_limit, km_point, direction, odatetime
    FROM OBSERVATIONS a JOIN ROADS b
    ON a.road = b.name
    WHERE nPlate = vehicle_input_2 AND road = road_input AND km_point = km_point_input
      AND direction = direction_input;

BEGIN
    IF vehicle_to_be_fined %ISOPEN THEN
      CLOSE vehicle_1;
    END IF;
    IF vehicle_2 %ISOPEN THEN
      CLOSE vehicle_2;
    END IF;

    FOR i IN vehicle_to_be_fined(vehicle_input_1,vehicle_input_2,road_input,km_point_input,direction_input)
    LOOP
      date_1 := CAST(i.odatetime AS VARCHAR2(28));
      FOR i IN vehicle_2(vehicle_input_1,vehicle_input_2,road_input,km_point_input,direction_input)
      LOOP
        date_2 := CAST(i.odatetime AS VARCHAR2(28));
        --calculo de la diferencia entre observaciones
        time_elapsed := TO_NUMBER(TO_DATE(date_1, 'SS.FF')) - TO_NUMBER(TO_DATE(date_2, 'SS.FF'));
        IF TO_DATE(date_1, 'MM-DD-YY') = TO_DATE(date_2, 'MM-DD-YY') AND
           THEN
          boolean_aux := 1;
          time_elapsed := ABS(3.6-time_elapsed);
          EXIT WHEN boolean_aux = 1;
        END IF;
      END LOOP;
      EXIT WHEN boolean_aux = 1;
    END LOOP;

    --ACCESS HERE WHEN THE time_elapsed HAS BEEN CALCULATED AND THE EXIT COMMAND
    --HAS BEEN EXECUTED.
    total_amount := CEIL(time_elapsed*amount_fine);
    BMS_OUTPUT.PUT_LINE(total_amount);
    RETURN total_amount;

END; /

-- Observation immediately prior to a given observation (of the same radar)

CREATE OR REPLACE FUNCTION obs_right_after_radar ()
RETURN OBSERVATIONS%ROWTYPE AS obs_row_f1%ROWTYPE;
BEGIN
END; /

-- Observation immediately prior to a given observation (of the same vehicle)

CREATE OR REPLACE FUNCTION obs_right_after_vehicle ()
RETURN OBSERVATIONS%ROWTYPE AS obs_row_f2%ROWTYPE;
BEGIN
END; /
