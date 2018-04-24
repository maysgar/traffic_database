-- -----------------------------------------------------
-- -----------------------------------------------------
-- --  2nd Assignment script  -------  Starting Point  -
-- -----------------------------------------------------
-- - Warning! - Spoiler: some solutions to 1st Asgmnt. -
-- -----------------------------------------------------
-- -----------------------------------------------------
-- - (C) 2018 Giga BD - Computer Science Dpmnt. - UC3M -
-- -----------------------------------------------------
-- -----------------------------------------------------

-- -----------------------------------------------------
-- - BEFORE this script, run again CREATION script -----
-- -----------------------------------------------------
-- - AFTER this script, run again WORKLOAD script ------
-- -----------------------------------------------------


-- - Defining the package ------------------------------
-- -----------------------------------------------------

create or replace package FeelFine as
   function speed_tck(obs observations%rowtype) return number;
   function stretch_tck(obs1 observations%rowtype, obs2 observations%rowtype) return number;
   function distance_tck(obs1 observations%rowtype, obs2 observations%rowtype) return number;
   function former_car(obs observations%rowtype) return observations%rowtype;
   function former_rad(obs observations%rowtype) return observations%rowtype;
END FeelFine;

/

-- - Creating the package ------------------------------
-- -----------------------------------------------------

create or replace package body FeelFine as

function speed_tck(obs observations%rowtype) return number is
 limit number;
begin
   select speedlim into limit from radars where road=obs.road and km_point=obs.km_point and direction=obs.direction;
   if limit<obs.speed
      THEN RETURN (obs.speed-limit)*10;
      ELSE RETURN 0;
   END if;
end speed_tck;

function stretch_tck(obs1 observations%rowtype, obs2 observations%rowtype) return number is
 limit number;
 speed number;
 mileage number;
 seconds number;
begin
  IF obs2.nplate IS null
     THEN RETURN 0;
     ELSE select speedlim into limit from radars where road=obs2.road and km_point=obs2.km_point and direction=obs2.direction;
          mileage := abs(obs1.km_point-obs2.km_point);
          IF mileage>5
             THEN select speed_limit into speed from roads where name=obs1.road;
                  limit:= ((limit*5) + (speed*(mileage-5)))/mileage;
          END IF;
          seconds := (to_date(to_char(obs1.odatetime,'YYYYMMDDHHMISS'),'YYYYMMDDHHMISS') -
                      to_date(to_char(obs2.odatetime,'YYYYMMDDHHMISS'),'YYYYMMDDHHMISS') ) *24*3600 +
                     to_number('0,'||to_char(obs1.odatetime,'FF')) - to_number('0,'||to_char(obs2.odatetime,'FF')) ;
          speed := mileage * 3600 / seconds;
          if limit<speed
             THEN RETURN (speed-limit)*10;
             ELSE RETURN 0;
          END if;
  END if;
end stretch_tck;

function distance_tck(obs1 observations%rowtype, obs2 observations%rowtype) return number is
 decseconds number;
begin
  IF obs2.nplate IS null
     THEN RETURN 0;
     ELSE decseconds := ((to_date(to_char(obs1.odatetime,'YYYYMMDDHHMISS'),'YYYYMMDDHHMISS') -
                         to_date(to_char(obs2.odatetime,'YYYYMMDDHHMISS'),'YYYYMMDDHHMISS') ) *24*3600 +
                         to_number('0,'||to_char(obs1.odatetime,'FF')) - to_number('0,'||to_char(obs2.odatetime,'FF')))*10 ;
          if decseconds<36
             THEN RETURN (36-decseconds)*10;
             ELSE RETURN 0;
          END if;
  END if;
end distance_tck;

function former_car(obs observations%rowtype) return observations%rowtype is
 newobs observations%rowtype;
begin
   newobs.nplate := null;
   select * into newobs
      from (select * from observations
               where road=obs.road and km_point=obs.km_point and direction=obs.direction and odatetime<obs.odatetime
               order by odatetime desc)
      where rownum=1;
   return newobs;
