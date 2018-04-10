--Daily sanctions
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
  WHERE SYSDATE = odatetime;

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
