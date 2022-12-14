USE [EDW]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE dbo.MERGE_HSDET
AS
BEGIN
MERGE EDW.dbo.HSDET as target
USING EDW.stg.HSDET as source
ON
    (
        target.HistorySequenceNumber                    = source.HistorySequenceNumber
        and target.OrderSequenceNumber                  = source.OrderSequenceNumber
        and target.ItemNumber                           = source.ItemNumber
    )    
    WHEN MATCHED
        THEN UPDATE
            SET target.CompanyNumber                    = source.CompanyNumber,
                target.CustomerNumber                   = source.CustomerNumber,
                target.OrderNumber                      = source.OrderNumber,
                target.OrderGenerationNumber            = source.OrderGenerationNumber,
                target.HistorySequenceNumber            = source.HistorySequenceNumber,
                target.OrderSequenceNumber              = source.OrderSequenceNumber,
                target.LineItemType                     = source.LineItemType,
                target.ShipToNumber                     = source.ShipToNumber,
                target.PrimarySalesmanNumber            = source.PrimarySalesmanNumber,
                target.WarehouseID                      = source.WarehouseID,
                target.OrderType                        = source.OrderType,
                target.PriceList                        = source.PriceList,
                target.OrderHoldCode                    = source.OrderHoldCode,
                target.Century1                         = source.Century1,
                target.RequestDate                      = source.RequestDate,
                target.LotCode                          = source.LotCode,
                target.ItemNumber                       = source.ItemNumber,
                target.ItemDescription1                 = source.ItemDescription1,
                target.ItemDescription2                 = source.ItemDescription2,
                target.QuantityOrdered                  = source.QuantityOrdered,
                target.QuantityShipped                  = source.QuantityShipped,
                target.QuantityBackordered              = source.QuantityBackordered,
                target.UnitofMeasure                    = source.UnitofMeasure,
                target.UMCode                           = source.UMCode,
                target.ItemClass                        = source.ItemClass,
                target.ItemSubclass                     = source.ItemSubclass,
                target.NonStockCode                     = source.NonStockCode,
                target.ListPrice                        = source.ListPrice,
                target.ItemDiscountPercent              = source.ItemDiscountPercent,
                target.FinalPriceOverrideCode           = source.FinalPriceOverrideCode,
                target.QtyDscType                       = source.QtyDscType, 
                target.CharacterFillerField1            = source.CharacterFillerField1,
                target.AdditionalDiscountPercent        = source.AdditionalDiscountPercent,
                target.ActualSellPrice                  = source.ActualSellPrice,
                target.TotalLineAmount                  = source.TotalLineAmount,
                target.LotChargeCode                    = source.LotChargeCode,
                target.SystemTotalLineAmount            = source.SystemTotalLineAmount,
                target.Pricing                          = source.Pricing,
                target.TaxableCode                      = source.TaxableCode,
                target.TaxExemptCode                    = source.TaxExemptCode,
                target.ContainerCharge                  = source.ContainerCharge,
                target.FederalExciseTaxAmount           = source.FederalExciseTaxAmount,
                target.AllowCashDiscountCode            = source.AllowCashDiscountCode,
                target.WarehouseLocation                = source.WarehouseLocation,
                target.CurrentAverageCost               = source.CurrentAverageCost,
                target.OurPurchaseOrderNumber           = source.OurPurchaseOrderNumber,
                target.AllocatedCode                    = source.AllocatedCode,
                target.LineValue                        = source.LineValue,
                target.CostOverrideCode                 = source.CostOverrideCode,
                target.InvoiceCost                      = source.InvoiceCost,
                target.UnitWeight                       = source.UnitWeight,
                target.ExtendedWeight                   = source.ExtendedWeight,
                target.DropShipCode                     = source.DropShipCode,
                target.ReUsableCode                     = source.ReUsableCode,
                target.KitBuildQuantity                 = source.KitBuildQuantity,
                target.GeneralLedgerAccountNumber       = source.GeneralLedgerAccountNumber,
                target.QuantityBreakClass               = source.QuantityBreakClass,
                target.DiscountMarkupCode1              = source.DiscountMarkupCode1,
                target.OrderEntrySequence               = source.OrderEntrySequence,
                target.Century2                         = source.Century2,
                target.InvoiceDate                      = source.InvoiceDate,
                target.PriceClass                       = source.PriceClass,
                target.ContractCode                     = source.ContractCode,
                target.CustomerSortWord                 = source.CustomerSortWord,
                target.ItemQuantityDiscount             = source.ItemQuantityDiscount,
                target.UserArea                         = source.UserArea,
                target.BillofMaterialsCode              = source.BillofMaterialsCode,
                target.ItemDescPrintCode                = source.ItemDescPrintCode,
                target.ItemGLCode                       = source.ItemGLCode,
                target.SpecialOrderSequence             = source.SpecialOrderSequence,
                target.InsertInProgressFlag             = source.InsertInProgressFlag,
                target.AssignedComplete                 = source.AssignedComplete,
                target.WHMgmtCode                       = source.WHMgmtCode,
                target.CharacterFillerField2            = source.CharacterFillerField2,
                target.ParentOrderNumber                = source.ParentOrderNumber,
                target.EntrySequenceNumber              = source.EntrySequenceNumber,
                target.OriginalQuantity                 = source.OriginalQuantity,
                target.OriginalItemNumber               = source.OriginalItemNumber,
                target.ReplacementReasonCode            = source.ReplacementReasonCode,
                target.OriginalWarehouse                = source.OriginalWarehouse,
                target.ReturnReasonCode                 = source.ReturnReasonCode,
                target.InvoicePrintSequence             = source.InvoicePrintSequence,
                target.ProcuctRestrictionCode           = source.ProcuctRestrictionCode,
                target.CommissionCost                   = source.CommissionCost,
                target.RebateId                         = source.RebateId,
                target.InventoryCost                    = source.InventoryCost,
                target.RebateVendorNumber               = source.RebateVendorNumber,
                target.RebatePending                    = source.RebatePending,
                target.CustomerOrder                    = source.CustomerOrder,
                target.DocumentNumber                   = source.DocumentNumber,
                target.EDILineReferenceNumber           = source.EDILineReferenceNumber,
                target.CustomerOrderQuantity            = source.CustomerOrderQuantity,
                target.CustomerPricing                  = source.CustomerPricing,
                target.OriginalParOrderNumber           = source.OriginalParOrderNumber,
                target.OriginalEntrySeqNmbr             = source.OriginalEntrySeqNmbr,
                target.LineItemTaxAmount                = source.LineItemTaxAmount,
                target.OrderTaxAmount                   = source.OrderTaxAmount,
                target.ConsolidatedBillCode             = source.ConsolidatedBillCode,
                target.ConsolidatedInvControlNumber     = source.ConsolidatedInvControlNumber,
                target.ConsolidatedInvPrtFlag           = source.ConsolidatedInvPrtFlag,
                target.ItemContractCode                 = source.ItemContractCode,
                target.InventoryPostedFlag              = source.InventoryPostedFlag,
                target.ReturntoVendorLogNumber          = source.ReturntoVendorLogNumber,
                target.DaysinProcessType                = source.DaysinProcessType,
                target.Last_Modified                    = source.Last_Modified 
