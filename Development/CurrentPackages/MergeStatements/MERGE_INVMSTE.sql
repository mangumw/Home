CREATE PROCEDURE dbo.MERGE_INVMSTE
AS
BEGIN
MERGE EDW.dbo.INVMSTE AS target 
USING EDW.stg.INVMSTE AS source
ON
    (
        target.SkuNumber                = source.SkuNumber
    )
WHEN MATCHED 
    THEN UPDATE
        SET target.StyleVendor          = source.StyleVendor,
            target.StyleNumber          = source.StyleNumber,
            target.SkuNumber            = source.SkuNumber,
            target.FirstActivityCentury = source.FirstActivityCentury,
            target.FirstActivityDate    = source.FirstActivityDate,
            target.BackStockPct         = source.BackStockPct,
            target.BackStockQty         = source.BackStockQty,
            target.ChainOrder           = source.ChainOrder,
            target.PublisherRunQty      = source.PublisherRunQty,
            target.OutofPrintTitleFlag  = source.OutofPrintTitleFlag,
            target.PrivateLabelFlag     = source.PrivateLabelFlag,
            target.SellDownActivityCode = source.SellDownActivityCode,
            target.ImportFlag           = source.ImportFlag,
            target.Method               = source.Method,
            target.MethodPercent        = source.MethodPercent,
            target.PublisherCost        = source.PublisherCost,
            target.PublisherCostPercent = source.PublisherCostPercent,
            target.DWItemnumber         = source.DWItemnumber,
            target.Converteditem        = source.Converteditem,
            target.StatusChangeCentury  = source.StatusChangeCentury,
            target.StatusChangeDate     = source.StatusChangeDate,
            target.TypeChangeCentury    = source.TypeChangeCentury,
            target.TypeChangeDate       = source.TypeChangeDate,
            target.ItemEntryCentury     = source.ItemEntryCentury,
            target.ItemEntryDate        = source.ItemEntryDate,
            target.GroupDist            = source.GroupDist,
            target.LimitAddGroup        = source.LimitAddGroup,
            target.LOFLAG               = source.LOFLAG,
            target.LOGRPOFGRPS          = source.LOGRPOFGRPS,
            target.LOSTORE              = source.LOSTORE,
            target.InitialOrderQuantity = source.InitialOrderQuantity,
            target.ExpectedReceiptCentury   = source.ExpectedReceiptCentury,
            target.ExpectdReceiptDate   = source.ExpectdReceiptDate,
            target.InitialAllocQuantity = source.InitialAllocQuantity,
            target.InitialStrength      = source.InitialStrength,
            target.InitialStockto       = source.InitialStockto,
            target.LastMaintainedby     = source.LastMaintainedby
WHEN NOT MATCHED BY TARGET
    THEN INSERT
        (
           StyleVendor,
            StyleNumber,
            SkuNumber,
            FirstActivityCentury,
            FirstActivityDate,
            BackStockPct,
            BackStockQty,
            ChainOrder,
            PublisherRunQty,
            OutofPrintTitleFlag,
            PrivateLabelFlag,
            SellDownActivityCode,
            ImportFlag,
            Method,
            MethodPercent,
            PublisherCost,
            PublisherCostPercent,
            DWItemnumber,
            Converteditem,
            StatusChangeCentury,
            StatusChangeDate,
            TypeChangeCentury,
            TypeChangeDate,
            ItemEntryCentury,
            ItemEntryDate,
            GroupDist,
            LimitAddGroup,
            LOFLAG,
            LOGRPOFGRPS,
            LOSTORE,
            InitialOrderQuantity,
            ExpectedReceiptCentury,
            ExpectdReceiptDate,
            InitialAllocQuantity,
            InitialStrength,
            InitialStockto,
            LastMaintainedby  
        )   
    VALUES
        (
            source.StyleVendor,
            source.StyleNumber,
            source.SkuNumber,
            source.FirstActivityCentury,
            source.FirstActivityDate,
            source.BackStockPct,
            source.BackStockQty,
            source.ChainOrder,
            source.PublisherRunQty,
            source.OutofPrintTitleFlag,
            source.PrivateLabelFlag,
            source.SellDownActivityCode,
            source.ImportFlag,
            source.Method,
            source.MethodPercent,
            source.PublisherCost,
            source.PublisherCostPercent,
            source.DWItemnumber,
            source.Converteditem,
            source.StatusChangeCentury,
            source.StatusChangeDate,
            source.TypeChangeCentury,
            source.TypeChangeDate,
            source.ItemEntryCentury,
            source.ItemEntryDate,
            source.GroupDist,
            source.LimitAddGroup,
            source.LOFLAG,
            source.LOGRPOFGRPS,
            source.LOSTORE,
            source.InitialOrderQuantity,
            source.ExpectedReceiptCentury,
            source.ExpectdReceiptDate,
            source.InitialAllocQuantity,
            source.InitialStrength,
            source.InitialStockto,
            source.LastMaintainedby 
        ) 
    ;
END;                                 