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
BEGIN
  --Selecting the speed limits of the radar and road
  SELECT speedlim, speed_limit
  FROM RADARS a JOIN ROADS b
  ON a.road = b.name
  WHERE speedlim = :new.speedlim AND speed_limit = :new.speed_limit;

  IF :new.speedlim > :new.speed_limit THEN
    RAISE_APPLICATION_ERROR(-20001, 'Radar cannot be registered, speed is above the permitted');
  END IF;
END restriction_speed_radar;

CREATE OR REPLACE TRIGGER restriction_driver_age
BEFORE INSERT OR UPDATE
ON DRIVERS
FOR EACH ROW
BEGIN
  --Selecting the drivers' dni and drivers' age
  SELECT dni,months_between(TRUNC(sysdate)-birthdate)/12 as age
  FROM PERSONS NATURAL JOIN DRIVERS
  WHERE birthdate = :new.birthdate;

  IF months_between(TRUNC(sysdate)-:new.birthdate)/12 < 18 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Driver is under age, cannot be registered');
  END IF;
END restriction_driver_age;
