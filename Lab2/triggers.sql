--a) Insert tickets



/*
b) Process allegations: if the new debtor is not assigned to the vehicle,
 it will be rejected; if he/she is assigned, it will be approved unless he/she
 has already alleged the same ticket (in such cases, new state will be under
 study).
*/



/*c) King_is_dead: when a regular driver dies (the attribute is nullified in
  the row of the vehicle) a new regular driver will be assigned from among
  those assigned to that vehicle (the one with older driving license). If there
  were none, the operation will be prevented.
*/



/*d) Restrictions: observe that the speed of any radar is less than or equal
  to the general speed of the road, and that drivers are at least 18 years old.
*/
CREATE OR REPLACE TRIGGER restriction_speed_radar
BEFORE INSERT OR UPDATE
ON RADARS
FOR EACH ROW
DECLARE
  spot INTEGER := 0;
  speedlimit INTEGER := 0;
BEGIN
  --Selecting the speed limits of the radar and road
  SELECT speed_limit INTO speedlimit FROM(
    SELECT speed_limit FROM ROADS WHERE :new.road = name);

  SELECT COUNT(*) INTO spot FROM(
    SELECT road,km_point,direction FROM RADARS WHERE road = :new.road AND km_point = :new.km_point AND direction = :new.direction);
  --If there is already a radar in the same spot...
  IF spot > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Radar cannot be registered: Already a radar in that spot');
  END IF;

  IF :new.speedlim > speedlimit THEN
    RAISE_APPLICATION_ERROR(-20001, 'Radar cannot be registered, speed is above the permitted');
  END IF;
END restriction_speed_radar;

/*
  Pruebas:

  INSERT INTO RADARS VALUES('M50',323,'ASC',200);
  INSERT INTO RADARS VALUES('A1',217,'ASC',80);
  INSERT INTO RADARS VALUES('M50',401,'DES',100);

  Expected:
  - above speed
  - same spot
  - normal speed
*/

CREATE OR REPLACE TRIGGER restriction_driver_age
BEFORE INSERT OR UPDATE
ON PERSONS
FOR EACH ROW
DECLARE
identif INTEGER := 0;
BEGIN
  --Selecting the drivers' dni and drivers' age
  SELECT dni INTO identif FROM(
    SELECT dni FROM PERSONS WHERE dni = :new.dni);

  IF identif > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Person cannot be registered: Person is already registered');
  END IF;

  IF months_between(TRUNC(sysdate),:new.birthdate)/12 < 18 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Driver is under age, cannot be registered');
  END IF;
END restriction_driver_age;

/*
  Pruebas:

  INSERT INTO PERSONS VALUES('12345678P','g','g','','calle inventada','madrid','','',TO_DATE('1997-08-22','YYYY-MM-DD'));
  INSERT INTO PERSONS VALUES('12345678P','g','g','','calle inventada','madrid','','',TO_DATE('1997-08-22','YYYY-MM-DD'));
  INSERT INTO PERSONS VALUES('12345678Q','g','g','','calle inventada','madrid','','',TO_DATE('2018-01-01','YYYY-MM-DD'));

  Expected:
  - +18 years ok
  - same person 
  - <18 year ok
*/