WHEN NOT MATCHED BY TARGET 
            THEN INSERT
                (
                    CompanyNumber,
                    CustomerNumber,
                    OrderNumber,
                    OrderGenerationNumber,
                    HistorySequenceNumber,
                    OrderSequenceNumber,
                    LineItemType,
                    ShipToNumber,
                    PrimarySalesmanNumber,
                    WarehouseID,
                    OrderType,
                    PriceList,
                    OrderHoldCode,
                    Century1,
                    RequestDate,
                    LotCode,
                    ItemNumber,
                    ItemDescription1,
                    ItemDescription2,
                    QuantityOrdered,
                    QuantityShipped,
                    QuantityBackordered,
                    UnitofMeasure,
                    UMCode,
                    ItemClass,
                    ItemSubclass,
                    NonStockCode,
                    ListPrice,
                    ItemDiscountPercent,
                    FinalPriceOverrideCode,
                    QtyDscType, 
                    CharacterFillerField1,
                    AdditionalDiscountPercent,
                    ActualSellPrice,
                    TotalLineAmount,
                    LotChargeCode,
                    SystemTotalLineAmount,
                    Pricing,
                    TaxableCode,
                    TaxExemptCode,
                    ContainerCharge,
                    FederalExciseTaxAmount,
                    AllowCashDiscountCode,
                    WarehouseLocation,
                    CurrentAverageCost,
                    OurPurchaseOrderNumber,
                    AllocatedCode,
                    LineValue,
                    CostOverrideCode,
                    InvoiceCost,
                    UnitWeight,
                    ExtendedWeight,
                    DropShipCode,
                    ReUsableCode,
                    KitBuildQuantity,
                    GeneralLedgerAccountNumber,
                    QuantityBreakClass,
                    DiscountMarkupCode1,
                    OrderEntrySequence,
                    Century2,
                    InvoiceDate,
                    PriceClass,
                    ContractCode,
                    CustomerSortWord,
                    ItemQuantityDiscount,
                    UserArea,
                    BillofMaterialsCode,
                    ItemDescPrintCode,
                    ItemGLCode,
                    SpecialOrderSequence,
                    InsertInProgressFlag,
                    AssignedComplete,
                    WHMgmtCode,
                    CharacterFillerField2,
                    ParentOrderNumber,
                    EntrySequenceNumber,
                    OriginalQuantity,
                    OriginalItemNumber,
                    ReplacementReasonCode,
                    OriginalWarehouse,
                    ReturnReasonCode,
                    InvoicePrintSequence,
                    ProcuctRestrictionCode,
                    CommissionCost,
                    RebateId,
                    InventoryCost,
                    RebateVendorNumber,
                    RebatePending,
                    CustomerOrder,
                    DocumentNumber,
                    EDILineReferenceNumber,
                    CustomerOrderQuantity,
                    CustomerPricing,
                    OriginalParOrderNumber,
                    OriginalEntrySeqNmbr,
                    LineItemTaxAmount,
                    OrderTaxAmount,
                    ConsolidatedBillCode,
                    ConsolidatedInvControlNumber,
                    ConsolidatedInvPrtFlag,
                    ItemContractCode,
                    InventoryPostedFlag,
                    ReturntoVendorLogNumber,
                    DaysinProcessType,
                    Last_Modified                     
                )   
        VALUES
                (
                    source.CompanyNumber,
                    source.CustomerNumber,
                    source.OrderNumber,
                    source.OrderGenerationNumber,
                    source.HistorySequenceNumber,
                    source.OrderSequenceNumber,
                    source.LineItemType,
                    source.ShipToNumber,
                    source.PrimarySalesmanNumber,
                    source.WarehouseID,
                    source.OrderType,
                    source.PriceList,
                    source.OrderHoldCode,
                    source.Century1,
                    source.RequestDate,
                    source.LotCode,
                    source.ItemNumber,
                    source.ItemDescription1,
                    source.ItemDescription2,
                    source.QuantityOrdered,
                    source.QuantityShipped,
                    source.QuantityBackordered,
                    source.UnitofMeasure,
                    source.UMCode,
                    source.ItemClass,
                    source.ItemSubclass,
                    source.NonStockCode,
                    source.ListPrice,
                    source.ItemDiscountPercent,
                    source.FinalPriceOverrideCode,
                    source.QtyDscType, 
                    source.CharacterFillerField1,
                    source.AdditionalDiscountPercent,
                    source.ActualSellPrice,
                    source.TotalLineAmount,
                    source.LotChargeCode,
                    source.SystemTotalLineAmount,
                    source.Pricing,
                    source.TaxableCode,
                    source.TaxExemptCode,
                    source.ContainerCharge,
                    source.FederalExciseTaxAmount,
                    source.AllowCashDiscountCode,
                    source.WarehouseLocation,
                    source.CurrentAverageCost,
                    source.OurPurchaseOrderNumber,
                    source.AllocatedCode,
                    source.LineValue,
                    source.CostOverrideCode,
                    source.InvoiceCost,
                    source.UnitWeight,
                    source.ExtendedWeight,
                    source.DropShipCode,
                    source.ReUsableCode,
                    source.KitBuildQuantity,
                    source.GeneralLedgerAccountNumber,
                    source.QuantityBreakClass,
                    source.DiscountMarkupCode1,
                    source.OrderEntrySequence,
                    source.Century2,
                    source.InvoiceDate,
                    source.PriceClass,
                    source.ContractCode,
                    source.CustomerSortWord,
                    source.ItemQuantityDiscount,
                    source.UserArea,
                    source.BillofMaterialsCode,
                    source.ItemDescPrintCode,
                    source.ItemGLCode,
                    source.SpecialOrderSequence,
                    source.InsertInProgressFlag,
                    source.AssignedComplete,
                    source.WHMgmtCode,
                    source.CharacterFillerField2,
                    source.ParentOrderNumber,
                    source.EntrySequenceNumber,
                    source.OriginalQuantity,
                    source.OriginalItemNumber,
                    source.ReplacementReasonCode,
                    source.OriginalWarehouse,
                    source.ReturnReasonCode,
                    source.InvoicePrintSequence,
                    source.ProcuctRestrictionCode,
                    source.CommissionCost,
                    source.RebateId,
                    source.InventoryCost,
                    source.RebateVendorNumber,
                    source.RebatePending,
                    source.CustomerOrder,
                    source.DocumentNumber,
                    source.EDILineReferenceNumber,
                    source.CustomerOrderQuantity,
                    source.CustomerPricing,
                    source.OriginalParOrderNumber,
                    source.OriginalEntrySeqNmbr,
                    source.LineItemTaxAmount,
                    source.OrderTaxAmount,
                    source.ConsolidatedBillCode,
                    source.ConsolidatedInvControlNumber,
                    source.ConsolidatedInvPrtFlag,
                    source.ItemContractCode,
                    source.InventoryPostedFlag,
                    source.ReturntoVendorLogNumber,
                    source.DaysinProcessType,
                    source.Last_Modified                     
                ) 
    ;
END;                                    