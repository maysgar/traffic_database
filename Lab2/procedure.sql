--Daily sanctions
--TODO: JOBS
CREATE OR REPLACE PROCEDURE daily_sanctions IS

  total_amount INTEGER := 0;
  amount_speed INTEGER := 0;
  amount_section INTEGER := 0;
  amount_safety INTEGER := 0;
  a OBSERVATIONS%ROWTYPE;

  CURSOR obs IS
  SELECT nPlate, odatetime, road, km_point, direction, speed, DNI FROM
  OBSERVATIONS NATURAL JOIN VEHICLES
  JOIN PERSONS ON owner = DNI
  WHERE SYSDATE = CAST(odatetime AS DATE);

BEGIN
    IF obs %ISOPEN THEN
      CLOSE obs;
    END IF;

    FOR i IN obs
    LOOP
      a.nPlate = i.nPlate;
      a.odatetime = i.odatetime;
      a.road = i.road;
      a.km_point = i.km_point;
      a.direction = i.direction;
      a.speed = i.speed;
      amount_speed := exceeding_max_speed(a);
      --amount_section := exceeding_max_section_speed(a);
      amount_safety := safety_distance(a);
      IF amount_speed > 0 OR amount_section > 0 OR amount_safety > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Daily sanction generated');
      END IF;
END daily_sanctions;

/*
PRUEBAS:

INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('10-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('11-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('12-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('13-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('14-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('15-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('16-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('17-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
INSERT INTO OBSERVATIONS VALUES('3422AEU',TO_TIMESTAMP('18-APR-18 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);

exec daily_sanctions;
*/