exception
   when no_data_found then return newobs;
end former_car;

function former_rad(obs observations%rowtype) return observations%rowtype is
 newobs observations%rowtype;
begin
   newobs.nplate := null;
   select * into newobs
      from (select * from observations
               where road=obs.road and nplate=obs.nplate and direction=obs.direction and odatetime<obs.odatetime
               order by odatetime desc)
      where rownum=1;
   return newobs;
exception
   when no_data_found then return newobs;
end former_rad;

end FeelFine;

/

-- - Trigger for inserting Tickets ---------------------
-- -----------------------------------------------------

DROP TABLE obs_aux;
CREATE GLOBAL TEMPORARY TABLE obs_aux AS (SELECT * FROM observations WHERE 1=0);

CREATE OR REPLACE TRIGGER ins_tickets_1
AFTER INSERT ON observations FOR EACH ROW
BEGIN
    INSERT INTO obs_aux VALUES (:NEW.nplate, :NEW.odatetime, :NEW.road, :NEW.km_point, :NEW.direction, :NEW.speed);
END;

/

CREATE OR REPLACE TRIGGER ins_tickets_2
AFTER INSERT ON observations
DECLARE
  cuanto1 NUMBER;
  cuanto2 NUMBER;
  cuanto3 NUMBER;
  quien vehicles.owner%type;
  obs1 observations%rowtype;
  obs2 observations%rowtype;
BEGIN
   FOR fila in (SELECT * FROM obs_aux) LOOP
      cuanto1 := FeelFine.speed_tck(fila);
      obs1 := FeelFine.former_rad(fila);
      cuanto2 := FeelFine.stretch_tck(fila,obs1);
      obs2 := FeelFine.former_car(fila);
      cuanto3 := FeelFine.distance_tck(fila,obs2);
      IF (cuanto1+cuanto2+cuanto3)>0
         THEN SELECT owner into quien FROM vehicles where nplate=fila.nplate;
      END IF;
      IF cuanto1 >0 THEN
         INSERT INTO tickets(OBS1_VEH,OBS1_DATE,TIK_TYPE,SENT_DATE,AMOUNT,DEBTOR,STATE)
                VALUES (fila.nplate, fila.odatetime, 'S',sysdate, cuanto1, quien, 'R');
      END IF;
      IF cuanto2 >0 THEN
         INSERT INTO tickets(OBS1_VEH,OBS1_DATE,TIK_TYPE,OBS2_VEH,OBS2_DATE,SENT_DATE,AMOUNT,DEBTOR,STATE)
                VALUES (fila.nplate, fila.odatetime, 'T', obs1.nplate, obs1.odatetime, sysdate, cuanto2, quien, 'R');
      END IF;
      IF cuanto3 >0 THEN
         INSERT INTO tickets(OBS1_VEH,OBS1_DATE,TIK_TYPE,OBS2_VEH,OBS2_DATE,SENT_DATE,AMOUNT,DEBTOR,STATE)
                VALUES (fila.nplate, fila.odatetime, 'D', obs2.nplate, obs2.odatetime, sysdate, cuanto3, quien, 'R');
      END IF;
   END LOOP;

   DELETE FROM obs_aux;

END;

/


-- - A couple of views for testing ---------------------
-- -----------------------------------------------------

CREATE OR REPLACE VIEW new_ticket AS (
   SELECT A.nplate, A.idate, (B.speed_limit-A.speed) difference
      FROM (select nplate, TO_DATE(TO_CHAR(odatetime,'YYYYMMDD'),'YYYYMMDD') idate, speed, road FROM observations) A
           JOIN roads B ON (A.road=B.name AND A.speed*2<B.speed_limit) );
/

