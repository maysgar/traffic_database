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
  a.odatetime := TO_TIMESTAMP('21-JUL-09 21.47.40.780000','DD-MON-YY HH24.MI.SS.FF');
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
  a.odatetime := TO_TIMESTAMP('07-MAY-10 01.15.30.290000','DD-MON-YY HH24.MI.SS.FF');
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
  a.odatetime := TO_TIMESTAMP('03-SEP-10 23.24.33.540000','DD-MON-YY HH24.MI.SS.FF');
  result := exceeding_max_speed(a);
end;

declare
  a OBSERVATIONS%ROWTYPE;
  result number;
begin
  a.nPlate := '6648AEO';
  a.speed := 51;
  a.road := 'M45';
  a.direction := 'DES';
  a.km_point := 20;
  a.odatetime := TO_TIMESTAMP('29-JUN-11 18.05.57.740000','DD-MON-YY HH24.MI.SS.FF');
  result := exceeding_max_speed(a);
end;

Results expected:
- 100€ ok
- 650€ ok
- 470€ ok
- 0€ ok
*/

CREATE OR REPLACE FUNCTION exceeding_section_speed (obs OBSERVATIONS%ROWTYPE)
RETURN NUMBER
IS
  obs2 OBSERVATIONS%ROWTYPE;
  time_diff FLOAT := 0;
  total_amount FLOAT := 0;
  road_speed_limit INTEGER := 0;
  CURSOR speed_road(obs OBSERVATIONS%ROWTYPE) IS
  SELECT speed_limit INTO road_speed_limit FROM roads WHERE name = obs.road;
BEGIN
    obs2 := obs_right_after_vehicle(obs);
    --If we are guaranteed to be on a section...
    --Section is delimited by 5 km or less, to know this:
	  /*
		  SELECT DISTINCT R1.km_point AS start_point, CASE WHEN ABS(R1.km_point-R2.km_point) > 5 THEN R1.km_point+5
          ELSE R2.km_point END AS end_point
		  FROM RADARS R1, RADARS R2 JOIN ROADS ON name = road
		  WHERE R1.km_point < R2.km_point AND R1.road = R2.road AND R1.direction = R2.direction AND R1.km_point != R2.km_point AND R1.speedlim < speed_limit ;

	  */
	  --Primer if revisar
    IF obs.km_point < obs2.km_point THEN
      --And if we the observations were made in the same road and direction...
      IF obs.road = obs2.road AND obs.direction = obs2.direction THEN
        --In the same day, month, year and hour...
        IF TO_CHAR(obs.odatetime,'DD-MON-YY HH24') = TO_CHAR(obs2.odatetime,'DD-MON-YY HH24') THEN
        --If the two observations correspond to the same car
          IF  obs.nPlate = obs2.nPlate THEN
            time_diff := (TO_NUMBER(EXTRACT(MINUTE FROM obs2.odatetime))-TO_NUMBER(EXTRACT(MINUTE FROM obs.odatetime)))*3600;
            IF TO_NUMBER(EXTRACT(SECOND FROM obs2.odatetime)) >= TO_NUMBER(EXTRACT(SECOND FROM obs.odatetime)) THEN
              time_diff := time_diff + TO_NUMBER(EXTRACT(SECOND FROM obs2.odatetime)) - TO_NUMBER(EXTRACT(SECOND FROM obs2.odatetime));
            END IF;
            IF TO_NUMBER(EXTRACT(SECOND FROM obs2.odatetime)) < TO_NUMBER(EXTRACT(SECOND FROM obs.odatetime)) THEN
              time_diff := time_diff + TO_NUMBER(EXTRACT(SECOND FROM obs2.odatetime)) + (60 - TO_NUMBER(EXTRACT(SECOND FROM obs.odatetime)));
            END IF;

          total_amount := ((((obs2.km_point - obs.km_point)*3600)/time_diff) - road_speed_limit)*10;
          END IF;
        END IF;
      END IF;
    END IF;

    DBMS_OUTPUT.PUT_LINE(total_amount);
    RETURN total_amount;
END;
/

