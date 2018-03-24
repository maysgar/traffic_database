-- ----------------------------------------------------
-- -- Part III: Populate tables by querying old ones --
-- ----------------------------------------------------


INSERT INTO CATALOG(make,model,power) 
   SELECT marca, modelo, MIN(TO_NUMBER(potencia,'9999')) 
      FROM FSDB.MEGATABLE
      GROUP BY (marca, modelo);  
-- Problem: there were several 'power' values for some 'make'&'model'
-- Implicit assumption: in case that occurs, minimum value should be taken
-- 32 rows created. 


INSERT INTO PERSONS (DNI,name,surn_1,surn_2,address,town,mobile,email,birthdate) 
   (SELECT DISTINCT NIF_dueno,nombre_dueno,apell_1_dueno,apell_2_dueno,direcc_dueno,ciudad_dueno,
                    tlf_dueno,email_dueno,to_date(cumple_dueno, 'YYYY-MM-DD') 
       FROM FSDB.MEGATABLE
    UNION
    SELECT DISTINCT NIF_condtr,nombre_condtr,apell_1_condtr,apell_2_condtr,direcc_condtr,ciudad_condtr,
                    tlf_condtr,email_condtr,to_date(cumple_condtr, 'YYYY-MM-DD') 
       FROM FSDB.MEGATABLE
    );  
-- 248 rows created. 


INSERT INTO DRIVERS (DNI,lic_date,lic_type)
   SELECT DISTINCT NIF_condtr,TO_DATE(fecha_carnet,'YYYY-MM-DD'),carnet_condtr 
      FROM FSDB.MEGATABLE;
-- 207 rows created. 


INSERT INTO VEHICLES (nPlate,vin,make,model,color,reg_date,MOT_date,reg_driver,owner)
   SELECT DISTINCT matricula,VIN,marca,modelo,color,TO_DATE(fecha_matricula,'YYYY-MM-DD'),
                   TO_DATE(fecha_ITV,'YYYY-MM-DD'), NIF_CONDTR, NIF_dueno 
      FROM FSDB.MEGATABLE;
-- 250 rows created. 

   
INSERT INTO ASSIGNMENTS (driver, nPlate)
   SELECT DISTINCT NIF_condtr,matricula FROM FSDB.MEGATABLE
   MINUS 
   SELECT reg_driver,nPlate FROM VEHICLES;
-- 0 rows created. 


INSERT INTO ROADS (name,speed_limit) 
   SELECT DISTINCT carretera_foto,limit_vel_ctera FROM FSDB.MEGATABLE; 
-- 10 rows created. 


INSERT INTO RADARS (road,Km_point,direction,speedlim)
   SELECT carretera_foto,pto_km_radar,sentido_radar, MIN(limit_vel_radar) 
      FROM FSDB.MEGATABLE 
      GROUP BY (carretera_foto,pto_km_radar,sentido_radar);  
-- Problem: there were several 'speed_limit' values for some radars
-- Implicit assumption: in case that occurs, minimum speed_limit will be taken
-- 150 rows created. 


INSERT INTO OBSERVATIONS (nPlate,odatetime,road,km_point,direction,speed)
   SELECT DISTINCT matricula, TO_TIMESTAMP(fecha_foto||hora_foto,'YYYY-MM-DDHH24:MI:SS.FF2'),
                   carretera_foto,pto_km_radar,sentido_radar, velocidad_foto
      FROM FSDB.MEGATABLE;
--50.000 rows created. 
