USE EDW
GO

CREATE PROCEDURE dbo.MERGE_IAHST
AS
BEGIN
MERGE EDW.dbo.IAHST as target 
USING EDW.stg.IAHST as source
ON
    (
        target.HistorySequenceNumber                    = source.HistorySequenceNumber
    )

ItemNumber,
WarehouseID,
UnitofMeasure,
TransactionCentury,
TransactionDate,
Time,
SequenceNumber,
TransactionCode,
TransactionQuantity,
CostorExtension,
CostorExtensionCode,
QuantityonHandLastTransaction,
AverageCostLastTransaction,
ItemGLCode,
CompanyNumber,
GLPostingCentury,
GLPostingDate,
InternalGLAcctNo1,
InternalGLAcctNo2,
InternalGLAcctNo3,
InternalGLAcctNo4,
InternalGLAcctNo5,
InternalGLAcctNo6,
InternalGLAcctNo7,
InternalGLAcctNo8,
InternalGLAcctNo9,
DebitorCreditCode1,
DebitorCreditCode2,
DebitorCreditCode3,
DebitorCreditCode4,
DebitorCreditCode5,
DebitorCreditCode6,
DebitorCreditCode7,
DebitorCreditCode8,
DebitorCreditCode9,
Amount1,
Amount2,
Amount3,
Amount4,
Amount5,
Amount6,
Amount7,
Amount8,
Amount9,
JournalNumber,
RelativeRecordNumber,
RecordNumber,
OriginalUser,
IAHistoryAccountBucket2,
UpdateInventoryCode 