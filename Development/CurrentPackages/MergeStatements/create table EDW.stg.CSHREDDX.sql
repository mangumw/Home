create table EDW.stg.CSHREDDX
(
    ID int identity, 
    StoreNumber varchar(25),
	TransactionCentury int,
    TransactionDate varchar(250),
	RegisterNumber int,
	TillNumber int,
	ReportLineNo int,
	DepartmentNo int,
	ReportAmount Decimal(11,2),
    HashValue as CHECKSUM(ID,StoreNumber,TransactionCentury,TransactionDate,RegisterNumber,TillNumber,ReportLineNo,DepartmentNo,ReportAmount)  
    CONSTRAINT COMBOKEY2  PRIMARY KEY (ID,StoreNumber,TransactionCentury,TransactionDate,RegisterNumber,TillNumber,ReportLineNo,DepartmentNo,ReportAmount)
	)

 create table EDW.stg.CSHREDDXR
(
    ID int identity, 
    StoreNumber varchar(25),
	TransactionCentury int,
    TransactionDate varchar(250),
	RegisterNumber int,
	TillNumber int,
	ReportLineNo int,
	DepartmentNo int,
	ReportAmount Decimal(11,2),
    HashValue as HASHBYTES(ID + StoreNumber + TransactionCentury + TransactionDate + RegisterNumber + TillNumber + ReportLineNo + DepartmentNo + ReportAmount)  
    CONSTRAINT COMBOKEY2  PRIMARY KEY (ID,StoreNumber,TransactionCentury,TransactionDate,RegisterNumber,TillNumber,ReportLineNo,DepartmentNo,ReportAmount)
	)   


    CAST(HASHBYTES('SHA1', ISNULL(CAST)))