/*
PRUEBAS:

15-MAY-11 4.20.47.690000 - M30 - DES - 26
15-MAY-11 4.15.23.450000 - M30 - DES - 30
6525AEI

declare
  a OBSERVATIONS%ROWTYPE;
  result number;
begin
  a.nPlate := '';
  a.speed := ;
  a.road := '';
  a.direction := '';
  a.km_point := ;
  a.odatetime := TO_TIMESTAMP('','DD-MON-YY HH24.MI.SS.FF');
  result := exceeding_section_speed(a);
end;
*/

-- Amount for a ‘safety distance’ radar sanction.
CREATE OR REPLACE FUNCTION safety_distance (obs OBSERVATIONS%ROWTYPE)
RETURN NUMBER
IS
  obs2 OBSERVATIONS%ROWTYPE;
  partial_amount FLOAT := 0;
  total_amount FLOAT := 0;
  amount_fine FLOAT := 10;
  time_elapsed FLOAT := 0;
BEGIN
    obs2 := obs_right_after_radar(obs);
    IF TO_CHAR(obs.odatetime,'DD-MON-YY HH24.MI') = TO_CHAR(obs2.odatetime,'DD-MON-YY HH24.MI') THEN
      time_elapsed := ABS(TO_NUMBER(EXTRACT(SECOND FROM obs.odatetime))-TO_NUMBER(EXTRACT(SECOND FROM obs2.odatetime)));
      IF time_elapsed < 3.6 AND obs.nPlate != obs2.nPlate THEN
        partial_amount := 3.6-time_elapsed;
      END IF;
    ELSE
      partial_amount := 0;
    END IF;

    total_amount := CEIL(partial_amount*amount_fine);
    DBMS_OUTPUT.PUT_LINE(total_amount);
    RETURN total_amount;
END;

/*
PRUEBAS:
Insert two new rows just see if the function is calcultaing good the fine amount:

insert into vehicles values('1234XWE','abcasdasadasdbasd','Seta','Cardus','black',to_date('10-JUL-97','DD-MON-YY'),to_date('10-JUL-97','DD-MON-YY'),'65871451A','48906593Z');
insert into vehicles values('4444ABC','abcasdasadaszbasd','Seta','Champi','black',to_date('10-JUL-97','DD-MON-YY'),to_date('10-JUL-97','DD-MON-YY'),'93655750A','48906593Z');

insert into observations values('1234XWE',TO_TIMESTAMP('19-MAR-10 09.00.00.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);
insert into observations values('4444ABC',TO_TIMESTAMP('19-MAR-10 09.00.02.000000','DD-MON-YY HH24.MI.SS.FF'),'A1',76,'ASC',134);

delete from observations where nplate = '1234XWE';
delete from observations where nplate = '4444ABC';
delete from vehicles where nplate = '1234XWE';
delete from vehicles where nplate = '4444ABC';

The two cars go with the same speed and both observations are done by the same radar
and the second car is not respecting the safety distance, it should be fined with
16€. - ok

declare
  a OBSERVATIONS%ROWTYPE;
  result number;
begin
  a.nPlate := '4444ABC';
  a.speed := 134;
  a.road := 'A1';
  a.direction := 'ASC';
  a.km_point := 76;
  a.odatetime := TO_TIMESTAMP('19-MAR-10 09.00.02.000000','DD-MON-YY HH24.MI.SS.FF');
  result := safety_distance(a);
end;
*/

-- Observation immediately prior to a given observation (of the same radar)
CREATE OR REPLACE FUNCTION obs_right_after_radar (obs OBSERVATIONS%ROWTYPE)
RETURN OBSERVATIONS%ROWTYPE
IS
  bool NUMBER := 0;
  obs2 OBSERVATIONS%ROWTYPE;
  CURSOR aux (obs OBSERVATIONS%ROWTYPE) IS
    SELECT odatetime,LAG(nPlate) OVER (ORDER BY odatetime ASC) AS prior_nPlate, LAG(odatetime) OVER (ORDER BY odatetime ASC) AS prior_odatetime, LAG(speed) OVER (ORDER BY odatetime ASC) AS prior_speed
    FROM OBSERVATIONS
    WHERE road = obs.road AND direction = obs.direction AND km_point = obs.km_point;