CREATE OR REPLACE VIEW qw_drivers AS
  SELECT *
    FROM (SELECT AVG(E.speed*100/F.speedlim) speed_pct, D.driver
            FROM ((SELECT nplate FROM vehicles)
                   MINUS (SELECT nplate FROM observations A JOIN radars B
                         ON(B.road=A.road AND B.km_point=A.km_point AND B.direction=A.direction AND A.speed>B.speedlim))
                 ) C
                 JOIN (SELECT nplate, reg_driver driver FROM vehicles) D ON (C.nplate=D.nplate)
                 JOIN observations E ON (C.nplate=E.nplate)
                 JOIN radars F ON(E.road=F.road AND E.km_point=F.km_point AND E.direction=F.direction)
            GROUP BY D.driver
            ORDER BY speed_pct DESC)
    WHERE ROWNUM<11;
/


-- - Altering some constraints for testing -------------
-- -----------------------------------------------------

ALTER TABLE TICKETS DROP CONSTRAINT FK_TICKETS1;
ALTER TABLE TICKETS DROP CONSTRAINT FK_TICKETS2;
ALTER TABLE TICKETS ADD CONSTRAINT FK_TICKETS1 FOREIGN KEY (obs1_date,obs1_veh) REFERENCES OBSERVATIONS ON DELETE CASCADE;
ALTER TABLE TICKETS ADD CONSTRAINT FK_TICKETS2 FOREIGN KEY (obs2_date,obs2_veh) REFERENCES OBSERVATIONS ON DELETE CASCADE;


-- - A couple of procedures for testing ----------------
-- -----------------------------------------------------

DROP SEQUENCE periods;
CREATE SEQUENCE periods;

-- Data from FSDB.MEGATABLE
CREATE OR REPLACE PROCEDURE INS_OBS(cuantos number) IS
newyear NUMBER;
begin
   SELECT periods.nextval*4 INTO newyear FROM dual;
   INSERT INTO OBSERVATIONS (nPlate,odatetime,road,km_point,direction,speed)
      SELECT DISTINCT matricula, TO_TIMESTAMP(to_char(newyear+to_number(substr(fecha_foto,1,4)))||substr(fecha_foto,5)||hora_foto,'YYYY-MM-DDHH24:MI:SS.FF2'),
                      carretera_foto,pto_km_radar,sentido_radar, velocidad_foto
      FROM FSDB.MEGATABLE
      WHERE ROWNUM <= cuantos;
end ins_obs;

/

/*
-- Data from GOTCHA
CREATE OR REPLACE PROCEDURE INS_OBS(cuantos number) IS
newyear NUMBER;
begin
   SELECT periods.nextval*4 INTO newyear FROM dual;
   INSERT INTO OBSERVATIONS (nPlate,odatetime,road,km_point,direction,speed)
      SELECT DISTINCT nPlate, TO_TIMESTAMP(to_char(newyear+to_number(substr(date1,1,4)))||substr(date1,5)||time1,'YYYY-MM-DDHH24:MI:SS.FF2'),
                      road,km_point,direction, speed
      FROM GOTCHA
      WHERE ROWNUM <= cuantos;
end ins_obs;
/
*/


/*
CREATE OR REPLACE PROCEDURE DEL_OBS(cuantos number) IS
begin
 FOR I IN (SELECT * FROM (SELECT * FROM observations ORDER BY DBMS_RANDOM.VALUE)WHERE ROWNUM<=cuantos) LOOP
  DELETE FROM OBSERVATIONS WHERE nplate=i.nplate AND odatetime=i.odatetime;
 END LOOP;
   --DELETE FROM (SELECT * FROM observations ORDER BY DBMS_RANDOM.VALUE) WHERE rownum <=cuantos;
end del_obs;

*/


CREATE OR REPLACE PROCEDURE DEL_OBS(cuantos number) IS
begin
     DELETE FROM observations
            WHERE rowid in (select r from (select rowid r, ROW_NUMBER() OVER (ORDER BY null) n from observations)
                                   where mod(n,6)=3);
end;
/


-- -----------------------------------------------------
-- - DONE!!! -------------------------------------------
-- -----------------------------------------------------
