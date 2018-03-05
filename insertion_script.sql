INSERT INTO PEOPLE (Name,Surname_1,Surname_2,Address,Town,Dni,Mobile,Email,Birth)
  (SELECT NOMBRE_DUENO,APELL_1_DUENO,APELL_2_DUENO,DIRECC_DUENO,CIUDAD_DUENO,NIF_DUENO,TO_NUMBER(TLF_DUENO,'999999999'),EMAIL_DUENO,TO_DATE(CUMPLE_DUENO,'YYYY-MM-DD')
    FROM FSDB.MEGATABLE
    UNION
  SELECT NOMBRE_CONDTR,APELL_1_CONDTR,APELL_2_CONDTR,DIRECC_CONDTR,CIUDAD_CONDTR,NIF_CONDTR,TO_NUMBER(TLF_CONDTR,'999999999'),EMAIL_CONDTR,TO_DATE(CUMPLE_CONDTR,'YYYY-MM-DD')
    FROM FSDB.MEGATABLE);
/*
  248 ROWS CREATED
*/

/*	SELECT COUNT(*) FROM (((
		SELECT DISTINCT NIF_DUENO
			FROM FSDB.MEGATABLE
			WHERE NOT NIF_DUENO = NIF_CONDTR)
  --97 owners who do not drive
   UNION
  (SELECT DISTINCT NIF_CONDTR
			FROM FSDB.MEGATABLE
			WHERE NOT NIF_DUENO = NIF_CONDTR))
  --107 drivers which are not owners
	UNION
  (SELECT NIF_DUENO
    FROM FSDB.MEGATABLE
    INTERSECT
  SELECT NIF_CONDTR
    FROM FSDB.MEGATABLE));
	--156 are both roles
*/

INSERT INTO DRIVER (DriverDni,type,ldate,age)
  SELECT DISTINCT NIF_CONDTR,CARNET_CONDTR,TO_DATE(FECHA_CARNET,'YYYY-MM-DD'),EDAD_CONDTR
    FROM FSDB.MEGATABLE WHERE EDAD_CONDTR >= 18;
/*
  203 ROWS CREATED
*/

INSERT INTO OWNER (OwnerDni)
  SELECT DISTINCT NIF_DUENO
    FROM FSDB.MEGATABLE;
/*
  197 ROWS CREATED
*/

INSERT INTO VEHICLE (nPlate,VIN,registration,brand,model,color,itv,Dni)
SELECT DISTINCT MATRICULA,VIN,TO_DATE(FECHA_MATRICULA,'YYYY-MM-DD'),MARCA,MODELO,COLOR,TO_DATE(FECHA_ITV,'YYYY-MM-DD'),NIF_DUENO
FROM FSDB.MEGATABLE;
/*
  250 ROWS CREATED
*/

INSERT INTO DRIVES_VEHICLE (DriverDni,nPlate)
SELECT DISTINCT NIF_CONDTR, MATRICULA
FROM FSDB.MEGATABLE WHERE EDAD_CONDTR >= 18;
/*
  246 ROWS CREATED
*/

INSERT INTO ROAD (rname, speedlimit)
SELECT DISTINCT CARRETERA_FOTO, LIMIT_VEL_CTERA
FROM FSDB.MEGATABLE;
/*
  10 ROWS CREATED
*/

/*-------------------------------Insertion by road------------------------------*/

/*
  INSERT INTO RADAR (rname, mileagepoint, direction, speedlimit)
	SELECT DISTINCT CARRETERA_FOTO, PTO_KM_RADAR, SENTIDO_RADAR, LIMIT_VEL_RADAR
    FROM FSDB.MEGATABLE;

  --With speedlimit as PK of RADAR.

	--436 rows
*/

INSERT INTO RADAR (rname, mileagepoint, direction, speedlimit)
SELECT DISTINCT CARRETERA_FOTO, PTO_KM_RADAR, SENTIDO_RADAR, LIMIT_VEL_RADAR
FROM FSDB.MEGATABLE WHERE CARRETERA_FOTO LIKE 'A%' AND TO_NUMBER(LIMIT_VEL_RADAR) = 100;
/*
  88 ROWS CREATED A1,A2,A3,A4,A5,A6
*/
INSERT INTO RADAR (rname, mileagepoint, direction, speedlimit)
SELECT DISTINCT CARRETERA_FOTO, PTO_KM_RADAR, SENTIDO_RADAR, LIMIT_VEL_RADAR
FROM FSDB.MEGATABLE WHERE CARRETERA_FOTO LIKE 'M30' AND TO_NUMBER(LIMIT_VEL_RADAR) = 50;
/*
  16 ROWS CREATED M30
*/
INSERT INTO RADAR (rname, mileagepoint, direction, speedlimit)
SELECT DISTINCT CARRETERA_FOTO, PTO_KM_RADAR, SENTIDO_RADAR, LIMIT_VEL_RADAR
FROM FSDB.MEGATABLE WHERE CARRETERA_FOTO LIKE 'M4%' AND TO_NUMBER(LIMIT_VEL_RADAR) = 80;
/*
  31 ROWS CREATED M40
*/
INSERT INTO RADAR (rname, mileagepoint, direction, speedlimit)
SELECT DISTINCT CARRETERA_FOTO, PTO_KM_RADAR, SENTIDO_RADAR, LIMIT_VEL_RADAR
FROM FSDB.MEGATABLE WHERE CARRETERA_FOTO LIKE 'M50' AND TO_NUMBER(LIMIT_VEL_RADAR) = 100;
/*
  15 ROWS CREATED M50
*/
/*-------------------------------Insertion by road------------------------------*/

INSERT INTO OBSERVATION (odate, otime, speed, rname, mileagepoint, direction, nPlate)
SELECT DISTINCT TO_DATE(FECHA_FOTO, 'YYYY-MM-DD'), TO_TIMESTAMP(HORA_FOTO, 'HH24:MI:SS.FF'), VELOCIDAD_FOTO, CARRETERA_FOTO, PTO_KM_RADAR, SENTIDO_RADAR, MATRICULA
FROM FSDB.MEGATABLE;
/*
  50000 ROWS CREATED
*/