BEGIN
    IF aux %ISOPEN THEN
      CLOSE aux;
    END IF;
    FOR i IN aux(obs)
    LOOP
      IF obs.odatetime = i.odatetime THEN
        bool := 1;
        --Set the immediate observation
        obs2.nPlate := i.prior_nPlate;
        obs2.odatetime := i.prior_odatetime;
        obs2.road := obs.road;
        obs2.km_point := obs.km_point;
        obs2.direction := obs.direction;
        obs2.speed := i.prior_speed;
      END IF;
      EXIT WHEN bool = 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(obs2.nPlate);
    DBMS_OUTPUT.PUT_LINE(obs2.odatetime);
    DBMS_OUTPUT.PUT_LINE(obs2.speed);
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
  a.odatetime := TO_TIMESTAMP('14-JAN-12 23.12.26.670000','DD-MON-YY HH24.MI.SS.FF');
  result:=obs_right_after_radar(a);
end;

Results expected:
  -Input: (6560AII), (119km/h), 14-JAN-12 23:12:26.67
  -Prior observation (same radar): 2339OOI, 113km/h, 14-JAN-12 13:09:00.36
  ok
*/

-- Observation immediately prior to a given observation (of the same vehicle)
CREATE OR REPLACE FUNCTION obs_right_after_vehicle (obs OBSERVATIONS%ROWTYPE)
RETURN OBSERVATIONS%ROWTYPE
IS
  obs2 OBSERVATIONS%ROWTYPE;
  bool INTEGER := 0;
  CURSOR aux (obs OBSERVATIONS%ROWTYPE) IS
    SELECT odatetime,LAG(odatetime) OVER (ORDER BY odatetime ASC) AS prior_odatetime, LAG(road) OVER (ORDER BY odatetime ASC) AS prior_road, LAG(direction) OVER (ORDER BY odatetime ASC) AS prior_direction, LAG(km_point) OVER (ORDER BY odatetime ASC) AS prior_km_point, LAG(speed) OVER (ORDER BY odatetime ASC) AS prior_speed
    FROM OBSERVATIONS
    WHERE nPlate = obs.nPlate;
BEGIN
    IF aux %ISOPEN THEN
      CLOSE aux;
    END IF;
    FOR i IN aux(obs)
    LOOP
      IF obs.odatetime = i.odatetime THEN
        bool := 1;
        --Set the immediate observation
        obs2.nPlate := obs.nPlate;
        obs2.odatetime := i.prior_odatetime;
        obs2.road := i.prior_road;
        obs2.km_point := i.prior_km_point;
        obs2.direction := i.prior_direction;
        obs2.speed := i.prior_speed;
      END IF;
      EXIT WHEN bool = 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(obs2.road);
    DBMS_OUTPUT.PUT_LINE(obs2.odatetime);
    DBMS_OUTPUT.PUT_LINE(obs2.speed);
    DBMS_OUTPUT.PUT_LINE(obs2.direction);
    DBMS_OUTPUT.PUT_LINE(obs2.km_point);
    RETURN obs2;
END;

/*
PRUEBAS:

declare
  a OBSERVATIONS%ROWTYPE;
  result OBSERVATIONS%ROWTYPE;
begin
  a.nPlate := '3422AEU';
  a.odatetime := TO_TIMESTAMP('29-DEC-11 10.36.26.330000','DD-MON-YY HH24.MI.SS.FF');
  result:=obs_right_after_vehicle(a);
end;

Results expected:
  SELECT odatetime,road,speed,direction,km_point
  FROM OBSERVATIONS
  WHERE nPlate = '3422AEU'
  ORDER BY odatetime ASC;

  -Input: 29-DEC-11 10:36:26.33, (A6), (99km/h), (DES), (60)
  -Prior observation (same vehicle): 29-DEC-11 08:53:30.40, A6, 118km/h, DES, 198
  ok
*/
