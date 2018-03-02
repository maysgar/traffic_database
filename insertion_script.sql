INSERT INTO OWNER (OName,OSurname_1,OSurname_2,OAddress,OTown,ODni,OMobile,OEmail,OBirth)
  SELECT DISTINCT NOMBRE_DUENO,APELL_1_DUENO,APELL_2_DUENO,DIRECC_DUENO,CIUDAD_DUENO,NIF_DUENO,TO_NUMBER(TLF_DUENO,'999999999'),EMAIL_DUENO,TO_DATE(CUMPLE_DUENO,'YYYY-MM-DD')
    FROM FSDB.MEGATABLE;
/*197 FILAS*/

INSERT INTO DRIVER (DName,DSurname_1,DSurname_2,DAddress,DTown,DDni,DMobile,DEmail,DBirth,type,ldate,age)
  SELECT NOMBRE_CONDTR,APELL_1_CONDTR,APELL_2_CONDTR,DIRECC_CONDTR,CIUDAD_CONDTR,NIF_CONDTR,TO_NUMBER(TLF_CONDTR,'999999999'),EMAIL_CONDTR,TO_DATE(CUMPLE_CONDTR,'YYYY-MM-DD'),CARNET_CONDTR,TO_DATE(FECHA_CARNET,'YYYY-MM-DD'),EDAD_CONDTR
    FROM FSDB.MEGATABLE WHERE EDAD_CONDTR >= 18;
/**/
