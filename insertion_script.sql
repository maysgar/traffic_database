INSERT INTO OWNER (Name,Surname_1,Surname_2,Address,Town,Dni,Mobile,Email,Birth)
SELECT owner_name,owner_surn1,owner_surn2,owner_address,owner_town,owner_DNI,TO_NUMBER(owner_mobile,'999999999'),owner_email,TO_DATE(owner_birth,'YYYY-MM-DD')
  FROM FSDB.MEGATABLE;
