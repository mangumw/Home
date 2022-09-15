--select max(length(IVNDP#)) from MM4R4LIB.TRFDTL ;
  
  select substring(IVNDP#,1,15) as xxx from MM4R4LIB.TRFDTL
